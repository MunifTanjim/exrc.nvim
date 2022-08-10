local ui = {}

---@alias exrc_nvim_ui_select_item { text: string, key?: string }

---@param item exrc_nvim_ui_select_item
local function mark_key_char(item)
  if not item.key then
    return
  end

  local s, e = string.find(string.lower(item.text), string.lower(item.key), 1, true)
  if not s or not e then
    item.key = nil
    return
  end

  item.text = string.format(
    "%s[%s]%s",
    string.sub(item.text, 1, s - 1),
    string.sub(item.text, s, e),
    string.sub(item.text, e + 1)
  )
end

---@generic I : exrc_nvim_ui_select_item
---@param items I[]
---@param opts { kind?: string, prompt: string }
---@param on_select fun(item: I): nil
function ui.select(items, opts, on_select)
  local ok, Menu = pcall(require, "nui.menu")

  if not ok then
    ---@param item exrc_nvim_ui_select_item
    opts.format_item = function(item)
      return item.text
    end
    vim.ui.select(items, opts, on_select)
    return
  end

  local lines = vim.tbl_map(function(item)
    mark_key_char(item)
    return Menu.item(item)
  end, items)

  local menu = Menu({
    relative = "editor",
    border = {
      style = "rounded",
      text = {
        top = opts.prompt,
      },
    },
    position = "50%",
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:Normal",
    },
  }, {
    lines = lines,
    min_width = #opts.prompt + 2,
    keymap = {
      focus_next = { "j", "<Down>", "<Tab>" },
      focus_prev = { "k", "<Up>", "<S-Tab>" },
      close = { "<Esc>", "<C-c>" },
      submit = { "<CR>", "<Space>" },
    },
    on_submit = function(item)
      on_select(item)
    end,
  })

  menu:on("BufLeave", function()
    menu:unmount()
  end, { once = true })

  local map_options = { noremap = true, nowait = true }

  for _, item in ipairs(items) do
    if item.key then
      menu:map("n", item.key, function()
        menu:unmount()
        on_select(item)
      end, map_options)
    end
  end

  menu:mount()
end

return ui
