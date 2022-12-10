local parser_config = require('nvim-treesitter.configs')

parser_config.setup {
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
}
