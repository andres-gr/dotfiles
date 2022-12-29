local S = {}

S.setup = function ()
  local saga = require 'lspsaga'

  saga.init_lsp_saga {
    code_action_lightbulb = {
      cache_code_action = false,
      enable = true,
      enable_in_insert = false,
      update_time = 250,
      virtual_text = false,
    },
    definition_action_keys = {
      edit = '<CR>', -- Use enter to open file in preview definition
    },
    finder_action_keys = {
      open = '<CR>', -- Use enter to open file in finder
    },
    finder_request_timeout = 6000,
    -- preview lines of lsp_finder and definition preview
    max_preview_lines = 30,
    -- Keybinds for navigation in saga window
    move_in_saga = {
      next = '<C-j>',
      prev = '<C-k>',
    },
    server_filetype_map = {
      typescript = 'typescript',
    },
  }
end

return S
