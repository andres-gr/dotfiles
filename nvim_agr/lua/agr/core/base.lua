local a = vim.api
local o = vim.opt
local w = vim.wo

-- Encodings
vim.scriptencoding = 'utf-8'
o.encoding = 'utf-8'
o.fileencoding = 'uft-8'

w.number = true

o.autoindent = true
o.backspace = o.backspace + { 'nostop' } -- Don't stop backspace at insert
o.backup = false
o.backupskip = { '/tmp/*', '/private/tmp/*' }
o.breakindent = true
o.clipboard = 'unnamedplus' -- Connection to the system clipboard
o.cmdheight = 1
o.completeopt = { 'menuone', 'noselect' } -- Options for insert mode completion
o.conceallevel = 0 -- so that `` is visible in markdown files
o.copyindent = true -- Copy the previous indentation on autoindenting
o.cursorline = true -- Highlight the text line of the cursor
o.expandtab = true -- Enable the use of space in tab
o.fillchars = { eob = ' ' } -- Disable `~` on nonexistent lines
o.formatoptions:append { 'r' } -- Add asterisks in block comments
o.history = 100 -- Number of commands to remember in a history table
o.hlsearch = true
o.ignorecase = true -- Case insensitive searching UNLESS /C or capital in search
o.inccommand = 'split'
o.laststatus = 3 -- globalstatus
o.lazyredraw = true -- lazily redraw screen
o.mouse = 'a' -- Enable mouse support
o.number = true -- Show numberline
o.numberwidth = 4 -- Set number column width {default 4}
o.path:append { '**' } -- Finding files - Search down into subfolders
o.preserveindent = true -- Preserve indent structure as much as possible
o.pumheight = 10 -- Height of the pop up menu
o.relativenumber = true -- Show relative numberline
o.scrolloff = 8 -- Number of lines to keep above and below the cursor
o.shell = 'zsh'
o.shiftwidth = 2 -- Number of space inserted for indentation
o.shortmess:append 'c' -- forget about swap file
o.showcmd = true
o.showmode = false -- Disable showing modes in command line
o.showtabline = 2 -- show tabline always
o.sidescrolloff = 8 -- Number of columns to keep at the sides of the cursor
o.signcolumn = 'yes' -- Always show the sign column
o.smartcase = true -- Case sensitivie searching
o.smartindent = true
o.smarttab = true
o.splitbelow = true -- Splitting a new window below the current one
o.splitright = true -- Splitting a new window at the right of the current one
o.swapfile = false -- Disable use of swapfile for the buffer
o.tabstop = 2 -- Number of space in a tab
o.termguicolors = true -- Enable 24-bit RGB color in the TUI
o.timeoutlen = 500 -- Length of time to wait for a mapped sequence
o.title = false
o.undofile = true -- Enable persistent undo
o.updatetime = 300 -- Length of time to wait before triggering the plugin
o.whichwrap:append '<,>,[,],h,l' -- Automatically wrap left or right
o.wildignore:append { '*/node_modules/*' }
o.wrap = false -- Disable wrapping of lines longer than the width of window
o.writebackup = false -- Disable making a backup before overwriting a file

-- Undercurl
-- vim.cmd [[ let &t_Cs = '\e[4:3m' ]]
-- vim.cmd [[ let &t_Ce = '\e[4:0m' ]]

-- Turn off paste mode when leaving insert
a.nvim_create_autocmd('InsertLeave', {
  pattern = '*',
  command = 'set nopaste'
})

-- Blinking cursor
vim.cmd [[ set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175 ]]

