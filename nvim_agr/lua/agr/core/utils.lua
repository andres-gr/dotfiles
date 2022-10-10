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

local is_available = function (plugin)
  return packer_plugins ~= nil and packer_plugins[plugin] ~= nil
end

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
  local hl = vim.fn.hlexists(name) == 1 and vim.api.nvim_get_hl_by_name(name, vim.o.termguicolors) or {}
  return default_tbl(
    vim.o.termguicolors and { fg = hl.foreground, bg = hl.background, sp = hl.special }
      or { cterfm = hl.foreground, ctermbg = hl.background },
    fallback
  )
end

local lualine_mode = function (mode, fallback)
  local lualine_avail, lualine = pcall(require, 'lualine.themes.dracula-nvim')
  local lualine_opts = lualine_avail and lualine[mode]

  return lualine_opts and type(lualine_opts.a) == 'table' and lualine_opts.a.bg or fallback
end

U.default_tbl = default_tbl
U.dump = dump
U.get_hlgroup = get_hlgroup
U.is_available = is_available
U.key_down = key_down
U.lualine_mode = lualine_mode
U.null_ls_providers = null_ls_providers
U.null_ls_register = null_ls_register
U.null_ls_sources = null_ls_sources
U.pad_string = pad_string

return U

