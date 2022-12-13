{ config, pkgs, ... }:

let
  null-ls = pkgs.vimUtils.buildVimPluginFrom2Nix {
    name = "null-ls";
    src = pkgs.fetchFromGitHub {
      owner = "jose-elias-alvarez";
      repo = "null-ls.nvim";
      rev = "623cc25016647eb62392aead7612f27d539c33de";
      hash = "sha256-YUHT88JLXHpbHg1IIze3QTJaT4zpdVgyCt3ojk9osk8=";
    };
  };
  fidget = pkgs.vimUtils.buildVimPluginFrom2Nix {
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
      colorscheme gruvbox

      autocmd BufRead,BufNewFile *.hcl set filetype=hcl
      autocmd BufRead,BufNewFile *.tf,*.tfvars set filetype=terraform
    '';
    extraPackages = with pkgs; [
      mypy
      isort
      black
      nodePackages.cspell

      sumneko-lua-language-server
      python3Packages.jedi-language-server
      rust-analyzer
      gopls
      elmPackages.elm-language-server
      clang
      rnix-lsp
    ];
    plugins = with pkgs.vimPlugins; [
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      {
        plugin = nvim-cmp;
        type = "lua";
        config = ''
          local cmp = require('cmp')

          vim.cmd [[set completeopt=menu,menuone,noselect]]

          cmp.setup({
            snippet = {
              -- REQUIRED - you must specify a snippet engine
              expand = function(args)
                vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
                -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
                -- require'snippy'.expand_snippet(args.body) -- For `snippy` users.
              end,
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

          -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
          cmp.setup.cmdline('/', {
            sources = {
              { name = 'buffer' }
            }
          })

          -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
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
        plugin = nvim-treesitter;
        type = "lua";
        config = ''
          local treesitter = require('nvim-treesitter.configs')

          treesitter.setup {
            highlight = {
              enable = true,
              additional_vim_regex_highlighting = false,
            },
            indent = {
              enable = true,
            },
          }
        '';
      }
      null-ls
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
          end


          local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

          local lspcfg = require('lspconfig')
          local lsps = { 
            "gopls",
            "elmls",
            "rust_analyzer",
            "sumneko_lua",
            "tsserver",
            "clangd",
            "rnix",
            "jedi_language_server"
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


          local null_ls = require("null-ls")
          local null_ls_helpers = require("null-ls.helpers")
          local null_ls_utils = require("null-ls.utils")

          local isort = null_ls_helpers.make_builtin({
            name = "isort",
            method = null_ls.methods.FORMATTING,
            filetypes = { "python" },
            generator_opts = {
              command = "isort",
              args = {
                "--stdout",
                "--profile",
                "black",
                "-",
              },
              to_stdin = true,
              cwd = null_ls_helpers.cache.by_bufnr(function(params)
                return null_ls_utils.root_pattern(
                -- isort will detect files in the CWD as first-party
                -- https://pycqa.github.io/isort/docs/configuration/config_files.html
                  ".isort.cfg",
                  "pyproject.toml",
                  "setup.py",
                  "setup.cfg",
                  "tox.ini",
                  ".editorconfig"
                )(params.bufname)
              end),
            },
            factory = null_ls_helpers.formatter_factory,
          })

          local overrides = {
            severities = {
              error = null_ls_helpers.diagnostics.severities["error"],
              warning = null_ls_helpers.diagnostics.severities["warning"],
              note = null_ls_helpers.diagnostics.severities["information"],
            },
          }

          local quick_mypy = null_ls_helpers.make_builtin({
            name = "mypy",
            method = null_ls.methods.DIAGNOSTICS,
            filetypes = { "python" },
            generator_opts = {
              command = "mypy",
              args = function(params)
                local default_args = {
                  "--hide-error-codes",
                  "--hide-error-context",
                  "--no-color-output",
                  "--show-column-numbers",
                  "--show-error-codes",
                  "--no-error-summary",
                  "--no-pretty",
                  "--ignore-missing-imports",
                  "--follow-imports=skip",
                  "--shadow-file",
                  params.bufname,
                  params.temp_path,
                  params.bufname,
                }
                local config_file_path = vim.fs.find("mypy.toml", {
                  path = params.bufname,
                  upward = true,
                  stop = vim.fs.dirname(params.root),
                })[1]

                if config_file_path then
                  default_args = vim.list_extend({ "--config-file", config_file_path }, default_args)
                end

                return default_args
              end,
              to_temp_file = true,
              format = "line",
              check_exit_code = function(code)
                return code <= 2
              end,
              multiple_files = true,
              on_output = null_ls_helpers.diagnostics.from_patterns({
                -- see spec for pattern examples
                {
                  pattern = "([^:]+):(%d+):(%d+): (%a+): (.*)  %[([%a-]+)%]",
                  groups = { "filename", "row", "col", "severity", "message", "code" },
                  overrides = overrides,
                },
                -- no error code
                {
                  pattern = "([^:]+):(%d+):(%d+): (%a+): (.*)",
                  groups = { "filename", "row", "col", "severity", "message" },
                  overrides = overrides,
                },
                -- no column or error code
                {
                  pattern = "([^:]+):(%d+): (%a+): (.*)",
                  groups = { "filename", "row", "severity", "message" },
                  overrides = overrides,
                },
              }),
              cwd = null_ls_helpers.cache.by_bufnr(function(params)
                return null_ls_utils.root_pattern(
                -- https://mypy.readthedocs.io/en/stable/config_file.html
                  "mypy.ini",
                  "mypy.toml",
                  ".mypy.ini",
                  "pyproject.toml",
                  "setup.cfg"
                )(params.bufname)
              end),
            },
            factory = null_ls_helpers.generator_factory,
          })


          local black = null_ls_helpers.make_builtin({
            name = "black",
            method = null_ls.methods.FORMATTING,
            filetypes = { "python" },
            generator_opts = {
              command = "black",
              args = {
                "--quiet",
                "--fast",
                "-",
              },
              to_stdin = true,
            },
            factory = null_ls_helpers.formatter_factory,
          })


          local sources = {
            -- formatting
            null_ls.builtins.formatting.shfmt,
            isort,
            black,

            -- diagnostics
            null_ls.builtins.diagnostics.shellcheck.with {
              diagnostics_format = "#{m} [#{c}]",
            },
            null_ls.builtins.diagnostics.cspell.with {
              filetypes = { "python" }
            },

            quick_mypy.with({
              runtime_condition = function(params)
                return null_ls_utils.path.exists(params.bufname)
              end,
            }),

            -- code actions
            null_ls.builtins.code_actions.gitsigns,
            null_ls.builtins.code_actions.gitrebase,

            -- hover
            null_ls.builtins.hover.dictionary,

            -- completion
            null_ls.builtins.completion.tags,
          }

          null_ls.setup {
            debounce = 250,
            default_timeout = 60000,
            sources = sources,
            on_attach = on_attach,
            root_dir = null_ls_utils.root_pattern ".git",
          }
        '';
      }
      {
        plugin = vim-illuminate;
        type = "lua";
        config = ''
          require('illuminate').configure({
            -- providers: provider used to get references in the buffer, ordered by priority
            providers = {
              'lsp',
              'treesitter',
              'regex',
            },
            -- delay: delay in milliseconds
            delay = 100,
            -- filetype_overrides: filetype specific overrides.
            -- The keys are strings to represent the filetype while the values are tables that
            -- supports the same keys passed to .configure except for filetypes_denylist and filetypes_allowlist
            filetype_overrides = {},
            -- filetypes_denylist: filetypes to not illuminate, this overrides filetypes_allowlist
            filetypes_denylist = {
              'dirvish',
              'fugitive',
            },
            -- filetypes_allowlist: filetypes to illuminate, this is overriden by filetypes_denylist
            filetypes_allowlist = {},
            -- modes_denylist: modes to not illuminate, this overrides modes_allowlist
            -- See `:help mode()` for possible values
            modes_denylist = {},
            -- modes_allowlist: modes to illuminate, this is overriden by modes_denylist
            -- See `:help mode()` for possible values
            modes_allowlist = {},
            -- providers_regex_syntax_denylist: syntax to not illuminate, this overrides providers_regex_syntax_allowlist
            -- Only applies to the 'regex' provider
            -- Use :echom synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')
            providers_regex_syntax_denylist = {},
            -- providers_regex_syntax_allowlist: syntax to illuminate, this is overriden by providers_regex_syntax_denylist
            -- Only applies to the 'regex' provider
            -- Use :echom synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')
            providers_regex_syntax_allowlist = {},
            -- under_cursor: whether or not to illuminate under the cursor
            under_cursor = true,
            -- large_file_cutoff: number of lines at which to use large_file_config
            -- The `under_cursor` option is disabled when this cutoff is hit
            large_file_cutoff = nil,
            -- large_file_config: config to use for large files (based on large_file_cutoff).
            -- Supports the same keys passed to .configure
            -- If nil, vim-illuminate will be disabled for large files.
            large_file_overrides = nil,
            -- min_count_to_highlight: minimum number of matches required to perform highlighting
            min_count_to_highlight = 1,
          })
        '';
      }
    ];
  };
}

