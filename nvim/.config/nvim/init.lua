-- Leader key -> " "
--
-- In general, it's a good idea to set this early in your config, because otherwise
-- if you have any mappings you set BEFORE doing this, they will be set to the OLD
-- leader.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require('bootstrap')
require('deps')

vim.g.solarized_termcolors = 256
vim.o.background = 'dark'
vim.cmd [[colorscheme solarized]]