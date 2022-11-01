local dracula_status_ok, dracula = pcall(require, 'dracula')
if not dracula_status_ok then
  vim.notify('dracula theme not installed!')
  return
end

local colors = require 'agr.core.colors'.dracula_colors

dracula.setup({
  colors = colors,
  italic_comment = true,
  overrides = {
    AlphaButtonText = { fg = colors.bright_blue },
    AlphaButtonShortcut = { fg = colors.green, bold = true },
    AlphaFooter = { fg = colors.bright_cyan },
    CursorLine = { bg = colors.bg },
    IlluminatedWordRead = { bg = colors.gutter_fg },
    IlluminatedWordText = { bg = colors.gutter_fg },
    IlluminatedWordWrite = { bg = colors.gutter_fg },
    MatchParen = { bg = colors.gutter_fg },

    -- cmp highlights
    PmenuSel = { bg = colors.selection },
    Pmenu = { fg = colors.fg, bg = 'NONE' },

    CmpItemAbbrDeprecated = { fg = colors.purple, bg = 'NONE', strikethrough = true },
    CmpItemAbbrMatch = { fg = colors.cyan, bg = 'NONE', bold = true },
    CmpItemAbbrMatchFuzzy = { fg = colors.cyan, bg = 'NONE', bold = true },
    CmpItemMenu = { fg = colors.gutter_fg, bg = 'NONE', italic = true },

    CmpItemKindField = { fg = colors.bright_red },
    CmpItemKindProperty = { fg = colors.bright_red },
    CmpItemKindEvent = { fg = colors.bright_red },

    CmpItemKindText = { fg = colors.bright_yellow },
    CmpItemKindEnum = { fg = colors.bright_green },
    CmpItemKindKeyword = { fg = colors.fg },

    CmpItemKindConstant = { fg = colors.orange },
    CmpItemKindConstructor = { fg = colors.orange },
    CmpItemKindReference = { fg = colors.orange },

    CmpItemKindFunction = { fg = colors.bright_magenta },
    CmpItemKindStruct = { fg = colors.bright_magenta },
    CmpItemKindClass = { fg = colors.bright_magenta },
    CmpItemKindModule = { fg = colors.bright_magenta },
    CmpItemKindOperator = { fg = colors.bright_magenta },

    CmpItemKindVariable = { fg = colors.bright_cyan },
    CmpItemKindFile = { fg = colors.bright_cyan },

    CmpItemKindUnit = { fg = colors.bright_blue },
    CmpItemKindSnippet = { fg = colors.bright_blue },
    CmpItemKindFolder = { fg = colors.bright_blue },

    CmpItemKindMethod = { fg = colors.yellow },
    CmpItemKindValue = { fg = colors.yellow },
    CmpItemKindEnumMember = { fg = colors.yellow },

    CmpItemKindInterface = { fg = colors.green },
    CmpItemKindColor = { fg = colors.green },
    CmpItemKindTypeParameter = { fg = colors.green },

    -- Neo-tree
    NeoTreeCursorLine = { bg = colors.selection },
    NeoTreeDirectoryIcon = { fg = colors.bright_blue },
    NeoTreeDirectoryName = { fg = colors.fg },
    -- NeoTreeGitAdded = { fg = colors.bright_green },
    NeoTreeGitConflict = { fg = colors.yellow },
    NeoTreeGitDeleted = { fg = colors.bright_red },
    NeoTreeGitModified = { fg = colors.cyan },
    -- NeoTreeGitStaged = { fg = colors.green },
    NeoTreeGitUnstaged = { fg = colors.pink },
    -- NeoTreeGitUntracked = { fg = colors.bright_yellow },
    NeoTreeIndentMarker = { fg = colors.comment },
  },
  transparent_bg = true,
})

local colorscheme = 'dracula'

local color_status_ok, _ = pcall(vim.cmd, 'colorscheme ' .. colorscheme)
if not color_status_ok then
  vim.notify('colorscheme ' .. colorscheme .. ' not found!')
  return
end

-- vim.api.nvim_set_hl(0, 'AlphaButtonText', {
--   fg = colors.bright_blue,
-- })
-- vim.api.nvim_set_hl(0, 'AlphaButtonShortcut', {
--   fg = colors.green,
--   bold = true,
-- })
-- vim.api.nvim_set_hl(0, 'AlphaFooter', {
--   fg = colors.bright_cyan,
-- })

