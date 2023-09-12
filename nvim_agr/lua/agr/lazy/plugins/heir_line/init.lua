local H = {
  'rebelot/heirline.nvim',
  event = 'BufEnter',
}

H.config = function ()
  local heirline = require 'heirline'
  local conditions = require 'heirline.conditions'
  local C = require 'agr.core.colors'
  local utils = require 'agr.core.utils'
  local status = require 'agr.astro.status'
  local vimode = require 'agr.lazy.plugins.heir_line.vimode'.setup()
  local diagnostics = require 'agr.lazy.plugins.heir_line.diagnostics'.setup()

  local setup_colors = function ()
    local Normal = utils.get_hlgroup('Normal', { fg = C.fg, bg = C.bg })
    local Comment = utils.get_hlgroup('Comment', { fg = C.grey_2, bg = C.bg })
    local Error = utils.get_hlgroup('Error', { fg = C.red, bg = C.bg })
    local StatusLine = utils.get_hlgroup('StatusLine', { fg = C.fg, bg = C.grey_4 })
    local TabLine = utils.get_hlgroup('TabLine', { fg = C.grey, bg = C.none })
    local TabLineSel = utils.get_hlgroup('TabLineSel', { fg = C.fg, bg = C.none })
    local WinBar = utils.get_hlgroup('WinBar', { fg = C.grey_2, bg = C.bg })
    local WinBarNC = utils.get_hlgroup('WinBarNC', { fg = C.grey, bg = C.bg })
    local Conditional = utils.get_hlgroup('Conditional', { fg = C.purple_1, bg = C.grey_4 })
    local String = utils.get_hlgroup('String', { fg = C.green, bg = C.grey_4 })
    local TypeDef = utils.get_hlgroup('TypeDef', { fg = C.yellow, bg = C.grey_4 })
    local GitSignsAdd = utils.get_hlgroup('GitSignsAdd', { fg = C.green, bg = C.grey_4 })
    local GitSignsChange = utils.get_hlgroup('GitSignsChange', { fg = C.orange_1, bg = C.grey_4 })
    local GitSignsDelete = utils.get_hlgroup('GitSignsDelete', { fg = C.red_1, bg = C.grey_4 })
    local DiagnosticError = utils.get_hlgroup('DiagnosticError', { fg = C.red_1, bg = C.grey_4 })
    local DiagnosticWarn = utils.get_hlgroup('DiagnosticWarn', { fg = C.orange_1, bg = C.grey_4 })
    local DiagnosticInfo = utils.get_hlgroup('DiagnosticInfo', { fg = C.white_2, bg = C.grey_4 })
    local DiagnosticHint = utils.get_hlgroup('DiagnosticHint', { fg = C.yellow_1, bg = C.grey_4 })
    local HeirlineInactive = utils.get_hlgroup('HeirlineInactive', { fg = nil }).fg or status.hl.lualine_mode('inactive', C.grey_7)
    local HeirlineNormal = utils.get_hlgroup('HeirlineNormal', { fg = nil }).fg or status.hl.lualine_mode('normal', C.blue)
    local HeirlineInsert = utils.get_hlgroup('HeirlineInsert', { fg = nil }).fg or status.hl.lualine_mode('insert', C.green)
    local HeirlineVisual = utils.get_hlgroup('HeirlineVisual', { fg = nil }).fg or status.hl.lualine_mode('visual', C.purple)
    local HeirlineReplace = utils.get_hlgroup('HeirlineReplace', { fg = nil }).fg or status.hl.lualine_mode('replace', C.red_1)
    local HeirlineCommand = utils.get_hlgroup('HeirlineCommand', { fg = nil }).fg or status.hl.lualine_mode('command', C.yellow_1)
    local HeirlineTerminal = utils.get_hlgroup('HeirlineTerminal', { fg = nil }).fg or status.hl.lualine_mode('inactive', HeirlineInsert)

    local colors = {
      close_fg = Error.fg,
      fg = StatusLine.fg,
      bg = StatusLine.bg,
      section_fg = StatusLine.fg,
      section_bg = StatusLine.bg,
      git_branch_fg = Conditional.fg,
      mode_fg = StatusLine.bg,
      treesitter_fg = String.fg,
      scrollbar = TypeDef.fg,
      git_added = GitSignsAdd.fg,
      git_changed = GitSignsChange.fg,
      git_removed = GitSignsDelete.fg,
      diag_ERROR = DiagnosticError.fg,
      diag_WARN = DiagnosticWarn.fg,
      diag_INFO = DiagnosticInfo.fg,
      diag_HINT = DiagnosticHint.fg,
      winbar_fg = WinBar.fg,
      winbar_bg = WinBar.bg,
      winbarnc_fg = WinBarNC.fg,
      winbarnc_bg = WinBarNC.bg,
      tabline_bg = StatusLine.bg,
      tabline_fg = StatusLine.bg,
      buffer_fg = Comment.fg,
      buffer_path_fg = WinBarNC.fg,
      buffer_close_fg = Comment.fg,
      buffer_bg = StatusLine.bg,
      buffer_active_fg = Normal.fg,
      buffer_active_path_fg = WinBarNC.fg,
      buffer_active_close_fg = Error.fg,
      buffer_active_bg = Normal.bg,
      buffer_visible_fg = Normal.fg,
      buffer_visible_path_fg = WinBarNC.fg,
      buffer_visible_close_fg = Error.fg,
      buffer_visible_bg = Normal.bg,
      buffer_overflow_fg = Comment.fg,
      buffer_overflow_bg = StatusLine.bg,
      buffer_picker_fg = Error.fg,
      tab_close_fg = Error.fg,
      tab_close_bg = StatusLine.bg,
      tab_fg = TabLine.fg,
      tab_bg = TabLine.bg,
      tab_active_fg = TabLineSel.fg,
      tab_active_bg = TabLineSel.bg,
      inactive = HeirlineInactive,
      normal = HeirlineNormal,
      insert = HeirlineInsert,
      visual = HeirlineVisual,
      replace = HeirlineReplace,
      command = HeirlineCommand,
      terminal = HeirlineTerminal,
    }

    for _, section in ipairs {
      'git_branch',
      'file_info',
      'git_diff',
      'diagnostics',
      'lsp',
      'macro_recording',
      'cmd_info',
      'treesitter',
      'nav',
    } do
      if not colors[section .. '_bg'] then colors[section .. '_bg'] = colors['section_bg'] end
      if not colors[section .. '_fg'] then colors[section .. '_fg'] = colors['section_fg'] end
    end

    return colors
  end

  local heir_colors = setup_colors()

  heirline.load_colors(heir_colors)

  local statusline = {
    {
      hl = { fg = 'fg', bg = 'bg' },
      vimode,
      status.component.git_branch(),
      status.component.file_info(
        utils.has_plugin 'bufferline.nvim' and { filetype = {}, filename = false, file_modified = false } or nil
      ),
      status.component.git_diff(),
      diagnostics,
      status.component.fill(),
      status.component.cmd_info(),
      status.component.fill(),
      status.component.lsp(),
      status.component.treesitter(),
      status.component.nav(),
      status.component.mode { surround = { separator = 'right' } },
    },
  }

  local winbar = {
    init = function (self) self.bufnr = vim.api.nvim_get_current_buf() end,
    fallthrough = false,
    {
      condition = function () return not status.condition.is_active() end,
      status.component.file_info {
        file_icon = { hl = status.hl.file_icon 'winbar', padding = { left = 0 } },
        file_modified = false,
        file_read_only = false,
        hl = status.hl.get_attributes('winbarnc', true),
        surround = false,
        update = 'BufEnter',
      },
    },
    status.component.breadcrumbs { hl = status.hl.get_attributes('winbar', true) }
  }

  local opts = {
    disable_winbar_cb = function (args)
      return not utils.is_valid(args.buf) or conditions.buffer_matches({
        buftype = {
          'help',
          'nofile',
          'prompt',
          'quickfix',
          'terminal',
        },
        filetype = {
          'aerial',
          'alpha',
          'dashboard',
          'neo%-tree',
          'NvimTree',
          'Outline',
        },
      }, args.buf)
    end,
  }

  heirline.setup {
    opts = opts,
    statusline = statusline,
    winbar = winbar,
  }

  local augroup = vim.api.nvim_create_augroup('Heirline', { clear = true })
  vim.api.nvim_create_autocmd('User', {
    callback = function ()
      require 'heirline.utils'.on_colorscheme(setup_colors())
    end,
    desc = 'Refresh heirline colors',
    group = augroup,
    pattern = 'AGRColorScheme',
  })

  -- vim.api.nvim_create_autocmd('User', {
  --   callback = function ()
  --     if
  --       vim.opt.diff:get()
  --       or status.condition.buffer_matches(require('heirline').winbar.disabled or {
  --         buftype = { 'terminal', 'prompt', 'nofile', 'help', 'quickfix' },
  --         filetype = { 'NvimTree', 'neo%-tree', 'dashboard', 'Outline', 'aerial' },
  --       }) -- TODO v3: remove the default fallback here
  --     then
  --       vim.opt_local.winbar = nil
  --     end
  --   end,
  --   desc = 'Disable winbar for some filetypes',
  --   group = augroup,
  --   pattern = 'HeirlineInitWinbar',
  -- })
end

return H
