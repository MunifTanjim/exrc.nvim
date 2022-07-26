local cache_path = vim.fn.stdpath("cache") .. "/exrc.nvim.json"

local cache_default_data = {
  __exrc__ = "v0.1",
}

---@param data table JSON object
---@return string|nil blob # encoded string
---@return nil|string error
local function json_encode(data)
  local ok, result = pcall(vim.fn.json_encode, data)

  if ok then
    return result
  end

  return nil, result
end

---@param blob string # encoded string
---@return table|nil data # JSON object
---@return nil|table error
local function json_decode(blob)
  local ok, result = pcall(vim.fn.json_decode, blob)

  if ok then
    return result
  end

  return nil, result
end

local function cache_file_exists()
  return vim.fn.filereadable(cache_path) == 1
end

local function cache_file_read()
  local blob = vim.fn.readfile(cache_path)[1]

  local decoded_data, err = json_decode(blob)
  if err then
    vim.api.nvim_err_writeln("[exrc.nvim] file read error: " .. err)
    return
  end

  return decoded_data
end

---@param data table
local function cache_file_write(data)
  local blob, err = json_encode(data)
  if err then
    vim.api.nvim_err_writeln("[exrc.nvim] file write error: " .. err)
    return
  end

  vim.fn.writefile({ blob }, cache_path)
end

local function cache_file_ensure()
  if not cache_file_exists() then
    vim.fn.mkdir(vim.fn.fnamemodify(cache_path, ":h"), "p")
    cache_file_write(cache_default_data)
  end
end

---@param data table|nil
local function cache_has_current_version(data)
  return data and data.__exrc__ == cache_default_data.__exrc__ or false
end

local cache_data

local cache = {
  _initialized = false,
}

---@param filepath string
---@return nil|{ hash: string, allowed: boolean, modified_at: number }
function cache.get(filepath)
  return cache_data[filepath]
end

---@param filepath string
---@param value { hash: string, allowed: boolean }
function cache.set(filepath, value)
  value.modified_at = os.time()

  cache_data[filepath] = value

  vim.schedule(function()
    cache_file_write(cache_data)
  end)
end

function cache.setup()
  if cache._initialized then
    return
  end

  cache_file_ensure()

  local data = cache_file_read()

  if cache_has_current_version(data) then
    cache_data = data
  else
    cache_data = vim.deepcopy(cache_default_data)
  end

  cache._initialized = true
end

return cache
