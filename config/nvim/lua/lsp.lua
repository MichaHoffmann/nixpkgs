local on_attach = function(_)
  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = {
      spacing = 4,
      prefix = '~',
    },
    underline = true,
    signs = true,
    update_in_insert = true,
  }
  )

  vim.cmd [[nnoremap <silent> <c-]> <cmd> lua vim.lsp.buf.definition() <CR>]]
  vim.cmd [[nnoremap <silent> K <cmd> lua vim.lsp.buf.hover() <CR>]]
  vim.cmd [[nnoremap <silent> gD <cmd> lua vim.lsp.buf.implementation() <CR>]]
end


-- Setup lspconfig.
require("fidget").setup {}
require("mason").setup()
require("mason-lspconfig").setup({ automatic_installation = true })

local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

local lspcfg = require('lspconfig')
lspcfg["pylsp"].setup {
  on_attach = on_attach,
  flags = {
    debounce_text_changes = 150,
  },
  capabilities = capabilities,
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = {
          enabled = true,
          maxLineLength = 125,
        },
        flake = {
          enabled = true,
        },
        pylint = {
          enabled = true,
        }
      }
    }
  }
}

-- non python lsps
local lsps = { "gopls", "elmls", "rust_analyzer", "sumneko_lua", "tsserver", "clangd", "rnix", "hls"}

for i in pairs(lsps) do
  lspcfg[lsps[i]].setup {
    on_attach = function(client)
      on_attach(client)

      vim.cmd [[augroup Format]]
      vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.formatting_sync()]]
      vim.cmd [[augroup END]]

    end,
    flags = {
      debounce_text_changes = 150,
    },
    capabilities = capabilities
  }
end
