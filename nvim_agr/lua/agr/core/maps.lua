local keymap = require 'agr.core.utils'.keymap

local map = keymap.map
local opts = keymap.opts
local desc_opts = function (desc)
  return keymap:desc_opts(desc)
end
local term_opts = { silent = true }
local all = {
  '',
  '!',
  't',
}

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
-- map('n', '<C-h>', '<C-w>h', desc_opts('Move to left window'))
-- map('n', '<C-j>', '<C-w>j', desc_opts('Move to lower window'))
-- map('n', '<C-k>', '<C-w>k', desc_opts('Move to upper window'))
-- map('n', '<C-l>', '<C-w>l', desc_opts('Move to right window'))

-- Resize with arrows
map('n', '<C-Up>', '<CMD>resize -2<CR>', desc_opts('Resize window up'))
map('n', '<C-Down>', '<CMD>resize +2<CR>', desc_opts('Resize window down'))
map('n', '<C-Left>', '<CMD>vertical resize -2<CR>', desc_opts('Resize window left'))
map('n', '<C-Right>', '<CMD>vertical resize +2<CR>', desc_opts('Resize window right'))

-- Navigate buffers
map('n', '<M-l>', '<CMD>BufferLineCycleNext<CR>', desc_opts('Go to next buffer'))
map('n', '<M-h>', '<CMD>BufferLineCyclePrev<CR>', desc_opts('Go to previous buffer'))
map('n', '<leader>>', '<CMD>BufferLineMoveNext<CR>', desc_opts('Move buffer right'))
map('n', '<leader><', '<CMD>BufferLineMovePrev<CR>', desc_opts('Move buffer left'))

-- File actions
map('n', '\\c', '<CMD>Bdelete<CR>', desc_opts('Close current buffer'))
map('n', '\\C', '<CMD>Bdelete!<CR>', desc_opts('Close w/force current buffer'))
map('n', '\\w', '<CMD>w!<CR>', desc_opts('Save current file'))
map('n', '\\q', '<CMD>q<CR>', desc_opts('Quit'))
map('n', '\\Q', '<CMD>q!<CR>', desc_opts('Quit w/force'))
map('n', '<leader>q', '<CMD>q<CR>', desc_opts('Quit'))
map('n', '<leader>Q', '<CMD>q!<CR>', desc_opts('Quit w/force'))
map('n', '<leader>z', '<CMD>Bdelete<CR>', desc_opts('Close current buffer'))
map('n', '<leader>Z', '<CMD>Bdelete!<CR>', desc_opts('Close w/force current buffer'))
map('n', '\\t', '<CMD>windo bd<CR>', desc_opts('Quit window tab'))

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
map('x', 'p', 'P', desc_opts('Paste without replace in visual'))
map('x', 'P', 'p', desc_opts('Regular paste with replace in visual'))

-- Center navigation
map('n', 'N', [[<CMD>execute('normal! ' . v:count1 . 'N')<CR><CMD>lua require('hlslens').start()<CR>zz]], desc_opts('Center search backwards'))
map('n', 'n', [[<CMD>execute('normal! ' . v:count1 . 'n')<CR><CMD>lua require('hlslens').start()<CR>zz]], desc_opts('Center search forwards'))
map('n', '#', [[#<CMD>lua require('hlslens').start()<CR>zz]], desc_opts('Center prev cursor word'))
map('n', '*', [[*<CMD>lua require('hlslens').start()<CR>zz]], desc_opts('Center next cursor word'))
map('n', 'g#', [[g#<CMD>lua require('hlslens').start()<CR>zz]], desc_opts('Center prev cursor word'))
map('n', 'g*', [[g*<CMD>lua require('hlslens').start()<CR>zz]], desc_opts('Center next cursor word'))
map('n', '<C-u>', '<C-u>zz', desc_opts('Center half page up'))
map('n', '<C-d>', '<C-d>zz', desc_opts('Center half page down'))

-- Better indents
map('v', '<', '<gv', desc_opts('Indent left'))
map('v', '>', '>gv', desc_opts('Indent right'))
map('n', '<', 'v<', desc_opts('Indent left'))
map('n', '>', 'v>', desc_opts('Indent right'))

-- Cancel search highlight
map('n', '<leader>n', '<CMD>nohlsearch<Bar>:echo<CR>', desc_opts('Clear search highlight'))
map('n', '<ESC>', '<CMD>nohlsearch<Bar>:echo<CR>', desc_opts('Clear search highlight'))

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
map('n', '<leader>v', '<CMD>Neotree toggle<CR>', desc_opts('Open file tree explorer'))
map('n', '<leader>o', '<CMD>Neotree focus<CR>', desc_opts('Focus file tree explorer'))

-- Lazy
map('n', '<leader>pS', '<CMD>Lazy sync<CR>', desc_opts('Lazy sync'))
map('n', '<leader>ps', '<CMD>Lazy<CR>', desc_opts('Lazy status'))
map('n', '<leader>pU', '<CMD>Lazy update<CR>', desc_opts('Lazy update'))
map('n', '<leader>pc', '<CMD>Lazy check<CR>', desc_opts('Lazy check for updates'))

-- Git fugitive
map('n', '<leader>Gl', '<CMD>0Gllog<CR>', desc_opts('Git show file history'))

-- Git time lapse
map('n', '<leader>Gt', '<CMD>GitTimeLapse<CR>', desc_opts('Git show file time lapse'))

-- Dash
map('n', '<leader>a', '<CMD>Alpha<CR>', desc_opts('Show dashboard'))

-- LSP Installer
map('n', '<leader>pi', '<CMD>Mason<CR>', desc_opts('Mason installer'))
map('n', '<leader>li', '<CMD>LspInfo<CR>', desc_opts('LSP info'))

-- Symbols outline
map('n', '<leader>lS', '<CMD>AerialToggle<CR>', desc_opts('Symbols outline'))

-- Better motion
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
map('n', '<leader><leader>qs', function () require('persistence').load() end, desc_opts('Restore session'))
map('n', '<leader><leader>ql', function () require('persistence').load { last = true } end, desc_opts('Restore last session'))
map('n', '<leader><leader>qd', function () require('persistence').stop() end, desc_opts('Don\'t save current session'))

-- Undo history
map('n', '<leader>u', '<CMD>UndotreeToggle<CR>', desc_opts('Toggle undo history'))

-- Color picker
map('n', '<leader><leader>co', '<CMD>CccPick<CR>', desc_opts('Replace color'))
map('n', '<leader><leader>cv', '<CMD>CccConvert<CR>', desc_opts('Convert color'))
map('n', '<leader><leader>cc', '<CMD>CccHighlighterToggle<CR>', desc_opts('Show color highlights'))
