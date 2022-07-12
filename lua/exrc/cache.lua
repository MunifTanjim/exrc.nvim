---@param data table JSON object
---@returns string encoded string
local function json_encode(data)
  local success, result = pcall(vim.fn.json_encode, data)

  if success then
    return result
  end

  return nil, result
end

---@param data string encoded string
---@returns table JSON object
local function json_decode(data)
  local success, result = pcall(vim.fn.json_decode, data)

  if success then
    return result
  end

  return nil, result
end

local data = {}

local cache = {
  _initialized = false,
  path = vim.fn.stdpath("cache") .. "/exrc.nvim.json",
}

function cache.get(filepath)
  return data[filepath]
end

function cache.set(filepath, value)
  data[filepath] = value
  vim.schedule(function()
    vim.fn.writefile({ json_encode(data) }, cache.path)
  end)
end

function cache.setup()
  if cache._initialized then
    return
  end

  if vim.fn.glob(cache.path) == "" then
    vim.fn.mkdir(vim.fn.fnamemodify(cache.path, ":h"), "p")
    vim.fn.writefile({ json_encode(data) }, cache.path)
  end

  data = json_decode(vim.fn.readfile(cache.path))

  cache._initialized = true
end

return cache
