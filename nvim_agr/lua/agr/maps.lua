local map = vim.keymap.set
local opts = {
  noremap = true,
  silent = true,
}
local termOpts = { silent = true }
local all = {
  '',
  '!',
  't',
}

local descOpts = function (desc)
  local result = { desc = desc }

  for key, val in pairs(opts) do
    result[key] = val
  end

  return result
end

-- Remap space as leader
map('', '<Space>', '<Nop>', opts)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- map('', '', '', descOpts(''))

-- Modes
--   normal_mode = 'n',
--   insert_mode = 'i',
--   visual_mode = 'v',
--   visual_block_mode = 'x',
--   term_mode = 't',
--   command_mode = 'c',

-- Better window navigation
map('n', '<C-h>', '<C-w>h', descOpts('Move to left window'))
map('n', '<C-j>', '<C-w>j', descOpts('Move to right window'))
map('n', '<C-k>', '<C-w>k', descOpts('Move to upper window'))
map('n', '<C-l>', '<C-w>l', descOpts('Move to lower window'))

-- Resize with arrows
map('n', '<C-Up>', ':resize -2<CR>', descOpts('Resize window up'))
map('n', '<C-Down>', ':resize +2<CR>', descOpts('Resize window down'))
map('n', '<C-Left>', ':vertical resize -2<CR>', descOpts('Resize window left'))
map('n', '<C-Right>', ':vertical resize +2<CR>', descOpts('Resize window right'))

-- Navigate buffers
map('n', '<M-l>', ':bnext<CR>', descOpts('Go to next buffer'))
map('n', '<M-h>', ':bprevious<CR>', descOpts('Go to previous buffer'))

-- File actions
map('n', '\\c', ':bdelete<CR>', descOpts('Close current buffer'))
map('n', '\\w', ':w!<CR>', descOpts('Save current file'))
map('n', '\\q', ':q!<CR>', descOpts('Quit'))

-- Netrw file tree
map('n', '<leader>e', ':Lex 30<cr>', descOpts('Toggle Netrw file tree'))

-- Escapes
map('i', 'jk', '<ESC>', descOpts('Escape'))
map('i', 'jj', '<ESC>', descOpts('Escape'))
map(all, '<M-o>', '<ESC>', descOpts('Escape'))

-- Black hole deletes
map({ 'n', 'v' }, '<leader>d', '"_d', descOpts('Black hole delete'))
map({ 'n', 'v' }, '<leader>c', '"_c', descOpts('Black hole change'))
map({ 'n', 'v' }, '<leader>x', '"_x', descOpts('Black hole remove'))
map({ 'n', 'v' }, '<leader>r', '"_r', descOpts('Black hole replace'))
map({ 'n', 'v' }, '<leader>D', '"_D', descOpts('Black hole Delete'))
map({ 'n', 'v' }, '<leader>C', '"_C', descOpts('Black hole Change'))
map({ 'n', 'v' }, '<leader>X', '"_X', descOpts('Black hole Remove'))
map({ 'n', 'v' }, '<leader>R', '"_R', descOpts('Black hole Replace'))
-- map('v', 'p', '"_dP', descOpts('Paste without replace in visual'))

-- Center search
map('n', 'n', 'nzz', descOpts('Center search'))
map('n', 'N', 'Nzz', descOpts('Center Search'))

-- Better indents
map('n', '<', '<gv', descOpts('Indent left'))
map('n', '>', '>gv', descOpts('Indent right'))

-- Cancel search highlight
map('n', '<leader>h', ':nohlsearch<Bar>:echo<CR>', descOpts('Clear search hightlight'))
map('n', '<ESC>', ':nohlsearch<Bar>:echo<CR>', descOpts('Clear search hightlight'))

-- Move lines
map('x', '<M-k>', ":m '<-2<CR>gv-gv", descOpts('Move lines up'))
map('x', '<M-j>', ":m '>+1<CR>gv-gv", descOpts('Move lines down'))
map('n', '<M-k>', ":m-2<CR>==", descOpts('Move line up'))
map('n', '<M-j>', ":m+1<CR>==", descOpts('Move line down'))

-- Sort lines
map('v', '<leader>o', ':sort<CR>', descOpts('Sort lines'))

-- Better terminal navigation
map("t", "<C-h>", "<C-\\><C-N><C-w>h", term_opts)
map("t", "<C-j>", "<C-\\><C-N><C-w>j", term_opts)
map("t", "<C-k>", "<C-\\><C-N><C-w>k", term_opts)
map("t", "<C-l>", "<C-\\><C-N><C-w>l", term_opts)

