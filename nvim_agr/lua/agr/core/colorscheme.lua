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
    -- Standard
    CursorLine = { bg = colors.menu },
    MatchParen = { bg = colors.gutter_fg },
    TabLineFill = { bg = colors.none },

    -- Alpha dash
    AlphaButtonShortcut = { fg = colors.green, bold = true },
    AlphaButtonText = { fg = colors.bright_blue },
    AlphaFooter = { fg = colors.bright_cyan },

    -- Vim illuminate
    IlluminatedWordRead = { bg = colors.gutter_fg },
    IlluminatedWordText = { bg = colors.gutter_fg },
    IlluminatedWordWrite = { bg = colors.gutter_fg },

    -- CMP
    PmenuSel = { bg = colors.selection },
    Pmenu = { fg = colors.fg, bg = colors.none },

    CmpItemAbbrDeprecated = { fg = colors.purple, bg = colors.none , strikethrough = true },
    CmpItemAbbrMatch = { fg = colors.cyan, bg = colors.none , bold = true },
    CmpItemAbbrMatchFuzzy = { fg = colors.cyan, bg = colors.none , bold = true },
    CmpItemMenu = { fg = colors.comment, bg = colors.none , italic = true },

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
    NeoTreeNormal = { bg = colors.none },
    NeoTreeNormalNC = { bg = colors.none },

    -- Bufferline
    BufferLineFill = { bg = colors.none },

    -- TS
    ['@tag.delimiter'] = { fg = colors.fg },
    htmlEndTag = { fg = colors.fg },

    -- Telescope
    TelescopePromptCounter = { fg = colors.comment },
    TelescopeResultsDiffUntracked = { fg = colors.comment },

    -- Diff
    diffFile = { fg = colors.comment },
  },
  transparent_bg = true,
})

local colorscheme = 'dracula'

local color_status_ok, _ = pcall(vim.cmd, 'colorscheme ' .. colorscheme)
if not color_status_ok then
  vim.notify('colorscheme ' .. colorscheme .. ' not found!')
  return
end

