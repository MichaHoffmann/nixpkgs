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


-- Setup lspconfig.
require("fidget").setup()
require("mason").setup()
require("mason-lspconfig").setup({ automatic_installation = true })

local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

local lspcfg = require('lspconfig')
local lsps = { "gopls", "elmls", "rust_analyzer", "sumneko_lua", "tsserver", "clangd", "rnix" }

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
  meta = {
    url = "https://github.com/PyCQA/isort",
    description = "Python utility / library to sort imports alphabetically and automatically separate them into sections and by type.",
  },
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
  meta = {
    url = "https://github.com/python/mypy",
    description = [[Mypy is an optional static type checker for Python that aims to combine the
benefits of dynamic (or "duck") typing and static typing.]],
  },
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
  meta = {
    url = "https://github.com/psf/black",
    description = "The uncompromising Python code formatter",
  },
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
