local A = {
  'yetone/avante.nvim',
  build = 'make',
  dependencies = {
    {
      'HakonHarnes/img-clip.nvim',
      event = 'VeryLazy',
      opts = {
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
        },
      },
    },
    {
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        completions = {
          lsp = { enabled = false },
        },
        file_types = {
          'markdown',
          'Avante',
        },
        overrides = {
          buftype = {
            [''] = { enabled = false },
            nofile = { enabled = false },
          },
        },
      },
      ft = {
        'markdown',
        'Avante',
      },
    },
  },
  event = 'VeryLazy',
  version = false,
}

A.config = function ()
  local avante = require 'avante'

  avante.setup {
    input = {
      provider = 'snacks',
      provider_opts = {
        title = 'Avante Input',
        icon = ' ',
      },
    },
    provider = 'gemini',
    providers = {
      gemini = {
        model = 'gemini-2.5-flash',
      },
    },
  }
end

return A
