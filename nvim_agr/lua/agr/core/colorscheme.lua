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
    Visual = { reverse = true },

    -- Alpha dash
    AlphaButtonShortcut = { fg = colors.bright_magenta, bold = true },
    AlphaButtonText = { fg = colors.bright_cyan },

    -- Vim illuminate
    IlluminatedWordRead = { bg = colors.gutter_fg },
    IlluminatedWordText = { bg = colors.gutter_fg },
    IlluminatedWordWrite = { bg = colors.gutter_fg },

    -- CMP
    Pmenu = { fg = colors.fg, bg = colors.none },
    PmenuSel = { bg = colors.selection },

    CmpItemAbbrDeprecated = { fg = colors.purple, bg = colors.none , strikethrough = true },
    CmpItemAbbrMatch = { fg = colors.cyan, bg = colors.none , bold = true },
    CmpItemAbbrMatchFuzzy = { fg = colors.cyan, bg = colors.none , bold = true },
    CmpItemMenu = { fg = colors.comment, bg = colors.none , italic = true },

    CmpItemKindEvent = { fg = colors.bright_red },
    CmpItemKindField = { fg = colors.bright_red },
    CmpItemKindProperty = { fg = colors.bright_red },

    CmpItemKindEnum = { fg = colors.bright_green },
    CmpItemKindKeyword = { fg = colors.fg },
    CmpItemKindText = { fg = colors.bright_yellow },

    CmpItemKindConstant = { fg = colors.orange },
    CmpItemKindConstructor = { fg = colors.orange },
    CmpItemKindReference = { fg = colors.orange },

    CmpItemKindClass = { fg = colors.bright_magenta },
    CmpItemKindFunction = { fg = colors.bright_magenta },
    CmpItemKindModule = { fg = colors.bright_magenta },
    CmpItemKindOperator = { fg = colors.bright_magenta },
    CmpItemKindStruct = { fg = colors.bright_magenta },

    CmpItemKindFile = { fg = colors.bright_cyan },
    CmpItemKindVariable = { fg = colors.bright_cyan },

    CmpItemKindFolder = { fg = colors.bright_blue },
    CmpItemKindSnippet = { fg = colors.bright_blue },
    CmpItemKindUnit = { fg = colors.bright_blue },

    CmpItemKindEnumMember = { fg = colors.yellow },
    CmpItemKindMethod = { fg = colors.yellow },
    CmpItemKindValue = { fg = colors.yellow },

    CmpItemKindColor = { fg = colors.green },
    CmpItemKindInterface = { fg = colors.green },
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
    NeoTreeTabInactive = { fg = colors.comment, bg = colors.bg },
    NeoTreeTabSeparatorInactive = { fg = colors.bg, bg = colors.bg },

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

    -- LSP
    DiagnosticVirtualTextError = { fg = colors.bright_red },
    DiagnosticVirtualTextHint = { fg = colors.bright_cyan },
    DiagnosticVirtualTextInfo = { fg = colors.bright_cyan },
    DiagnosticVirtualTextWarn = { fg = colors.bright_yellow },

    -- Saga
    SagaLightBulb = { fg = colors.bright_yellow },

    -- Heirline
    StatusLine = { fg = colors.fg, bg = colors.menu },

    -- Rainbow Delimiters
    RainbowDelimiterBlue = { fg = colors.bright_blue },
    RainbowDelimiterCyan = { fg = colors.orange },
    RainbowDelimiterGreen = { fg = colors.green },
    RainbowDelimiterOrange = { fg = colors.cyan },
    RainbowDelimiterRed = { fg = colors.pink },
    RainbowDelimiterViolet = { fg = colors.purple },
    RainbowDelimiterYellow = { fg = colors.yellow },

    -- Git conflict
    GitConflictDiffCurrent = { fg = colors.bg, bg = colors.purple, bold = true },
    GitConflictDiffIncoming = { fg = colors.bg, bg = colors.red, bold = true },

    -- Flash
    FlashBackdrop = { fg = colors.comment },
    FlashCurrent = { fg = colors.bright_cyan },
    FlashLabel = { fg = colors.pink, bold = true },
    FlashMatch = { fg = colors.bright_green },
  },
  transparent_bg = true,
})

local colorscheme = 'dracula'

---@diagnostic disable-next-line: param-type-mismatch
local color_status_ok, _ = pcall(vim.cmd, 'colorscheme ' .. colorscheme)
if not color_status_ok then
  vim.notify('colorscheme ' .. colorscheme .. ' not found!')
  return
end

