local heirline_status_ok, heirline = pcall(require, 'heirline')
if not heirline_status_ok then return end

local C = require 'agr.core.colors'
local utils = require 'agr.core.utils'
local status = require 'agr.astro.status'
local vimode = require 'agr.configs.heir-line.vimode'

local setup_colors = function ()
  local StatusLine = utils.get_hlgroup('StatusLine', { fg = C.fg, bg = C.grey_4 })
  local WinBar = utils.get_hlgroup('WinBar', { fg = C.grey_2, bg = C.bg })
  local WinBarNC = utils.get_hlgroup('WinBarNC', { fg = C.grey, bg = C.bg })
  local Conditional = utils.get_hlgroup('Conditional', { fg = C.purple_1, bg = C.grey_4 })
  local String = utils.get_hlgroup('String', { fg = C.green, bg = C.grey_4 })
  local TypeDef = utils.get_hlgroup('TypeDef', { fg = C.yellow, bg = C.grey_4 })
  local HeirlineNormal = utils.get_hlgroup('HerlineNormal', { fg = C.blue, bg = C.grey_4 })
  local HeirlineInsert = utils.get_hlgroup('HeirlineInsert', { fg = C.green, bg = C.grey_4 })
  local HeirlineVisual = utils.get_hlgroup('HeirlineVisual', { fg = C.purple, bg = C.grey_4 })
  local HeirlineReplace = utils.get_hlgroup('HeirlineReplace', { fg = C.red_1, bg = C.grey_4 })
  local HeirlineCommand = utils.get_hlgroup('HeirlineCommand', { fg = C.yellow_1, bg = C.grey_4 })
  local HeirlineInactive = utils.get_hlgroup('HeirlineInactive', { fg = C.grey_7, bg = C.grey_4 })
  local GitSignsAdd = utils.get_hlgroup('GitSignsAdd', { fg = C.green, bg = C.grey_4 })
  local GitSignsChange = utils.get_hlgroup('GitSignsChange', { fg = C.orange_1, bg = C.grey_4 })
  local GitSignsDelete = utils.get_hlgroup('GitSignsDelete', { fg = C.red_1, bg = C.grey_4 })
  local DiagnosticError = utils.get_hlgroup('DiagnosticError', { fg = C.red_1, bg = C.grey_4 })
  local DiagnosticWarn = utils.get_hlgroup('DiagnosticWarn', { fg = C.orange_1, bg = C.grey_4 })
  local DiagnosticInfo = utils.get_hlgroup('DiagnosticInfo', { fg = C.white_2, bg = C.grey_4 })
  local DiagnosticHint = utils.get_hlgroup('DiagnosticHint', { fg = C.yellow_1, bg = C.grey_4 })

  local colors = {
    fg = StatusLine.fg,
    bg = StatusLine.bg,
    section_fg = StatusLine.fg,
    section_bg = StatusLine.bg,
    git_branch_fg = Conditional.fg,
    treesitter_fg = String.fg,
    scrollbar = TypeDef.fg,
    git_added = GitSignsAdd.fg,
    git_changed = GitSignsChange.fg,
    git_removed = GitSignsDelete.fg,
    diag_ERROR = DiagnosticError.fg,
    diag_WARN = DiagnosticWarn.fg,
    diag_INFO = DiagnosticInfo.fg,
    diag_HINT = DiagnosticHint.fg,
    normal = utils.lualine_mode('normal', HeirlineNormal.fg),
    insert = utils.lualine_mode('insert', HeirlineInsert.fg),
    visual = utils.lualine_mode('visual', HeirlineVisual.fg),
    replace = utils.lualine_mode('replace', HeirlineReplace.fg),
    command = utils.lualine_mode('command', HeirlineCommand.fg),
    inactive = HeirlineInactive.fg,
    winbar_fg = WinBar.fg,
    winbar_bg = WinBar.bg,
    winbarnc_fg = WinBarNC.fg,
    winbarnc_bg = WinBarNC.bg,
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

local heirline_opts = {
  {
    hl = { fg = 'fg', bg = 'bg' },
    -- status.component.mode(),
    vimode,
    status.component.git_branch(),
    status.component.file_info(
      utils.is_available 'bufferline.nvim' and { filetype = {}, filename = false, file_modified = false } or nil
    ),
    status.component.git_diff(),
    status.component.diagnostics(),
    status.component.fill(),
    status.component.cmd_info(),
    status.component.fill(),
    status.component.lsp(),
    status.component.treesitter(),
    status.component.nav(),
    status.component.mode { surround = { separator = 'right' } },
  },
  {
    fallthrough = false,
    {
      condition = function()
        return status.condition.buffer_matches {
          buftype = { 'terminal', 'prompt', 'nofile', 'help', 'quickfix' },
          filetype = { 'NvimTree', 'neo-tree', 'dashboard', 'Outline', 'aerial' },
        }
      end,
      init = function() vim.opt_local.winbar = nil end,
    },
    {
      condition = status.condition.is_active,
      status.component.breadcrumbs { hl = { fg = heir_colors.winbar_fg, bg = heir_colors.winbar_bg } },
    },
    status.component.file_info {
      file_icon = { hl = false },
      hl = { fg = heir_colors.winbarnc_fg, bg = heir_colors.winbarnc_bg },
      surround = false,
    },
  },
}

heirline.setup(heirline_opts[1], heirline_opts[2], heirline_opts[3])

vim.api.nvim_create_augroup('Heirline', { clear = true })
vim.api.nvim_create_autocmd('User', {
  callback = function ()
    require 'heirline.utils'.on_colorscheme(setup_colors())
  end,
  desc = 'Refresh heirline colors',
  group = 'Heirline',
  pattern = 'AGRColorScheme',
})

