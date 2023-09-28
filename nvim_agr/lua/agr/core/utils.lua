local U = {}

local function dump (o)
  if type(o) == 'table' then
    local s = '{ '
    for k,v in pairs(o) do
      if type(k) ~= 'number' then k = '"'..k..'"' end
      s = s .. '['..k..'] = ' .. dump(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end

local key_down = vim.api.nvim_replace_termcodes('<Down>', true, true, true)

local default_tbl = function (opts, default)
  opts = opts or {}
  return default and vim.tbl_deep_extend('force', default, opts) or opts
end

local pad_string = function (str, padding)
  padding = padding or {}
  return str and str ~= '' and string.rep(' ', padding.left or 0) .. str .. string.rep(' ', padding.right or 0) or ''
end

--- Get a list of registered null-ls providers for a given filetype
-- @param filetype the filetype to search null-ls for
-- @return a list of null-ls sources
local null_ls_providers = function (filetype)
  local registered = {}
  -- try to load null-ls
  local sources_avail, sources = pcall(require, 'null-ls.sources')
  if sources_avail then
    -- get the available sources of a given filetype
    for _, source in ipairs(sources.get_available(filetype)) do
      -- get each source name
      for method in pairs(source.methods) do
        registered[method] = registered[method] or {}
        table.insert(registered[method], source.name)
      end
    end
  end
  -- return the found null-ls sources
  return registered
end

--- Register a null-ls source given a name if it has not been manually configured in the null-ls configuration
-- @param source the source name to register from all builtin types
local null_ls_register = function (source)
  -- try to load null-ls
  local null_ls_avail, null_ls = pcall(require, 'null-ls')
  if null_ls_avail then
    if null_ls.is_registered(source) then return end
    for _, type in ipairs { 'diagnostics', 'formatting', 'code_actions', 'completion', 'hover' } do
      local builtin = require('null-ls.builtins._meta.' .. type)
      if builtin[source] then null_ls.register(null_ls.builtins[type][source]) end
    end
  end
end

--- Get the null-ls sources for a given null-ls method
-- @param filetype the filetype to search null-ls for
-- @param method the null-ls method (check null-ls documentation for available methods)
-- @return the available sources for the given filetype and method
local null_ls_sources = function (filetype, method)
  local methods_avail, methods = pcall(require, 'null-ls.methods')
  return methods_avail and null_ls_providers(filetype)[methods.internal[method]] or {}
end

--- Get highlight properties for a given highlight name
-- @param name highlight group name
-- @return table of highlight group properties
local get_hlgroup = function (name, fallback)
  if vim.fn.hlexists(name) == 1 then
    local hl = vim.api.nvim_get_hl_by_name(name, vim.o.termguicolors)

    if not hl['foreground'] then hl['foreground'] = 'NONE' end
    if not hl['background'] then hl['background'] = 'NONE' end

    hl.fg, hl.bg, hl.sp = hl.foreground, hl.background, hl.special
    hl.ctermfg, hl.ctermbg = hl.foreground, hl.background

    return hl
  end

  return fallback
end

local lualine_mode = function (mode, fallback)
  local lualine_avail, lualine = pcall(require, 'lualine.themes.dracula-nvim')
  local lualine_opts = lualine_avail and lualine[mode]

  return lualine_opts and type(lualine_opts.a) == 'table' and lualine_opts.a.bg or fallback
end

local has_plugin = function (plug)
  local status, plugin = pcall(require, plug)
  if not status then return false end

  return plugin
end

---Call lua fn and fix float window UI
---@param cmd string
local fix_float_ui = function (cmd)
  vim.cmd(cmd)
  vim.defer_fn(function ()
    local key = vim.api.nvim_replace_termcodes(':echon <CR>', true, false, true)
    vim.api.nvim_feedkeys(key, 'n', false)
  end, 100)
end

--- Navigate left and right by n places in the bufferline
-- @param n the number of tabs to navigate to (positive = right, negative = left)
local nav_buf = function (n)
  local current = vim.api.nvim_get_current_buf()
  for i, v in ipairs(vim.t.bufs) do
    if current == v then
      vim.cmd.b(vim.t.bufs[(i + n - 1) % #vim.t.bufs + 1])
      break
    end
  end
end

--- Close a given buffer
-- @param bufnr? the buffer number to close or the current buffer if not provided
local close_buf = function (bufnr, force)
  if force == nil then force = false end
  local current = vim.api.nvim_get_current_buf()
  if not bufnr or bufnr == 0 then bufnr = current end
  if bufnr == current then nav_buf(-1) end

  if has_plugin 'bufdelete.nvim' then
    require('bufdelete').bufdelete(bufnr, force)
  else
    vim.cmd((force and 'bd!' or 'confirm bd') .. bufnr)
  end
end

local contains = function (t, key) return t[key] ~= nil end


local diagnostics_signs = {
  {
    name = 'DiagnosticSignError',
    text = ''
  },
  {
    name = 'DiagnosticSignWarn',
    text = ''
  },
  {
    name = 'DiagnosticSignHint',
    text = ''
  },
  {
    name = 'DiagnosticSignInfo',
    text = ''
  },
}

local keymap = {
  opts = {
    remap = false,
    silent = true,
  },
  map = vim.keymap.set,
}

function keymap:desc_opts(desc, bufnr)
  local result = { desc = desc }

  if bufnr ~= nil then
    result.buffer = bufnr
  end

  for key, val in pairs(self.opts) do
    result[key] = val
  end

  return result
end

--- Check if a buffer is valid
---@param bufnr number? The buffer to check, default to current buffer
---@return boolean # Whether the buffer is valid or not
local is_valid = function (bufnr)
  if not bufnr then bufnr = 0 end
  return vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted
end

local rainbow_highlights = {
  'RainbowDelimiterRed',
  'RainbowDelimiterYellow',
  'RainbowDelimiterBlue',
  'RainbowDelimiterOrange',
  'RainbowDelimiterGreen',
  'RainbowDelimiterViolet',
  'RainbowDelimiterCyan',
}

U.close_buf = close_buf
U.contains = contains
U.default_tbl = default_tbl
U.diagnostics_signs = diagnostics_signs
U.dump = dump
U.fix_float_ui = fix_float_ui
U.get_hlgroup = get_hlgroup
U.has_plugin = has_plugin
U.is_valid = is_valid
U.key_down = key_down
U.keymap = keymap
U.lualine_mode = lualine_mode
U.nav_buf = nav_buf
U.null_ls_providers = null_ls_providers
U.null_ls_register = null_ls_register
U.null_ls_sources = null_ls_sources
U.pad_string = pad_string
U.rainbow_highlights = rainbow_highlights

return U
