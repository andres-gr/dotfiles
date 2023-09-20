local T = {
  'nvim-treesitter/nvim-treesitter-textobjects',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
  },
  event = {
    'BufNewFile',
    'BufReadPost',
  },
}

T.config = function ()
  local treesitter = require 'nvim-treesitter.configs'

  treesitter.setup {
    textobjects = {
      select = {
        enable = true,
        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['a='] = { query = '@assignment.outer', desc = 'Select outer part of an assignment region' },
          ['i='] = { query = '@assignment.inner', desc = 'Select inner part of an assignment region' },

          ['a:'] = { query = '@parameter.outer', desc = 'Select outer part of a parameter/field region' },
          ['i:'] = { query = '@parameter.inner', desc = 'Select inner part of a parameter/field region' },

          ['ai'] = { query = '@conditional.outer', desc = 'Select outer part of a conditional region' },
          ['ii'] = { query = '@conditional.inner', desc = 'Select inner part of a conditional region' },

          ['al'] = { query = '@loop.outer', desc = 'Select outer part of a loop region' },
          ['il'] = { query = '@loop.inner', desc = 'Select inner part of a loop region' },

          ['ab'] = { query = '@block.outer', desc = 'Select outer part of a block region' }, -- overrides default text object block of parenthesis to parenthesis
          ['ib'] = { query = '@block.inner', desc = 'Select inner part of a block region' }, -- overrides default text object block of parenthesis to parenthesis

          ['af'] = { query = '@function.outer', desc = 'Select outer part of a function region' },
          ['if'] = { query = '@function.inner', desc = 'Select inner part of a function region' },

          ['ac'] = { query = '@class.outer', desc = 'Select outer part of a class region' },
          ['ic'] = { query = '@class.inner', desc = 'Select inner part of a class region' },
        },
        include_surrounding_whitespace = true,
      },
      swap = {
        enable = true,
        swap_next = {
          ['<leader>tn'] = '@parameter.inner', -- swap object under cursor with next
        },
        swap_previous = {
          ['<leader>tp'] = '@parameter.inner', -- swap object under cursor with previous
        },
      },
    },
  }
end

return T