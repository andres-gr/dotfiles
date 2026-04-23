local R = {
  'MeanderingProgrammer/render-markdown.nvim',
  opts = {
    completions = {
      lsp = { enabled = false },
    },
    file_types = {
      'markdown',
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
  },
}

return R
