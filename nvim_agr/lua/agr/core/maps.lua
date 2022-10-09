local map = vim.keymap.set
local opts = {
  noremap = true,
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

map('', 'Q', '<Nop>', opts)

-- Remap space as leader
map('', '<Space>', '<Nop>', opts)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

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
map('n', '<C-j>', '<C-w>j', desc_opts('Move to right window'))
map('n', '<C-k>', '<C-w>k', desc_opts('Move to upper window'))
map('n', '<C-l>', '<C-w>l', desc_opts('Move to lower window'))

-- Resize with arrows
map('n', '<C-Up>', ':resize -2<CR>', desc_opts('Resize window up'))
map('n', '<C-Down>', ':resize +2<CR>', desc_opts('Resize window down'))
map('n', '<C-Left>', ':vertical resize -2<CR>', desc_opts('Resize window left'))
map('n', '<C-Right>', ':vertical resize +2<CR>', desc_opts('Resize window right'))

-- Navigate buffers
map('n', '<M-l>', ':bnext<CR>', desc_opts('Go to next buffer'))
map('n', '<M-h>', ':bprevious<CR>', desc_opts('Go to previous buffer'))

-- File actions
map('n', '\\c', ':bdelete<CR>', desc_opts('Close current buffer'))
map('n', '\\w', ':w!<CR>', desc_opts('Save current file'))
map('n', '\\q', ':q!<CR>', desc_opts('Quit'))

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
-- map('v', 'p', '"_dP', desc_opts('Paste without replace in visual'))

-- Center search
map('n', 'n', 'nzz', desc_opts('Center search'))
map('n', 'N', 'Nzz', desc_opts('Center Search'))

-- Better indents
map('v', '<', '<gv', desc_opts('Indent left'))
map('v', '>', '>gv', desc_opts('Indent right'))
map('n', '<', 'v<', desc_opts('Indent left'))
map('n', '>', 'v>', desc_opts('Indent right'))

-- Cancel search highlight
map('n', '<leader>h', ':nohlsearch<Bar>:echo<CR>', desc_opts('Clear search hightlight'))
map('n', '<ESC>', ':nohlsearch<Bar>:echo<CR>', desc_opts('Clear search hightlight'))

-- Move lines
map('x', '<M-k>', ":m '<-2<CR>gv-gv", desc_opts('Move lines up'))
map('x', '<M-j>', ":m '>+1<CR>gv-gv", desc_opts('Move lines down'))
map('n', '<M-k>', ":m-2<CR>==", desc_opts('Move line up'))
map('n', '<M-j>', ":m+1<CR>==", desc_opts('Move line down'))

-- Sort lines
map('v', '<leader>o', ':sort<CR>', desc_opts('Sort lines'))

-- Better terminal navigation
map('t', '<C-h>', '<C-\\><C-N><C-w>h', term_opts)
map('t', '<C-j>', '<C-\\><C-N><C-w>j', term_opts)
map('t', '<C-k>', '<C-\\><C-N><C-w>k', term_opts)
map('t', '<C-l>', '<C-\\><C-N><C-w>l', term_opts)

-- File tree
map('n', '<leader>e', ':Neotree toggle<CR>', desc_opts('Open file tree explorer'))
map('n', '<leader>o', ':Neotree focus<CR>', desc_opts('Focus file tree explorer'))

-- Fuzzy finder
local builtins = require 'telescope.builtin'
-- map('n', '<leader>f', function () builtins. end, desc_opts(''))
map('n', '<leader>fw', function () builtins.live_grep() end, desc_opts('Search words'))
map('n', '<leader>fW', function () builtins.live_grep({
  additional_args = function (args)
    return vim.list_extend(args, {
      '--hidden',
      '--no-ignore',
    })
  end,
}) end, desc_opts('Search words in all files'))
map('n', '<leader>ff', function () builtins.find_files() end, desc_opts('Search files'))
map('n', '<leader>fF', function () builtins.find_files {
  hidden = true,
  no_ignore = true,
} end, desc_opts('Search all files'))
map('n', '<leader>fb', function () builtins.buffers() end, desc_opts('Search buffers'))
map('n', '<leader>fh', function () builtins.hep_tags() end, desc_opts('Search help'))
map('n', '<leader>fo', function () builtins.oldfiles() end, desc_opts('Search file history'))
map('n', '<leader>fc', function () builtins.grep_string() end, desc_opts('Search word under cursor'))
map('n', '<leader>fr', function () builtins.registers() end, desc_opts('Search registers'))
map('n', '<leader>fk', function () builtins.keymaps() end, desc_opts('Search keymaps'))
map('n', '<leader>fm', function () builtins.commands() end, desc_opts('Search commands'))
map('n', '<leader>ls', function () builtins.lsp_document_symbols() end, desc_opts('Serach symbols'))
map('n', '<leader>lG', function () builtins.lsp_workspace_symbols() end, desc_opts('Search workspace symbols'))
map('n', '<leader>lR', function () builtins.lsp_references() end, desc_opts('Search references'))
map('n', '<leader>lD', function () builtins.diagnostics() end, desc_opts('Search diagnostics'))

-- Packer
map('n', '\\ps', ':PackerSync<CR>', desc_opts('Packer sync'))
map('n', '\\pS', ':PackerStatus<CR>', desc_opts('Packer status'))
map('n', '\\pu', ':PackerUpdate<CR>', desc_opts('Packer update'))

