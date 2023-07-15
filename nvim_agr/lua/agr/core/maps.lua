local utils = require 'agr.core.utils'
local map = vim.keymap.set
local opts = {
  remap = false,
  silent = true,
}
local term_opts = { silent = true }
local all = {
  '',
  '!',
  't',
}

local desc_opts = function (desc)
  local result = { desc = desc }

  for key, val in pairs(opts) do
    result[key] = val
  end

  return result
end

-- Unmap space and Q
map('', 'Q', '<Nop>', opts)
map('', '<Space>', '<Nop>', opts)

-- map('', '', '', desc_opts(''))

-- Modes
--   normal_mode = 'n',
--   insert_mode = 'i',
--   visual_mode = 'v',
--   visual_block_mode = 'x',
--   term_mode = 't',
--   command_mode = 'c',

-- Better window navigation
map('n', '<C-h>', '<C-w>h', desc_opts('Move to left window'))
map('n', '<C-j>', '<C-w>j', desc_opts('Move to lower window'))
map('n', '<C-k>', '<C-w>k', desc_opts('Move to upper window'))
map('n', '<C-l>', '<C-w>l', desc_opts('Move to right window'))

-- Resize with arrows
map('n', '<C-Up>', ':resize -2<CR>', desc_opts('Resize window up'))
map('n', '<C-Down>', ':resize +2<CR>', desc_opts('Resize window down'))
map('n', '<C-Left>', ':vertical resize -2<CR>', desc_opts('Resize window left'))
map('n', '<C-Right>', ':vertical resize +2<CR>', desc_opts('Resize window right'))

-- Navigate buffers
map('n', '<M-l>', ':BufferLineCycleNext<CR>', desc_opts('Go to next buffer'))
map('n', '<M-h>', ':BufferLineCyclePrev<CR>', desc_opts('Go to previous buffer'))
map('n', '<leader>>', ':BufferLineMoveNext<CR>', desc_opts('Move buffer right'))
map('n', '<leader><', ':BufferLineMovePrev<CR>', desc_opts('Move buffer left'))

-- File actions
map('n', '\\c', ':Bdelete<CR>', desc_opts('Close current buffer'))
map('n', '\\C', ':Bdelete!<CR>', desc_opts('Close w/force current buffer'))
map('n', '\\w', ':w!<CR>', desc_opts('Save current file'))
map('n', '\\q', ':q<CR>', desc_opts('Quit'))
map('n', '\\Q', ':q!<CR>', desc_opts('Quit w/force'))
map('n', '<leader>q', ':q<CR>', desc_opts('Quit'))
map('n', '<leader>Q', ':q!<CR>', desc_opts('Quit w/force'))
map('n', '<leader>z', ':Bdelete<CR>', desc_opts('Close current buffer'))
map('n', '<leader>Z', ':Bdelete!<CR>', desc_opts('Close w/force current buffer'))
map('n', '\\t', ':windo bd<CR>', desc_opts('Quit window tab'))

-- Netrw file tree
-- map('n', '<leader>e', ':Lex 30<cr>', desc_opts('Toggle Netrw file tree'))

-- Escapes
map('i', 'jk', '<ESC>', desc_opts('Escape'))
map('i', 'jj', '<ESC>', desc_opts('Escape'))
map(all, '<M-o>', '<ESC>', desc_opts('Escape'))

-- Black hole deletes
map({ 'n', 'v' }, '<leader>d', '"_d', desc_opts('Black hole delete'))
map({ 'n', 'v' }, '<leader>c', '"_c', desc_opts('Black hole change'))
map({ 'n', 'v' }, '<leader>x', '"_x', desc_opts('Black hole remove'))
map({ 'n', 'v' }, '<leader>r', '"_r', desc_opts('Black hole replace'))
map({ 'n', 'v' }, '<leader>D', '"_D', desc_opts('Black hole Delete'))
map({ 'n', 'v' }, '<leader>C', '"_C', desc_opts('Black hole Change'))
map({ 'n', 'v' }, '<leader>X', '"_X', desc_opts('Black hole Remove'))
map({ 'n', 'v' }, '<leader>R', '"_R', desc_opts('Black hole Replace'))
map('v', 'p', '"_dP', desc_opts('Paste without replace in visual'))

-- Center navigation
map('n', 'N', [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>zz]], desc_opts('Center search backwards'))
map('n', 'n', [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>zz]], desc_opts('Center search forwards'))
map('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>zz]], desc_opts('Center prev cursor word'))
map('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>zz]], desc_opts('Center next cursor word'))
map('n', 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>zz]], desc_opts('Center prev cursor word'))
map('n', 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>zz]], desc_opts('Center next cursor word'))
map('n', '<C-u>', '<C-u>zz', desc_opts('Center half page up'))
map('n', '<C-d>', '<C-d>zz', desc_opts('Center half page down'))

-- Better indents
map('v', '<', '<gv', desc_opts('Indent left'))
map('v', '>', '>gv', desc_opts('Indent right'))
map('n', '<', 'v<', desc_opts('Indent left'))
map('n', '>', 'v>', desc_opts('Indent right'))

-- Cancel search highlight
map('n', '<leader>n', ':nohlsearch<Bar>:echo<CR>', desc_opts('Clear search highlight'))
map('n', '<ESC>', ':nohlsearch<Bar>:echo<CR>', desc_opts('Clear search highlight'))

-- Move lines
map('x', '<M-k>', ":m '<-2<CR>gv-gv", desc_opts('Move lines up'))
map('x', '<M-j>', ":m '>+1<CR>gv-gv", desc_opts('Move lines down'))
map('n', '<M-k>', ":m-2<CR>==", desc_opts('Move line up'))
map('n', '<M-j>', ":m+1<CR>==", desc_opts('Move line down'))

-- Sort lines
map('v', '<leader>o', ':sort i<CR>', desc_opts('Sort lines'))
map('v', '<leader>O', ':sort<CR>', desc_opts('Sort lines case sensitive'))

-- Better terminal navigation
map('t', '<C-h>', '<C-\\><C-N><C-w>h', term_opts)
map('t', '<C-j>', '<C-\\><C-N><C-w>j', term_opts)
map('t', '<C-k>', '<C-\\><C-N><C-w>k', term_opts)
map('t', '<C-l>', '<C-\\><C-N><C-w>l', term_opts)

-- File tree
map('n', '<leader>v', ':Neotree toggle<CR>', desc_opts('Open file tree explorer'))
map('n', '<leader>o', ':Neotree focus<CR>', desc_opts('Focus file tree explorer'))

-- Fuzzy finder
local telescope_status, _ = pcall(require, 'telescope')
if telescope_status then
  local builtins = require 'telescope.builtin'
  -- map('n', '<leader>f', function () builtins. end, desc_opts(''))
  map('n', '<leader>fw', builtins.live_grep, desc_opts('Search words'))
  map('n', '<leader>fW', function () builtins.live_grep({
    additional_args = function (args)
      return vim.list_extend(args, {
        '--hidden',
        '--no-ignore',
      })
    end,
  }) end, desc_opts('Search words in all files'))
  map('n', '<leader>ff', builtins.find_files, desc_opts('Search files'))
  map('n', '<leader>fF', function () builtins.find_files { no_ignore = true } end, desc_opts('Search all files'))
  map('n', '<leader>fb', builtins.buffers, desc_opts('Search buffers'))
  map('n', '<leader>fh', builtins.help_tags, desc_opts('Search help'))
  map('n', '<leader>fH', function () builtins.highlights {
    attach_mappings = function (_, _map)
      _map('i', '<C-y>', function ()
        local entry = require 'telescope.actions.state'.get_selected_entry()
        vim.fn.setreg('*', entry.value)
        vim.notify('Yanked ' .. entry.value)
      end)

      _map('n', '<C-y>', function ()
        local entry = require 'telescope.actions.state'.get_selected_entry()
        vim.fn.setreg('*', entry.value)
        vim.notify('Yanked ' .. entry.value)
      end)

      return true
    end,
  } end, desc_opts('Search highlights'))
  map('n', '<leader>fo', builtins.oldfiles, desc_opts('Search file history'))
  map('n', '<leader>fc', builtins.grep_string, desc_opts('Search word under cursor'))
  map('n', '<leader>fr', builtins.registers, desc_opts('Search registers'))
  map('n', '<leader>fk', builtins.keymaps, desc_opts('Search keymaps'))
  map('n', '<leader>fn', builtins.commands, desc_opts('Search commands'))
  map('n', '<leader>fg', builtins.git_status, desc_opts('Search git status'))
  if utils.has_plugin 'aerial' then
    map('n', '<leader>fa', '<CMD>Telescope aerial<CR>', desc_opts('Search symbols'))
  end
  if utils.has_plugin 'notify' then
    map('n', '<leader>fm', '<CMD>Telescope notify<CR>', desc_opts('Search messages'))
  end
  map('n', '<leader>lg', builtins.lsp_workspace_symbols, desc_opts('Search workspace symbols'))
  map('n', '<leader>lr', builtins.lsp_references, desc_opts('Search references'))
  map('n', '<leader>ld', builtins.diagnostics, desc_opts('Search diagnostics'))
end

-- Lazy
map('n', '<leader>pS', ':Lazy sync<CR>', desc_opts('Lazy sync'))
map('n', '<leader>ps', ':Lazy<CR>', desc_opts('Lazy status'))
map('n', '<leader>pU', ':Lazy update<CR>', desc_opts('Lazy update'))
map('n', '<leader>pc', ':Lazy check<CR>', desc_opts('Lazy check for updates'))

-- Gitsigns
if utils.has_plugin 'gitsigns' then
  local blame_line = '<CMD>lua require "agr.core.utils".fix_float_ui("Gitsigns blame_line")<CR>'
  local preview_hunk = '<CMD>lua require "agr.core.utils".fix_float_ui("Gitsigns preview_hunk")<CR>'

  map('n', '<leader>gk', '<CMD>Gitsigns prev_hunk<CR>zz', desc_opts('Git prev hunk'))
  map('n', '<leader>gj', '<CMD>Gitsigns next_hunk<CR>zz', desc_opts('Git next hunk'))
  map('n', '<leader>gl', blame_line, desc_opts('Git blame line'))
  map('n', '<leader>gp', preview_hunk, desc_opts('Git preview hunk'))
  map('n', '<leader>ghr', '<CMD>Gitsigns reset_hunk<CR>', desc_opts('Git reset hunk'))
  map('n', '<leader>gbr', '<CMD>Gitsigns reset_buffer<CR>', desc_opts('Git reset buffer'))
  map('n', '<leader>ghs', '<CMD>Gitsigns stage_hunk<CR>', desc_opts('Git stage hunk'))
  map('n', '<leader>ghu', '<CMD>Gitsigns undo_stage_hunk<CR>', desc_opts('Git unstage hunk'))
  map('n', '<leader>Gd', '<CMD>Gitsigns diffthis<CR>', desc_opts('Git view diff'))
end

-- Git conflict
if utils.has_plugin 'git-conflict' then
  map('n', '<leader>gco', '<Plug>(git-conflict-ours)', desc_opts('Git conflict choose ours'))
  map('n', '<leader>gct', '<Plug>(git-conflict-theirs)', desc_opts('Git conflict choose theirs'))
  map('n', '<leader>gcb', '<Plug>(git-conflict-both)', desc_opts('Git conflict choose both'))
  map('n', '<leader>gcn', '<Plug>(git-conflict-none)', desc_opts('Git conflict choose none'))
  map('n', '[x', '<Plug>(git-conflict-prev-conflict)', desc_opts('Git prev conflict'))
  map('n', ']x', '<Plug>(git-conflict-next-conflict)', desc_opts('Git next conflict'))
end

-- Git fugitive
map('n', '<leader>Gl', ':0Gllog<CR>', desc_opts('Git show file history'))

-- Git time lapse
map('n', '<leader>Gt', ':GitTimeLapse<CR>', desc_opts('Git show file time lapse'))

-- Dash
map('n', '<leader>a', ':Alpha<CR>', desc_opts('Show dashboard'))

-- LSP Installer
map('n', '<leader>pi', ':Mason<CR>', desc_opts('Mason installer'))
map('n', '<leader>li', ':LspInfo<CR>', desc_opts('LSP info'))

-- Symbols outline
map('n', '<leader>lS', ':AerialToggle<CR>', desc_opts('Symbols outline'))

-- Better motion
map('n', '<leader>s', '<Plug>(leap-forward)', desc_opts('Leap forward'))
map('n', '<leader>S', '<Plug>(leap-backward)', desc_opts('Leap bacward'))
map('n', '<leader>w', '<Plug>WordMotion_w', desc_opts('Wordmotion w'))
map('', '<leader>iw', '<Plug>WordMotion_iw', desc_opts('Wordmotion iw'))
map('', '<leader><leader>aw', '<Plug>WordMotion_aw', desc_opts('Wordmotion aw'))
map('n', '<leader>e', '<Plug>WordMotion_e', desc_opts('Wordmotion e'))
map('n', '<leader>b', '<Plug>WordMotion_b', desc_opts('Wordmotion b'))
map('n', '<leader>W', '<Plug>WordMotion_W', desc_opts('Wordmotion W'))
map('', '<leader>iW', '<Plug>WordMotion_iW', desc_opts('Wordmotion iW'))
map('', '<leader><leader>aW', '<Plug>WordMotion_aW', desc_opts('Wordmotion aW'))
map('n', '<leader>E', '<Plug>WordMotion_E', desc_opts('Wordmotion E'))
map('n', '<leader>B', '<Plug>WordMotion_B', desc_opts('Wordmotion B'))

-- Increment/decrement numbers
map('n', '-', '<C-x>', desc_opts('Decrement number'))
map('n', '+', '<C-a>', desc_opts('Increment number'))

-- Find and replace
map('n', '<leader>fRo', function () require 'spectre'.open() end, desc_opts('Find and replace in files'))
map('n', '<leader>fRw', function () require 'spectre'.open_visual { select_word = true } end, desc_opts('Find and replace current word in files'))
map('v', '<leader>fR', "<ESC>:lua require('spectre').open_visual()<CR>", desc_opts('Find and current word replace in files'))
map('n', '<leader>fRc', function () require 'spectre'.open_file_search() end, desc_opts('Find and replace in current file'))

-- Zen mode
map('n', '\\z', '<CMD>ZenMode<CR>', desc_opts('Toggle Zen Mode'))

-- Session management
map('n', '<leader><leader>qs', function () require('persistance').load() end, desc_opts('Restore session'))
map('n', '<leader><leader>ql', function () require('persistance').load { last = true } end, desc_opts('Restore last session'))
map('n', '<leader><leader>qd', function () require('persistance').stop() end, desc_opts('Don\'t save current session'))
