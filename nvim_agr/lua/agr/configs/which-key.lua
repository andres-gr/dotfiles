local which_key_status_ok, which_key = pcall(require, 'which-key')
if not which_key_status_ok then return end

local show = which_key.show

which_key.show = function (keys, opts)
  if vim.bo.filetype ~= 'TelescopePrompt' then
    show(keys, opts)
  end
end

which_key.setup {
  active = true,
  disable = {
    filetypes = {
      'TelescopePrompt',
    },
  },
  hidden = {
    '<CR>',
    '<Cmd>',
    '<cmd>',
    '<silent>',
    '^ ',
    '^:',
    'call',
    'lua',
  }, -- hide mapping boilerplate
  ignore_missing = false, -- enable this to hide mappings for which you didn't specify a label
  layout = {
    align = 'center', -- align columns left, center or right
    height = {
      max = 25,
      min = 4,
    }, -- min and max height of the columns
    spacing = 8, -- spacing between columns
    width = {
      max = 50,
      min = 20,
    }, -- min and max width of the columns
  },
  on_config_done = nil,
  plugins = {
    presets = {
      operators = false,
    },
    spelling = {
      enabled = true,
    },
  },
  popup_mappings = {
    scroll_down = '<C-d>', -- binding to scroll down inside the popup
    scroll_up = '<C-u>', -- binding to scroll up inside the popup
  },
  show_help = true, -- show help message on the command line when the popup is visible
  triggers = 'auto', -- automatically setup triggers
  triggers_blacklist = {
    -- list of mode / prefixes that should never be hooked by WhichKey
    -- this is mostly relevant for key maps that start with a native binding
    -- most people should not need to change this
    i = { 'j', 'k' },
    v = { 'j', 'k' },
  },
  window = {
    border = 'rounded',
    margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
    padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
    position = 'bottom', -- bottom, top
    winblend = 0,
  },
}

