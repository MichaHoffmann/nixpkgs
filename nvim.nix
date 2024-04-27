{ config, pkgs, ... }:

let
  fidget = pkgs.vimUtils.buildVimPlugin {
    name = "fidget";
    src = pkgs.fetchFromGitHub {
      owner = "j-hui";
      repo = "fidget.nvim";
      rev = "44585a0c0085765195e6961c15529ba6c5a2a13b";
      hash = "sha256-FC0vjzpFhXmE/dtQ8XNjLarndf9v3JbokBxnK3yVVYQ=";
    };
  };
in

{
  programs.neovim = {
    enable = true;
    extraConfig = ''
      set completeopt=menuone,noinsert,noselect
      set shortmess+=c
      set shortmess-=F

      set nu
      set tabstop=2
      set shiftwidth=2
      set expandtab
      set colorcolumn=100
      set nofoldenable

      autocmd BufRead,BufNewFile *.promql set filetype=promql
      autocmd BufRead,BufNewFile *.hcl set filetype=hcl
      autocmd BufRead,BufNewFile *.tf,*.tfvars set filetype=terraform
    '';
    extraLuaConfig = ''
      vim.loader.enable()

      vim.opt.foldmethod = "expr"
      vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
    '';
    extraPackages = with pkgs; [
      # tree-sitter compiler
      zig

      # rust
      cargo
      rust-analyzer

      # golang
      go
      gopls

      # nix
      rnix-lsp
      statix

      # ocaml
      ocamlPackages.ocaml-lsp
      ocamlPackages.dune_3
      ocamlPackages.ocamlformat

      # js
      nodePackages.typescript-language-server

      # jsonnet
      jsonnet-language-server
    ];
    plugins = with pkgs.vimPlugins; [
      playground
      {
        plugin = tokyonight-nvim;
        type = "lua";
        config = ''
          vim.cmd[[colorscheme tokyonight-storm]]
        '';
      }
      {
        plugin = nvim-treesitter;
        type = "lua";
        config = ''

          local treesitter = require('nvim-treesitter.configs')
          local parser_config = require "nvim-treesitter.parsers".get_parser_configs()

          vim.opt.runtimepath:append("/var/home/mhoffm/.config/nvim/parsers")
          treesitter.setup {
            parser_install_dir = "/var/home/mhoffm/.config/nvim/parsers",
            highlight = {
              enable = true,
              additional_vim_regex_highlighting = false,
            },
            indent = {
              enable = true,
            },
            compilers = {"zig"},
          }
        '';
      }
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      cmp_luasnip
      luasnip
      {
        plugin = nvim-cmp;
        type = "lua";
        config = ''
          local cmp = require('cmp')

          cmp.setup({
            snippet = {
              expand = function(args)
                require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
              end,
            },
            window = {
              completion = cmp.config.window.bordered(),
              documentation = cmp.config.window.bordered(),
            },
            mapping = {
              ['<CR>'] = cmp.mapping.confirm({ select = true }),
              ['<Down>'] = cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }), { 'i' }),
              ['<Up>'] = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }), { 'i' }),
            },
            sources = cmp.config.sources({
              { name = 'nvim_lsp' },
            }, {
              { name = 'buffer' },
            })
          })

          cmp.setup.cmdline('/', {
            sources = {
              { name = 'buffer' }
            }
          })

          cmp.setup.cmdline(':', {
            sources = cmp.config.sources({
              { name = 'path' }
            }, {
              { name = 'cmdline' }
            })
          })
    
        '';
      }
      {
        plugin = fidget;
        type = "lua";
        config = ''require("fidget").setup({})'';
      }
      {
        plugin = vim-startify;
        config = "let g:startify_change_to_vcs_root = 0";
      }
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = ''
          local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
          local on_attach = function(client, bufnr)
            vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
              vim.lsp.diagnostic.on_publish_diagnostics, {
              virtual_text = {
                spacing = 4,
                prefix = '~',
              },
              underline = true,
              signs = true,
              update_in_insert = true,
            })

            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
            vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
              group = augroup,
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({ bufnr = bufnr, timeout_ms = 10000 })
              end,
            })
            vim.cmd [[nnoremap <silent> <c-]> <cmd> lua vim.lsp.buf.definition() <CR>]]
            vim.cmd [[nnoremap <silent> K <cmd> lua vim.lsp.buf.hover() <CR>]]
            vim.cmd [[nnoremap <silent> gD <cmd> lua vim.lsp.buf.implementation() <CR>]]
            vim.cmd [[nnoremap <silent> E <cmd> lua vim.diagnostic.open_float(0, {scope="line"})<CR>]]
          end

          local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

          local lspcfg = require('lspconfig')
          local lsps = { 
            "gopls",
            "rust_analyzer",
            "tsserver",
            "rnix",
            "ocamllsp",
            "jsonnet_ls"
          }

          for i in pairs(lsps) do
            lspcfg[lsps[i]].setup {
              on_attach = on_attach,
              flags = {
                debounce_text_changes = 150,
              },
              capabilities = capabilities
            }
          end
        '';
      }
    ];
  };
}

