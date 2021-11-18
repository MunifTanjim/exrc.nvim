local cache = require("exrc.cache")
local options = require("exrc.options")
local Menu = require("nui.menu")

local function file_hash(filepath)
  return vim.fn.sha256(table.concat(vim.fn.readfile(filepath, "b"), "\n"))
end

local mod = {
  _initialized = false,
}

function mod.setup(user_options)
  if mod._initialized then
    return
  end

  options.setup(user_options or {})
  cache.setup()

  if vim.o.exrc then
    error("[exrc.nvim] unset 'exrc' to use this plugin!")
  end

  vim.cmd([[
    augroup exrc-nvim-source
      autocmd!

      autocmd DirChanged * if v:event.scope ==# "global" | call v:lua.require("exrc").try_source() | endif

      if v:vim_did_enter
        lua require("exrc").try_source()
      else
        autocmd VimEnter * lua require("exrc").try_source()
      endif
    augroup END
  ]])

  mod._initialized = true
end

function mod.try_source()
  for _, file in ipairs(options.get("files")) do
    local filepath = vim.fn.fnamemodify(file, ":p")
    if vim.fn.glob(filepath) ~= "" then
      mod.source(filepath)
      break
    end
  end
  vim.api.nvim_exec([[doautocmd <nomodeline> User ExrcDone]], false)
end

function mod.source(filepath)
  local cached_result = cache.get(filepath)

  if type(cached_result) == "boolean" then
    if not cached_result then
      return false
    end

    vim.cmd("source " .. filepath)
    return true
  end

  local current_hash = file_hash(filepath)

  if type(cached_result) == "string" then
    if current_hash == cached_result then
      vim.cmd("source " .. filepath)
      return true
    end
  end

  local relative_filepath = vim.fn.fnamemodify(filepath, ":.")

  local action = {
    allow = function()
      cache.set(filepath, current_hash)
      vim.cmd("source " .. filepath)
    end,

    disallow = function()
      cache.set(filepath, false)
    end,

    open = function()
      vim.cmd(
        string.format(
          "tabedit +%s %s",
          string.gsub(
            string.format(
              [[set nohidden | autocmd BufWinLeave <buffer> ++once :lua require("exrc").source("%s")]],
              filepath
            ),
            " ",
            "\\ "
          ),
          relative_filepath
        )
      )
    end,
  }

  local title = "[Config Changed: " .. relative_filepath .. "]"

  if type(cached_result) == "nil" then
    title = "[Config Unknown: " .. relative_filepath .. "]"
  end

  local menu = Menu({
    relative = "editor",
    border = {
      style = "rounded",
      highlight = "Normal",
      text = {
        top = title,
      },
    },
    position = {
      row = "50%",
      col = "50%",
    },
    win_options = {
      winhighlight = "Normal:Normal",
    },
  }, {
    lines = {
      Menu.item("[A]llow", { action = "allow" }),
      Menu.item("[D]isallow", { action = "disallow" }),
      Menu.item("[C]lose"),
      Menu.item("[O]pen", { action = "open" }),
    },
    min_width = #title + 2,
    keymap = {
      focus_next = { "j", "<Down>", "<Tab>" },
      focus_prev = { "k", "<Up>", "<S-Tab>" },
      close = { "<Esc>", "<C-c>" },
      submit = { "<CR>", "<Space>" },
    },
    on_submit = function(item)
      if item.action and action[item.action] then
        action[item.action]()
      end
    end,
  })

  menu:mount()

  menu:on("BufLeave", function()
    menu:unmount()
  end, { once = true })

  local map_options = { noremap = true, nowait = true }

  menu:map("n", "a", function()
    menu:unmount()
    action.allow()
  end, map_options)

  menu:map("n", "d", function()
    menu:unmount()
    action.disallow()
  end, map_options)

  menu:map("n", "c", function()
    menu:unmount()
  end, map_options)

  menu:map("n", "o", function()
    menu:unmount()
    action.open()
  end, map_options)
end

return mod
