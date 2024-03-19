local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities
local lspconfig = require ("lspconfig")
local util = require "lspconfig/util"
vim.lsp.set_log_level("debug")
lspconfig.pyright.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = {"python"}
})
lspconfig.zls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = {"zig"}
})
lspconfig.jdtls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = {"java"}
})
lspconfig.rust_analyzer.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = {"rust"},
  root_dir = util.root_pattern('Cargo.toml'),
  settings = {
    ['rust-analyzer'] = {
      cargo = {
        allFeatures = true,
      },
    },
  },
})
