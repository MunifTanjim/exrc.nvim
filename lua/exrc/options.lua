local default_options = {
  _initialized = false,
  files = {
    ".nvimrc.lua",
    ".nvimrc",
    ".exrc",
  },
}

local function validate_options(user_options)
  vim.validate({
    ["files"] = {
      user_options["files"],
      "table",
      true,
    },
  })
end

local options = vim.deepcopy(default_options)

local M = {}

function M.setup(user_options)
  if options._initialized then
    return
  end

  validate_options(user_options)

  options = vim.tbl_deep_extend("force", options, user_options)

  options._initialized = true
end

function M.get(key)
  if type(key) == "string" then
    return vim.deepcopy(options[key])
  end

  return vim.deepcopy(options)
end

return M
