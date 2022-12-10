require('plugins')
require('treesitter')
require('lsp')
require('completion')

vim.cmd [[set completeopt=menuone,noinsert,noselect]]
vim.cmd [[set shortmess+=c]]
vim.cmd [[set shortmess-=F]]

vim.cmd [[set nu]]
vim.cmd [[set tabstop=2]]
vim.cmd [[set shiftwidth=2]]
vim.cmd [[set expandtab]]
vim.cmd [[set colorcolumn=100]]
vim.cmd [[colorscheme gruvbox]]
