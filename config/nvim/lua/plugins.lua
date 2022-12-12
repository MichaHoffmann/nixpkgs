return require('packer').startup(function()
  use { 'wbthomason/packer.nvim' }

  -- treesitter config
  use {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      require('nvim-treesitter.install').update({ with_sync = true })()
    end,
  }
  use { 'nvim-treesitter/playground' }

  -- lsp config
  use { 'neovim/nvim-lspconfig' }
  use { 'hrsh7th/cmp-nvim-lsp' }
  use { 'hrsh7th/cmp-buffer' }
  use { 'hrsh7th/cmp-path' }
  use { 'hrsh7th/cmp-cmdline' }
  use { 'hrsh7th/nvim-cmp' }
  use { 'hrsh7th/vim-vsnip' }
  use { 'hrsh7th/vim-vsnip-integ' }
  use { 'williamboman/mason.nvim' }
  use { 'williamboman/mason-lspconfig.nvim' }
  use { 'j-hui/fidget.nvim' }
  use { 'jose-elias-alvarez/null-ls.nvim' }


  -- telescope for searching and navigation
  use {
    'nvim-telescope/telescope.nvim',
    requires = { { 'nvim-lua/popup.nvim' }, { 'nvim-lua/plenary.nvim' }
    }
  }

  -- random stuff
  use { 'RRethy/vim-illuminate' }

  -- some themes
  use { "ellisonleao/gruvbox.nvim" }
  use { 'sainnhe/everforest' }

end)
