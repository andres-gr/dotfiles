--- ### AstroNvim Status
--
-- This module is automatically loaded by AstroNvim on during it's initialization into global variable `astronvim.status`
--
-- This module can also be manually loaded with `local status = require 'core.utils.status'`
--
-- @module core.utils.status
-- @copyright 2022
-- @license GNU General Public License v3.0

local utils = require 'agr.core.utils'
local get_icon = require 'agr.astro.icons'.get_icon

local status = { hl = {}, init = {}, provider = {}, condition = {}, component = {}, utils = {}, env = {} }

status.env.modes = {
  ['n'] = { 'NORMAL', 'normal' },
  ['no'] = { 'OP', 'normal' },
  ['nov'] = { 'OP', 'normal' },
  ['noV'] = { 'OP', 'normal' },
  ['no'] = { 'OP', 'normal' },
  ['niI'] = { 'NORMAL', 'normal' },
  ['niR'] = { 'NORMAL', 'normal' },
  ['niV'] = { 'NORMAL', 'normal' },
  ['i'] = { 'INSERT', 'insert' },
  ['ic'] = { 'INSERT', 'insert' },
  ['ix'] = { 'INSERT', 'insert' },
  ['t'] = { 'TERM', 'terminal' },
  ['nt'] = { 'TERM', 'terminal' },
  ['v'] = { 'VISUAL', 'visual' },
  ['vs'] = { 'VISUAL', 'visual' },
  ['V'] = { 'LINES', 'visual' },
  ['Vs'] = { 'LINES', 'visual' },
  [''] = { 'BLOCK', 'visual' },
  ['s'] = { 'BLOCK', 'visual' },
  ['R'] = { 'REPLACE', 'replace' },
  ['Rc'] = { 'REPLACE', 'replace' },
  ['Rx'] = { 'REPLACE', 'replace' },
  ['Rv'] = { 'V-REPLACE', 'replace' },
  ['s'] = { 'SELECT', 'visual' },
  ['S'] = { 'SELECT', 'visual' },
  [''] = { 'BLOCK', 'visual' },
  ['c'] = { 'COMMAND', 'command' },
  ['cv'] = { 'COMMAND', 'command' },
  ['ce'] = { 'COMMAND', 'command' },
  ['r'] = { 'PROMPT', 'inactive' },
  ['rm'] = { 'MORE', 'inactive' },
  ['r?'] = { 'CONFIRM', 'inactive' },
  ['!'] = { 'SHELL', 'inactive' },
  ['null'] = { 'null', 'inactive' },
}

status.env.separators = {
  none = { '', '' },
  left = { '', '  ' },
  right = { '  ', '' },
  center = { '  ', '  ' },
  tab = { '', ' ' },
}

status.env.attributes = {
  buffer_active = { bold = true, italic = true },
  buffer_picker = { bold = true },
  macro_recording = { bold = true },
  git_branch = { bold = true },
  git_diff = { bold = true },
}

status.env.icon_highlights = {
  file_icon = {
    tabline = function (self) return self.is_active or self.is_visible end,
    statusline = true,
  },
}

local function pattern_match(str, pattern_list)
  for _, pattern in ipairs(pattern_list) do
    if str:find(pattern) then return true end
  end
  return false
end

status.env.buf_matchers = {
  filetype = function (pattern_list, bufnr) return pattern_match(vim.bo[bufnr or 0].filetype, pattern_list) end,
  buftype = function (pattern_list, bufnr) return pattern_match(vim.bo[bufnr or 0].buftype, pattern_list) end,
  bufname = function (pattern_list, bufnr)
    return pattern_match(vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr or 0), ':t'), pattern_list)
  end,
}

--- Get the highlight background color of the lualine theme for the current colorscheme
-- @param  mode the neovim mode to get the color of
-- @param  fallback the color to fallback on if a lualine theme is not present
-- @return The background color of the lualine theme or the fallback parameter if one doesn't exist
function status.hl.lualine_mode(mode, fallback)
  local lualine_avail, lualine = pcall(require, 'lualine.themes.dracula-nvim')
  local lualine_opts = lualine_avail and lualine[mode]
  return lualine_opts and type(lualine_opts.a) == 'table' and lualine_opts.a.bg or fallback
end

--- Get the highlight for the current mode
-- @return the highlight group for the current mode
-- @usage local heirline_component = { provider = 'Example Provider', hl = status.hl.mode },
function status.hl.mode() return { bg = status.hl.mode_bg() } end

--- Get the foreground color group for the current mode, good for usage with Heirline surround utility
-- @return the highlight group for the current mode foreground
-- @usage local heirline_component = require('heirline.utils').surround({ '|', '|' }, status.hl.mode_bg, heirline_component),

function status.hl.mode_bg() return status.env.modes[vim.fn.mode()][2] end

--- Get the foreground color group for the current filetype
-- @return the highlight group for the current filetype foreground
-- @usage local heirline_component = { provider = status.provider.fileicon(), hl = status.hl.filetype_color },
function status.hl.filetype_color(self)
  local devicons_avail, devicons = pcall(require, 'nvim-web-devicons')
  if not devicons_avail then return {} end
  local _, color = devicons.get_icon_color(
    vim.fn.fnamemodify(vim.api.nvim_buf_get_name(self and self.bufnr or 0), ':t'),
    nil,
    { default = true }
  )
  return { fg = color }
end

--- Merge the color and attributes from user settings for a given name
-- @param name string, the name of the element to get the attributes and colors for
-- @param include_bg boolean whether or not to include background color (Default: false)
-- @return a table of highlight information
-- @usage local heirline_component = { provider = 'Example Provider', hl = status.hl.get_attributes('treesitter') },
function status.hl.get_attributes(name, include_bg)
  local hl = status.env.attributes[name] or {}
  hl.fg = name .. '_fg'
  if include_bg then hl.bg = name .. '_bg' end
  return hl
end

--- Enable filetype color highlight if enabled in icon_highlights.file_icon options
-- @param name string of the icon_highlights.file_icon table element
-- @return function for setting hl property in a component
-- @usage local heirline_component = { provider = 'Example Provider', hl = status.hl.file_icon('winbar') },
function status.hl.file_icon(name)
  return function (self)
    local hl_enabled = status.env.icon_highlights.file_icon[name]
    if type(hl_enabled) == 'function' then hl_enabled = hl_enabled(self) end
    if hl_enabled then return status.hl.filetype_color(self) end
  end
end

--- An `init` function to build a set of children components for LSP breadcrumbs
-- @param opts options for configuring the breadcrumbs (default: `{ separator = ' > ', icon = { enabled = true, hl = false }, padding = { left = 0, right = 0 } }`)
-- @return The Heirline init function
-- @usage local heirline_component = { init = status.init.breadcrumbs { padding = { left = 1 } } }
function status.init.breadcrumbs(opts)
  opts = utils.default_tbl(opts, {
    separator = ' > ',
    icon = { enabled = true, hl = status.env.icon_highlights.breadcrumbs },
    padding = { left = 0, right = 0 },
  })
  return function (self)
    local data = require('aerial').get_location(true) or {}
    local children = {}
    -- create a child for each level
    for i, d in ipairs(data) do
      local pos = status.utils.encode_pos(d.lnum, d.col, self.winnr)
      local child = {
        { provider = string.gsub(d.name, '%%', '%%%%'):gsub('%s*->%s*', '') }, -- add symbol name
        on_click = { -- add on click function
          minwid = pos,
          callback = function (_, minwid)
            local lnum, col, winnr = status.utils.decode_pos(minwid)
            vim.api.nvim_win_set_cursor(vim.fn.win_getid(winnr), { lnum, col })
          end,
          name = 'heirline_breadcrumbs',
        },
      }
      if opts.icon.enabled then -- add icon and highlight if enabled
        local hl = opts.icon.hl
        if type(hl) == 'function' then hl = hl(self) end
        table.insert(child, 1, {
          provider = string.format('%s ', d.icon),
          hl = hl and string.format('Aerial%sIcon', d.kind) or nil,
        })
      end
      if #data > 1 and i < #data then table.insert(child, { provider = opts.separator }) end -- add a separator only if needed
      table.insert(children, child)
    end
    if opts.padding.left > 0 then -- add left padding
      table.insert(children, 1, { provider = utils.pad_string(' ', { left = opts.padding.left - 1 }) })
    end
    if opts.padding.right > 0 then -- add right padding
      table.insert(children, { provider = utils.pad_string(' ', { right = opts.padding.right - 1 }) })
    end
    -- instantiate the new child
    self[1] = self:new(children, 1)
  end
end

--- An `init` function to build multiple update events which is not supported yet by Heirline's update field
-- @param opts an array like table of autocmd events as either just a string or a table with custom patterns and callbacks.
-- @return The Heirline init function
-- @usage local heirline_component = { init = status.init.update_events { 'BufEnter', { 'User', pattern = 'LspProgressUpdate' } } }
function status.init.update_events(opts)
  return function (self)
    if not rawget(self, 'once') then
      local clear_cache = function () self._win_cache = nil end
      for _, event in ipairs(opts) do
        local event_opts = { callback = clear_cache }
        if type(event) == 'table' then
          event_opts.pattern = event.pattern
          event_opts.callback = event.callback or clear_cache
          event.pattern = nil
          event.callback = nil
        end
        vim.api.nvim_create_autocmd(event, event_opts)
      end
      self.once = true
    end
  end
end

--- A provider function for the fill string
-- @return the statusline string for filling the empty space
-- @usage local heirline_component = { provider = status.provider.fill }
function status.provider.fill() return '%=' end

--- A provider function for the current tab numbre
-- @return the statusline function to return a string for a tab number
-- @usage local heirline_component = { provider = status.provider.tabnr() }
function status.provider.tabnr()
  return function (self) return (self and self.tabnr) and '%' .. self.tabnr .. 'T ' .. self.tabnr .. ' %T' or '' end
end

--- A provider function for showing if spellcheck is on
-- @param opts options passed to the stylize function
-- @return the function for outputting if spell is enabled
-- @usage local heirline_component = { provider = status.provider.spell() }
-- @see status.utils.stylize
function status.provider.spell(opts)
  opts = utils.default_tbl(opts, { str = '', icon = { kind = 'Spellcheck' }, show_empty = true })
  return function () return status.utils.stylize(vim.wo.spell and opts.str, opts) end
end

--- A provider function for showing if paste is enabled
-- @param opts options passed to the stylize function
-- @return the function for outputting if paste is enabled

-- @usage local heirline_component = { provider = status.provider.paste() }
-- @see status.utils.stylize
function status.provider.paste(opts)
  opts = utils.default_tbl(opts, { str = '', icon = { kind = 'Paste' }, show_empty = true })
  return function () return status.utils.stylize(vim.opt.paste:get() and opts.str, opts) end
end

--- A provider function for displaying if a macro is currently being recorded
-- @param opts a prefix before the recording register and options passed to the stylize function
-- @return a function that returns a string of the current recording status
-- @usage local heirline_component = { provider = status.provider.macro_recording() }
-- @see status.utils.stylize
function status.provider.macro_recording(opts)
  opts = utils.default_tbl(opts, { prefix = '@' })
  return function ()
    local register = vim.fn.reg_recording()
    if register ~= '' then register = opts.prefix .. register end
    return status.utils.stylize(register, opts)
  end
end

--- A provider function for displaying the current search count
-- @param opts options for `vim.fn.searchcount` and options passed to the stylize function
-- @return a function that returns a string of the current search location
-- @usage local heirline_component = { provider = status.provider.search_count() }
-- @see status.utils.stylize
function status.provider.search_count(opts)
  local search_func = vim.tbl_isempty(opts or {}) and function () return vim.fn.searchcount() end
    or function () return vim.fn.searchcount(opts) end
  return function ()
    local search_ok, search = pcall(search_func)
    if search_ok and type(search) == 'table' and search.total then
      return status.utils.stylize(
        string.format(
          '%s%d/%s%d',
          search.current > search.maxcount and '>' or '',
          math.min(search.current, search.maxcount),
          search.incomplete == 2 and '>' or '',
          math.min(search.total, search.maxcount)
        ),
        opts
      )
    end
  end
end

--- A provider function for showing the text of the current vim mode
-- @param opts options for padding the text and options passed to the stylize function
-- @return the function for displaying the text of the current vim mode
-- @usage local heirline_component = { provider = status.provider.mode_text() }
-- @see status.utils.stylize
function status.provider.mode_text(opts)
  local max_length =
    math.max(table.unpack(vim.tbl_map(function (str) return #str[1] end, vim.tbl_values(status.env.modes))))
  return function ()
    local text = status.env.modes[vim.fn.mode()][1]
    if opts.pad_text then
      local padding = max_length - #text
      if opts.pad_text == 'right' then
        text = string.rep(' ', padding) .. text
      elseif opts.pad_text == 'left' then
        text = text .. string.rep(' ', padding)
      elseif opts.pad_text == 'center' then
        text = string.rep(' ', math.floor(padding / 2)) .. text .. string.rep(' ', math.ceil(padding / 2))
      end
    end
    return status.utils.stylize(text, opts)
  end
end

--- A provider function for showing the percentage of the current location in a document
-- @param opts options for Top/Bot text, fixed width, and options passed to the stylize function
-- @return the statusline string for displaying the percentage of current document location
-- @usage local heirline_component = { provider = status.provider.percentage() }
-- @see status.utils.stylize
function status.provider.percentage(opts)
  opts = utils.default_tbl(opts, { fixed_width = false, edge_text = true })
  return function ()
    local text = '%' .. (opts.fixed_width and '3' or '') .. 'p%%'
    if opts.edge_text then
      local current_line = vim.fn.line '.'
      if current_line == 1 then
        text = (opts.fixed_width and ' ' or '') .. 'Top'
      elseif current_line == vim.fn.line '$' then
        text = (opts.fixed_width and ' ' or '') .. 'Bot'
      end
    end
    return status.utils.stylize(text, opts)
  end
end

--- A provider function for showing the current line and character in a document
-- @param opts options for padding the line and character locations and options passed to the stylize function
-- @return the statusline string for showing location in document line_num:char_num
-- @usage local heirline_component = { provider = status.provider.ruler({ pad_ruler = { line = 3, char = 2 } }) }
-- @see status.utils.stylize
function status.provider.ruler(opts)
  opts = utils.default_tbl(opts, { pad_ruler = { line = 0, char = 0 } })
  local padding_str = string.format('%%%dd:%%%dd', opts.pad_ruler.line, opts.pad_ruler.char)
  return function ()
    local line = vim.fn.line '.'
    local char = vim.fn.virtcol '.'
    return status.utils.stylize(string.format(padding_str, line, char), opts)
  end
end

--- A provider function for showing the current location as a scrollbar
-- @param opts options passed to the stylize function
-- @return the function for outputting the scrollbar
-- @usage local heirline_component = { provider = status.provider.scrollbar() }
-- @see status.utils.stylize
function status.provider.scrollbar(opts)
  local sbar = { '▁', '▂', '▃', '▄', '▅', '▆', '▇', '█' }

  return function ()
    local curr_line = vim.api.nvim_win_get_cursor(0)[1]
		local lines = vim.api.nvim_buf_line_count(0)
    local i

    if lines > 0 then
      i = math.floor((curr_line - 1) / lines * #sbar) + 1
    else
      i = #sbar
    end

    return status.utils.stylize(string.rep(sbar[i], 2), opts)
  end
end

--- A provider to simply show a cloes button icon
-- @param opts options passed to the stylize function and the kind of icon to use
-- @return return the stylized icon
-- @usage local heirline_component = { provider = status.provider.close_button() }
-- @see status.utils.stylize
function status.provider.close_button(opts)
  opts = utils.default_tbl(opts, { kind = 'BufferClose' })
  return status.utils.stylize(get_icon(opts.kind), opts)
end

--- A provider function for showing the current filetype
-- @param opts options passed to the stylize function
-- @return the function for outputting the filetype
-- @usage local heirline_component = { provider = status.provider.filetype() }
-- @see status.utils.stylize
function status.provider.filetype(opts)
  return function (self)
    local buffer = vim.bo[self and self.bufnr or 0]
    return status.utils.stylize(string.lower(buffer.filetype), opts)
  end
end

--- A provider function for showing the current filename
-- @param opts options for argument to fnamemodify to format filename and options passed to the stylize function
-- @return the function for outputting the filename
-- @usage local heirline_component = { provider = status.provider.filename() }
-- @see status.utils.stylize
function status.provider.filename(opts)
  opts = utils.default_tbl(
    opts,
    { fallback = '[No Name]', fname = function (nr) return vim.api.nvim_buf_get_name(nr) end, modify = ':t' }
  )
  return function (self)
    local filename = vim.fn.fnamemodify(opts.fname(self and self.bufnr or 0), opts.modify)
    return status.utils.stylize((filename == '' and opts.fallback or filename), opts)
  end
end

--- Get a unique filepath between all buffers
-- @param opts options for function to get the buffer name, a buffer number, max length, and options passed to the stylize function
-- @return path to file that uniquely identifies each buffer
-- @usage local heirline_component = { provider = status.provider.unique_path() }
-- @see status.utils.stylize
function status.provider.unique_path(opts)
  opts = utils.default_tbl(opts, {
    buf_name = function (bufnr) return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':t') end,
    bufnr = 0,
    max_length = 16,
  })
  return function (self)
    opts.bufnr = self and self.bufnr or opts.bufnr
    local name = opts.buf_name(opts.bufnr)
    local unique_path = ''
    -- check for same buffer names under different dirs
    -- TODO v3: remove get_valid_buffers
    for _, value in ipairs(vim.g.heirline_bufferline and vim.t.bufs or status.utils.get_valid_buffers()) do
      if name == opts.buf_name(value) and value ~= opts.bufnr then
        local other = {}
        for match in (vim.api.nvim_buf_get_name(value) .. '/'):gmatch('(.-)' .. '/') do
          table.insert(other, match)
        end

        local current = {}
        for match in (vim.api.nvim_buf_get_name(opts.bufnr) .. '/'):gmatch('(.-)' .. '/') do
          table.insert(current, match)
        end

        unique_path = ''

        for i = #current - 1, 1, -1 do
          local value_current = current[i]
          local other_current = other[i]

          if value_current ~= other_current then
            unique_path = value_current .. '/'
            break
          end
        end
        break
      end
    end
    return status.utils.stylize(
      (
        opts.max_length > 0
        and #unique_path > opts.max_length
        and string.sub(unique_path, 1, opts.max_length - 2) .. get_icon 'Ellipsis' .. '/'
      ) or unique_path,
      opts
    )
  end
end

--- A provider function for showing if the current file is modifiable
-- @param opts options passed to the stylize function
-- @return the function for outputting the indicator if the file is modified
-- @usage local heirline_component = { provider = status.provider.file_modified() }
-- @see status.utils.stylize
function status.provider.file_modified(opts)
  opts = utils.default_tbl(opts, { str = '', icon = { kind = 'FileModified' }, show_empty = true })
  return function (self)
    return status.utils.stylize(
      status.condition.file_modified((self or {}).bufnr) and opts.str,
      opts
    )
  end
end

--- A provider function for showing if the current file is read-only
-- @param opts options passed to the stylize function
-- @return the function for outputting the indicator if the file is read-only
-- @usage local heirline_component = { provider = status.provider.file_read_only() }
-- @see status.utils.stylize
function status.provider.file_read_only(opts)
  opts = utils.default_tbl(opts, { str = '', icon = { kind = 'FileReadOnly' }, show_empty = true })
  return function (self)
    return status.utils.stylize(
      status.condition.file_read_only((self or {}).bufnr) and opts.str,
      opts
    )
  end
end

--- A provider function for showing the current filetype icon
-- @param opts options passed to the stylize function
-- @return the function for outputting the filetype icon
-- @usage local heirline_component = { provider = status.provider.file_icon() }
-- @see status.utils.stylize
function status.provider.file_icon(opts)
  return function (self)
    local devicons_avail, devicons = pcall(require, 'nvim-web-devicons')
    if not devicons_avail then return '' end
    local ft_icon, _ = devicons.get_icon(
      vim.fn.fnamemodify(vim.api.nvim_buf_get_name(self and self.bufnr or 0), ':t'),
      nil,
      { default = true }
    )
    return status.utils.stylize(ft_icon, opts)
  end
end

--- A provider function for showing the current git branch
-- @param opts options passed to the stylize function
-- @return the function for outputting the git branch
-- @usage local heirline_component = { provider = status.provider.git_branch() }
-- @see status.utils.stylize
function status.provider.git_branch(opts)
  return function (self) return status.utils.stylize(vim.b[self and self.bufnr or 0].gitsigns_head or '', opts) end
end

--- A provider function for showing the current git diff count of a specific type
-- @param opts options for type of git diff and options passed to the stylize function
-- @return the function for outputting the git diff
-- @usage local heirline_component = { provider = status.provider.git_diff({ type = 'added' }) }
-- @see status.utils.stylize
function status.provider.git_diff(opts)
  if not opts or not opts.type then return end
  return function (self)
    local stat = vim.b[self and self.bufnr or 0].gitsigns_status_dict
    return status.utils.stylize(
      stat and stat[opts.type] and stat[opts.type] > 0 and tostring(stat[opts.type]) or '',
      opts
    )
  end
end

--- A provider function for showing the current diagnostic count of a specific severity
-- @param opts options for severity of diagnostic and options passed to the stylize function
-- @return the function for outputting the diagnostic count
-- @usage local heirline_component = { provider = status.provider.diagnostics({ severity = 'ERROR' }) }
-- @see status.utils.stylize
function status.provider.diagnostics(opts)
  if not opts or not opts.severity then return end
  return function (self)
    local bufnr = self and self.bufnr or 0
    local count = #vim.diagnostic.get(bufnr, opts.severity and { severity = vim.diagnostic.severity[opts.severity] })
    return status.utils.stylize(count ~= 0 and tostring(count) or '', opts)
  end
end

--- A provider function for showing the current progress of loading language servers
-- @param opts options passed to the stylize function
-- @return the function for outputting the LSP progress
-- @usage local heirline_component = { provider = status.provider.lsp_progress() }
-- @see status.utils.stylize
function status.provider.lsp_progress(opts)
  return function ()
    local Lsp = vim.lsp.status()
    return status.utils.stylize(Lsp, opts)
  end
end

--- A provider function for showing the connected LSP client names
-- @param opts options for explanding null_ls clients, max width percentage, and options passed to the stylize function
-- @return the function for outputting the LSP client names
-- @usage local heirline_component = { provider = status.provider.lsp_client_names({ expand_null_ls = true, truncate = 0.25 }) }
-- @see status.utils.stylize
function status.provider.lsp_client_names(opts)
  opts = utils.default_tbl(opts, { expand_null_ls = true, truncate = 0.25 })
  return function (self)
    local buf_client_names = {}
    for _, client in pairs(vim.lsp.get_active_clients { bufnr = self and self.bufnr or 0 }) do
      if client.name == 'null-ls' and opts.expand_null_ls then
        local null_ls_sources = {}
        for _, type in ipairs { 'FORMATTING', 'DIAGNOSTICS' } do
          for _, source in ipairs(utils.null_ls_sources(vim.bo.filetype, type)) do
            null_ls_sources[source] = true
          end
        end
        vim.list_extend(buf_client_names, vim.tbl_keys(null_ls_sources))
      else
        table.insert(buf_client_names, client.name)
      end
    end
    local str = table.concat(buf_client_names, ', ')
    if type(opts.truncate) == 'number' then
      local max_width = math.floor(status.utils.width() * opts.truncate)
      if #str > max_width then str = string.sub(str, 0, max_width) .. '…' end
    end
    return status.utils.stylize(str, opts)
  end
end

--- A provider function for showing if treesitter is connected
-- @param opts options passed to the stylize function
-- @return the function for outputting TS if treesitter is connected
-- @usage local heirline_component = { provider = status.provider.treesitter_status() }
-- @see status.utils.stylize
function status.provider.treesitter_status(opts)
  return function ()
    return status.utils.stylize(require('nvim-treesitter.parser').has_parser() and 'TS' or '', opts)
  end
end

--- A provider function for displaying a single string
-- @param opts options passed to the stylize function
-- @return the stylized statusline string
-- @usage local heirline_component = { provider = status.provider.str({ str = 'Hello' }) }
-- @see status.utils.stylize
function status.provider.str(opts)
  opts = utils.default_tbl(opts, { str = ' ' })
  return status.utils.stylize(opts.str, opts)
end

--- A condition function if the window is currently active
-- @return boolean of wether or not the window is currently actie
-- @usage local heirline_component = { provider = 'Example Provider', condition = status.condition.is_active }
function status.condition.is_active() return vim.api.nvim_get_current_win() == tonumber(vim.g.actual_curwin) end

--- A condition function if the buffer filetype,buftype,bufname match a pattern
-- @param patterns the table of patterns to match
-- @param bufnr number of the buffer to match (Default: 0 [current])
-- @return boolean of wether or not LSP is attached
-- @usage local heirline_component = { provider = 'Example Provider', condition = function () return status.condition.buffer_matches { buftype = { 'terminal' } } end }
function status.condition.buffer_matches(patterns, bufnr)
  for kind, pattern_list in pairs(patterns) do
    if status.env.buf_matchers[kind](pattern_list, bufnr) then return true end
  end
  return false
end

--- A condition function if a macro is being recorded
-- @return boolean of wether or not a macro is currently being recorded
-- @usage local heirline_component = { provider = 'Example Provider', condition = status.condition.is_macro_recording }
function status.condition.is_macro_recording() return vim.fn.reg_recording() ~= '' end

--- A condition function if search is visible
-- @return boolean of wether or not searching is currently visible
-- @usage local heirline_component = { provider = 'Example Provider', condition = status.condition.is_hlsearch }
function status.condition.is_hlsearch() return vim.v.hlsearch ~= 0 end

--- A condition function if the current file is in a git repo
-- @param bufnr a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer
-- @return boolean of wether or not the current file is in a git repo
-- @usage local heirline_component = { provider = 'Example Provider', condition = status.condition.is_git_repo }
function status.condition.is_git_repo(bufnr)
  if type(bufnr) == 'table' then bufnr = bufnr.bufnr end
  return vim.b[bufnr or 0].gitsigns_head or vim.b[bufnr or 0].gitsigns_status_dict
end

--- A condition function if there are any git changes
-- @param bufnr a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer
-- @return boolean of wether or not there are any git changes
-- @usage local heirline_component = { provider = 'Example Provider', condition = status.condition.git_changed }
function status.condition.git_changed(bufnr)
  if type(bufnr) == 'table' then bufnr = bufnr.bufnr end
  local git_status = vim.b[bufnr or 0].gitsigns_status_dict
  return git_status and (git_status.added or 0) + (git_status.removed or 0) + (git_status.changed or 0) > 0
end

--- A condition function if the current buffer is modified
-- @param bufnr a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer
-- @return boolean of wether or not the current buffer is modified
-- @usage local heirline_component = { provider = 'Example Provider', condition = status.condition.file_modified }
function status.condition.file_modified(bufnr)
  if type(bufnr) == 'table' then bufnr = bufnr.bufnr end
  return vim.bo[bufnr or 0].modified
end

--- A condition function if the current buffer is read only
-- @param bufnr a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer
-- @return boolean of wether or not the current buffer is read only or not modifiable
-- @usage local heirline_component = { provider = 'Example Provider', condition = status.condition.file_read_only }
function status.condition.file_read_only(bufnr)
  if type(bufnr) == 'table' then bufnr = bufnr.bufnr end
  local buffer = vim.bo[bufnr or 0]
  return not buffer.modifiable or buffer.readonly
end

--- A condition function if the current file has any diagnostics
-- @param bufnr a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer
-- @return boolean of wether or not the current file has any diagnostics
-- @usage local heirline_component = { provider = 'Example Provider', condition = status.condition.has_diagnostics }
function status.condition.has_diagnostics(bufnr)
  if type(bufnr) == 'table' then bufnr = bufnr.bufnr end
  return vim.g.status_diagnostics_enabled and #vim.diagnostic.get(bufnr or 0) > 0
end

--- A condition function if there is a defined filetype
-- @param bufnr a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer
-- @return boolean of wether or not there is a filetype
-- @usage local heirline_component = { provider = 'Example Provider', condition = status.condition.has_filetype }
function status.condition.has_filetype(bufnr)
  if type(bufnr) == 'table' then bufnr = bufnr.bufnr end
  return vim.fn.empty(vim.fn.expand '%:t') ~= 1 and vim.bo[bufnr or 0].filetype and vim.bo[bufnr or 0].filetype ~= ''
end

--- A condition function if Aerial is available
-- @return boolean of wether or not aerial plugin is installed
-- @usage local heirline_component = { provider = 'Example Provider', condition = status.condition.aerial_available }
-- function status.condition.aerial_available() return is_available 'aerial.nvim' end
function status.condition.aerial_available() return package.loaded['aerial'] end

--- A condition function if LSP is attached
-- @param bufnr a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer
-- @return boolean of wether or not LSP is attached
-- @usage local heirline_component = { provider = 'Example Provider', condition = status.condition.lsp_attached }
function status.condition.lsp_attached(bufnr)
  if type(bufnr) == 'table' then bufnr = bufnr.bufnr end
  return next(vim.lsp.get_active_clients { bufnr = bufnr or 0 }) ~= nil
end

--- A condition function if treesitter is in use
-- @param bufnr a buffer number to check the condition for, a table with bufnr property, or nil to get the current buffer
-- @return boolean of wether or not treesitter is active
-- @usage local heirline_component = { provider = 'Example Provider', condition = status.condition.treesitter_available }
function status.condition.treesitter_available(bufnr)
  if not package.loaded['nvim-treesitter'] then return false end
  if type(bufnr) == 'table' then bufnr = bufnr.bufnr end
  local parsers = require 'nvim-treesitter.parsers'
  return parsers.has_parser(parsers.get_buf_lang(bufnr or vim.api.nvim_get_current_buf()))
end

--- A utility function to stylize a string with an icon from lspkind, separators, and left/right padding
-- @param str the string to stylize
-- @param opts options of `{ padding = { left = 0, right = 0 }, separator = { left = '|', right = '|' }, show_empty = false, icon = { kind = 'NONE', padding = { left = 0, right = 0 } } }`
-- @return the stylized string
-- @usage local string = status.utils.stylize('Hello', { padding = { left = 1, right = 1 }, icon = { kind = 'String' } })
function status.utils.stylize(str, opts)
  opts = utils.default_tbl(opts, {
    padding = { left = 0, right = 0 },
    separator = { left = '', right = '' },
    show_empty = false,
    icon = { kind = 'NONE', padding = { left = 0, right = 0 } },
  })
  local icon = utils.pad_string(get_icon(opts.icon.kind), opts.icon.padding)
  return str
      and (str ~= '' or opts.show_empty)
      and opts.separator.left .. utils.pad_string(icon .. str, opts.padding) .. opts.separator.right
    or ''
end

--- A Heirline component for filling in the empty space of the bar
-- @param opts options for configuring the other fields of the heirline component
-- @return The heirline component table
-- @usage local heirline_component = status.component.fill()
function status.component.fill(opts)
  return utils.default_tbl(opts, { provider = status.provider.fill() })
end

--- A function to build a set of children components for an entire file information section
-- @param opts options for configuring file_icon, filename, filetype, file_modified, file_read_only, and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = status.component.file_info()
function status.component.file_info(opts)
  opts = utils.default_tbl(opts, {
    file_icon = {
      hl = status.hl.file_icon 'statusline',
      padding = { left = 1, right = 1 },
    }, -- TODO: REWORK THIS
    filename = {},
    file_modified = { padding = { left = 1 } },
    file_read_only = { padding = { left = 1 } },
    surround = { separator = 'left', color = 'file_info_bg', condition = status.condition.has_filetype },
    hl = status.hl.get_attributes 'file_info',
  })
  return status.component.builder(status.utils.setup_providers(opts, {
    'file_icon',
    'unique_path',
    'filename',
    'filetype',
    'file_modified',
    'file_read_only',
    'close_button',
  }))
end

--- A function with different file_info defaults specifically for use in the tabline
-- @param opts options for configuring file_icon, filename, filetype, file_modified, file_read_only, and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = status.component.tabline_file_info()
function status.component.tabline_file_info(opts)
  return status.component.file_info(utils.default_tbl(opts, {
    file_icon = {
      condition = function (self) return not self._show_picker end,
      hl = status.hl.file_icon 'tabline',
    },
    unique_path = {
      hl = function (self) return status.hl.get_attributes(self.tab_type .. '_path') end,
    },
    close_button = {
      hl = function (self) return status.hl.get_attributes(self.tab_type .. '_close') end,
      padding = { left = 1, right = 1 },
      on_click = {
        callback = function (_, minwid) utils.close_buf(minwid) end,
        minwid = function (self) return self.bufnr end,
        name = 'heirline_tabline_close_buffer_callback',
      },
    },
    padding = { left = 1, right = 1 },
    hl = function (self)
      local tab_type = self.tab_type
      if self._show_picker and self.tab_type ~= 'buffer_active' then tab_type = 'buffer_visible' end
      return status.hl.get_attributes(tab_type)
    end,
    surround = false,
  }))
end

--- A function to build a set of children components for an entire navigation section
-- @param opts options for configuring ruler, percentage, scrollbar, and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = status.component.nav()
function status.component.nav(opts)
  opts = utils.default_tbl(opts, {
    ruler = {},
    percentage = { padding = { left = 1 } },
    scrollbar = { padding = { left = 1 }, hl = { fg = 'scrollbar' } },
    surround = { separator = 'right', color = 'nav_bg' },
    hl = status.hl.get_attributes 'nav',
    update = { 'CursorMoved', 'BufEnter' },
  })
  return status.component.builder(
    status.utils.setup_providers(opts, { 'ruler', 'percentage', 'scrollbar' })
  )
end

--- A function to build a set of children components for a macro recording section
-- @param opts options for configuring macro recording and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = status.component.macro_recording()
-- TODO: deprecate on next major version release
function status.component.macro_recording(opts)
  opts = utils.default_tbl(opts, {
    macro_recording = { icon = { kind = 'MacroRecording', padding = { right = 1 } } },
    surround = {
      separator = 'center',
      color = 'macro_recording_bg',
      condition = status.condition.is_macro_recording,
    },
    hl = status.hl.get_attributes 'macro_recording',
    update = { 'RecordingEnter', 'RecordingLeave' },
  })
  return status.component.builder(status.utils.setup_providers(opts, { 'macro_recording' }))
end

--- A function to build a set of children components for information shown in the cmdline
-- @param opts options for configuring macro recording, search count, and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = status.component.cmd_info()
function status.component.cmd_info(opts)
  opts = utils.default_tbl(opts, {
    macro_recording = {
      icon = { kind = 'MacroRecording', padding = { right = 1 } },
      condition = status.condition.is_macro_recording,
      update = { 'RecordingEnter', 'RecordingLeave' },
    },
    search_count = {
      icon = { kind = 'Search', padding = { right = 1 } },
      padding = { left = 1 },
      condition = status.condition.is_hlsearch,
    },
    surround = {
      separator = 'center',
      color = 'cmd_info_bg',
      condition = function ()
        return status.condition.is_hlsearch() or status.condition.is_macro_recording()
      end,
    },
    ---@diagnostic disable-next-line: undefined-field
    condition = function () return vim.opt.cmdheight:get() == 0 end,
    hl = status.hl.get_attributes 'cmd_info',
  })
  return status.component.builder(
    status.utils.setup_providers(opts, { 'macro_recording', 'search_count' })
  )
end

--- A function to build a set of children components for a mode section
-- @param opts options for configuring mode_text, paste, spell, and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = status.component.mode { mode_text = true }
function status.component.mode(opts)
  opts = utils.default_tbl(opts, {
    init = function (self)
      self.mode = vim.fn.mode(1) -- :h mode()

      -- execute this only once, this is required if you want the ViMode
      -- component to be updated on operator pending mode
      if not self.once then
        vim.api.nvim_create_autocmd('ModeChanged', {
          pattern = '*:*o',
          command = 'redrawstatus'
        })
        self.once = true
      end
    end,
    mode_text = false,
    paste = false,
    spell = false,
    surround = { separator = 'left', color = status.hl.mode_bg },
    hl = status.hl.get_attributes 'mode',
    update = 'ModeChanged',
  })
  if not opts['mode_text'] then opts.str = { str = ' ' } end
  return status.component.builder(
    status.utils.setup_providers(opts, { 'mode_text', 'str', 'paste', 'spell' })
  )
end

--- A function to build a set of children components for an LSP breadcrumbs section
-- @param opts options for configuring breadcrumbs and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = status.component.breadcumbs()
function status.component.breadcrumbs(opts)
  opts = utils.default_tbl(
    opts,
    { padding = { left = 1 }, condition = status.condition.aerial_available, update = 'CursorMoved' }
  )
  opts.init = status.init.breadcrumbs(opts)
  return opts
end

--- A function to build a set of children components for a git branch section
-- @param opts options for configuring git branch and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = status.component.git_branch()
function status.component.git_branch(opts)
  opts = utils.default_tbl(opts, {
    git_branch = { icon = { kind = 'GitBranch', padding = { right = 1 } } },
    surround = { separator = 'left', color = 'git_branch_bg', condition = status.condition.is_git_repo },
    hl = status.hl.get_attributes 'git_branch',
    on_click = {
      name = 'heirline_branch',
      callback = function ()
        if utils.has_plugin 'telescope.nvim' then
          vim.defer_fn(function () require('telescope.builtin').git_branches() end, 100)
        end
      end,
    },
    update = { 'User', pattern = 'GitSignsUpdate' },
    init = status.init.update_events { 'BufEnter' },
  })
  return status.component.builder(status.utils.setup_providers(opts, { 'git_branch' }))
end

--- A function to build a set of children components for a git difference section
-- @param opts options for configuring git changes and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = status.component.git_diff()
function status.component.git_diff(opts)
  opts = utils.default_tbl(opts, {
    added = { icon = { kind = 'GitAdd', padding = { left = 1, right = 1 } } },
    changed = { icon = { kind = 'GitChange', padding = { left = 1, right = 1 } } },
    removed = { icon = { kind = 'GitDelete', padding = { left = 1, right = 1 } } },
    hl = status.hl.get_attributes 'git_diff',
    on_click = {
      name = 'heirline_git',
      callback = function ()
        if utils.has_plugin 'telescope.nvim' then
          vim.defer_fn(function () require('telescope.builtin').git_status() end, 100)
        end
      end,
    },
    surround = { separator = 'left', color = 'git_diff_bg', condition = status.condition.git_changed },
    update = { 'User', pattern = 'GitSignsUpdate' },
    init = status.init.update_events { 'BufEnter' },
  })
  return status.component.builder(
    status.utils.setup_providers(opts, { 'added', 'changed', 'removed' }, function (p_opts, provider)
      local out = status.utils.build_provider(p_opts, provider)
      if out then
        out.provider = 'git_diff'
        out.opts.type = provider
        if out.hl == nil then out.hl = { fg = 'git_' .. provider } end
      end
      return out
    end)
  )
end

--- A function to build a set of children components for a diagnostics section
-- @param opts options for configuring diagnostic providers and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = status.component.diagnostics()
function status.component.diagnostics(opts)
  opts = utils.default_tbl(opts, {
    ERROR = { icon = { kind = 'DiagnosticError', padding = { left = 1, right = 1 } } },
    WARN = { icon = { kind = 'DiagnosticWarn', padding = { left = 1, right = 1 } } },
    INFO = { icon = { kind = 'DiagnosticInfo', padding = { left = 1, right = 1 } } },
    HINT = { icon = { kind = 'DiagnosticHint', padding = { left = 1, right = 1 } } },
    surround = { separator = 'left', color = 'diagnostics_bg', condition = status.condition.has_diagnostics },
    hl = status.hl.get_attributes 'diagnostics',
    on_click = {
      name = 'heirline_diagnostic',
      callback = function ()
        if utils.has_plugin 'telescope.nvim' then
          vim.defer_fn(function () require('telescope.builtin').diagnostics() end, 100)
        end
      end,
    },
    update = { 'DiagnosticChanged', 'BufEnter' },
  })
  return status.component.builder(
    status.utils.setup_providers(opts, { 'ERROR', 'WARN', 'INFO', 'HINT' }, function (p_opts, provider)
      local out = status.utils.build_provider(p_opts, provider)
      if out then
        out.provider = 'diagnostics'
        out.opts.severity = provider
        if out.hl == nil then out.hl = { fg = 'diag_' .. provider } end
      end
      return out
    end)
  )
end

--- A function to build a set of children components for a Treesitter section
-- @param opts options for configuring diagnostic providers and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = status.component.treesitter()
function status.component.treesitter(opts)
  opts = utils.default_tbl(opts, {
    str = { str = ' TS', icon = { kind = 'ActiveTS' } },
    surround = {
      separator = 'right',
      color = 'treesitter_bg',
      condition = status.condition.treesitter_available,
    },
    hl = status.hl.get_attributes 'treesitter',
    update = { 'OptionSet', pattern = 'syntax' },
    init = status.init.update_events { 'BufEnter' },
  })
  return status.component.builder(status.utils.setup_providers(opts, { 'str' }))
end

--- A function to build a set of children components for an LSP section
-- @param opts options for configuring lsp progress and client_name providers and the overall padding
-- @return The Heirline component table
-- @usage local heirline_component = status.component.lsp()
function status.component.lsp(opts)
  opts = utils.default_tbl(opts, {
    lsp_progress = {
      str = '',
      padding = { right = 1 },
      update = { 'User', pattern = { 'LspProgressUpdate', 'LspRequest' } },
    },
    lsp_client_names = {
      str = 'LSP',
      update = { 'LspAttach', 'LspDetach', 'BufEnter' },
      icon = { kind = 'ActiveLSP', padding = { right = 2 } },
    },
    hl = status.hl.get_attributes 'lsp',
    surround = { separator = 'right', color = 'lsp_bg', condition = status.condition.lsp_attached },
    on_click = {
      name = 'heirline_lsp',
      callback = function ()
        vim.defer_fn(function () pcall(vim.cmd.LspInfo) end, 100)
      end,
    },
  })
  return status.component.builder(
    status.utils.setup_providers(
      opts,
      { 'lsp_progress', 'lsp_client_names' },
      function (p_opts, provider, i)
        return p_opts
            and {
              flexible = i,
              status.utils.build_provider(p_opts, status.provider[provider](p_opts)),
              status.utils.build_provider(p_opts, status.provider.str(p_opts)),
            }
          or false
      end
    )
  )
end

--- A general function to build a section of status providers with highlights, conditions, and section surrounding
-- @param opts a list of components to build into a section
-- @return The Heirline component table
-- @usage local heirline_component = status.components.builder({ { provider = 'file_icon', opts = { padding = { right = 1 } } }, { provider = 'filename' } })
function status.component.builder(opts)
  opts = utils.default_tbl(opts, { padding = { left = 0, right = 0 } })
  local children = {}
  if opts.padding.left > 0 then -- add left padding
    table.insert(children, { provider = utils.pad_string(' ', { left = opts.padding.left - 1 }) })
  end
  for key, entry in pairs(opts) do
    if
      type(key) == 'number'
      and type(entry) == 'table'
      and status.provider[entry.provider]
      and (entry.opts == nil or type(entry.opts) == 'table')
    then
      entry.provider = status.provider[entry.provider](entry.opts)
    end
    children[key] = entry
  end
  if opts.padding.right > 0 then -- add right padding
    table.insert(children, { provider = utils.pad_string(' ', { right = opts.padding.right - 1 }) })
  end
  return opts.surround
      and status.utils.surround(
        opts.surround.separator,
        opts.surround.color,
        children,
        opts.surround.condition
      )
    or children
end

--- Convert a component parameter table to a table that can be used with the component builder
-- @param opts a table of provider options
-- @param provider a provider in `status.providers`
-- @return the provider table that can be used in `status.component.builder`
function status.utils.build_provider(opts, provider, _)
  return opts
      and {
        provider = provider,
        opts = opts,
        condition = opts.condition,
        on_click = opts.on_click,
        update = opts.update,
        hl = opts.hl,
      }
    or false
end

--- Convert key/value table of options to an array of providers for the component builder
-- @param opts the table of options for the components
-- @param providers an ordered list like array of providers that are configured in the options table
-- @param setup a function that takes provider options table, provider name, provider index and returns the setup provider table, optional, default is `status.utils.build_provider`
-- @return the fully setup options table with the appropriately ordered providers
function status.utils.setup_providers(opts, providers, setup)
  setup = setup or status.utils.build_provider
  for i, provider in ipairs(providers) do
    opts[i] = setup(opts[provider], provider, i)
  end
  return opts
end

--- A utility function to get the width of the bar
-- @param is_winbar boolean true if you want the width of the winbar, false if you want the statusline width
-- @return the width of the specified bar
function status.utils.width(is_winbar)
  return vim.o.laststatus == 3 and not is_winbar and vim.o.columns or vim.api.nvim_win_get_width(0)
end

--- Surround component with separator and color adjustment
-- @param separator the separator index to use in `status.env.separators`
-- @param color the color to use as the separator foreground/component background
-- @param component the component to surround
-- @param condition the condition for displaying the surrounded component
-- @return the new surrounded component
function status.utils.surround(separator, color, component, condition)
  local function surround_color(self)
    local colors = type(color) == 'function' and color(self) or color
    return type(colors) == 'string' and { main = colors } or colors
  end

  separator = type(separator) == 'string' and status.env.separators[separator] or separator
  local surrounded = { condition = condition }
  if separator[1] ~= '' then
    table.insert(surrounded, {
      provider = separator[1],
      hl = function (self)
        local s_color = surround_color(self)
        if s_color then return { fg = s_color.main, bg = s_color.left } end
      end,
    })
  end
  table.insert(surrounded, {
    hl = function (self)
      local s_color = surround_color(self)
      if s_color then return { bg = s_color.main } end
    end,
    utils.default_tbl({}, component),
  })
  if separator[2] ~= '' then
    table.insert(surrounded, {
      provider = separator[2],
      hl = function (self)
        local s_color = surround_color(self)
        if s_color then return { fg = s_color.main, bg = s_color.right } end
      end,
    })
  end
  return surrounded
end

--- Check if a buffer is valid
-- @param bufnr the buffer to check
-- @return true if the buffer is valid or false
function status.utils.is_valid_buffer(bufnr) -- TODO v3: remove this function
  if not bufnr or bufnr < 1 then return false end
  return vim.bo[bufnr].buflisted and vim.api.nvim_buf_is_valid(bufnr)
end

--- Get all valid buffers
-- @return array-like table of valid buffer numbers
function status.utils.get_valid_buffers() -- TODO v3: remove this function
  return vim.tbl_filter(status.utils.is_valid_buffer, vim.api.nvim_list_bufs())
end

--- Encode a position to a single value that can be decoded later
-- @param line line number of position
-- @param col column number of position
-- @param winnr a window number
-- @return the encoded position
function status.utils.encode_pos(line, col, winnr)
  return bit.bor(bit.lshift(line, 16), bit.lshift(col, 6), winnr)
end

--- Decode a previously encoded position to it's sub parts
-- @param c the encoded position
-- @return line number, column number, window id
function status.utils.decode_pos(c)
  return bit.rshift(c, 16), bit.band(bit.rshift(c, 6), 1023), bit.band(c, 63)
end

return status
