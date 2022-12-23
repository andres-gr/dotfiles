local A = {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
}

A.config = function ()
  local autopairs = require 'nvim-autopairs'

  autopairs.setup {
    check_ts = true,
    disable_filetype = {
      'TelescopePrompt',
      'spectre_panel',
    },
    fast_wrap = {
      chars = {
        "'",
        '(',
        '[',
        '{',
        '"',
      },
      check_comma = true,
      end_key = '$',
      highlight = 'PmenuSel',
      highlight_grey = 'LineNr',
      keys = 'qwertyuiopzxcvbnmasdfghjkl',
      map = '<M-e>',
      offset = 0,
      pattern = string.gsub([[ [%'%'%)%>%]%)%}%,] ]], '%s+', ''),
    },
    ts_config = {
      java = false,
      javascript = {
        'string',
        'template_string',
      },
      lua = {
        'source',
        'string',
      },
    },
  }

  local cmp_status_ok, cmp = pcall(require, 'cmp')
  if cmp_status_ok then
    local cmp_npairs = require 'nvim-autopairs.completion.cmp'
    cmp.event:on('confirm_done', cmp_npairs.on_confirm_done { map_char = { tex = '' } })
  end
end

return A
