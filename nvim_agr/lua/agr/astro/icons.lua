local I = {}

local icons = {
  ActiveLSP = '',
  ActiveTS = '綠',
  BufferClose = '',
  NeovimClose = '',
  DefaultFile = '',
  Diagnostic = '裂',
  DiagnosticError = '',
  DiagnosticHint = '',
  DiagnosticInfo = '',
  DiagnosticWarn = '',
  Ellipsis = '…',
  FileModified = '',
  FileReadOnly = '',
  FolderClosed = '',
  FolderEmpty = '',
  FolderOpen = '',
  Git = '',
  GitAdd = '',
  GitBranch = '',
  GitChange = '',
  GitConflict = '',
  GitDelete = '',
  GitIgnored = '◌',
  GitRenamed = '➜',
  GitStaged = '✓',
  GitUnstaged = '✗',
  GitUntracked = '★',
  LSPLoaded = '',
  LSPLoading1 = '',
  LSPLoading2 = '',
  LSPLoading3 = '',
}

local get_icon = function (kind)
  return icons[kind] or ''
end

I.icons = icons
I.get_icon = get_icon

return I

