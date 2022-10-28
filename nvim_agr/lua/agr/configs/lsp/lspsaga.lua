local saga_status, saga = pcall(require, 'lspsaga')
if not saga_status then return end

saga.init_lsp_saga {
  definition_action_keys = {
    edit = '<CR>', -- Use enter to open file in preview definition
  },
  finder_action_keys = {
    open = '<CR>', -- Use enter to open file in finder
  },
  -- Keybinds for navigation in saga window
  move_in_saga = {
    next = '<C-j>',
    prev = '<C-k>',
  },
}

