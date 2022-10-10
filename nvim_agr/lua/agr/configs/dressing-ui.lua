local dressing_status_ok, dressing = pcall(require, 'dressing')
if not dressing_status_ok then return end

dressing.setup {
  input = {
    default_prompt = '➤ ',
    winhighlight = 'Normal:Normal,NormalNC:Normal',
  },
  select = {
    backend = {
      'builtin',
      'telescope',
    },
    builtin = {
      winhighlight = 'Normal:Normal,NormalNC:Normal',
    },
  },
}

