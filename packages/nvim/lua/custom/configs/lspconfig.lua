local base = require("plugins.configs.lspconfig")
local on_attach = base.on_attach
local capabilities = base.capabilities

local lspconfig = require("lspconfig")

-- Bash 
lspconfig.bashls.setup {
  on_attach = function (client, bufnr)
    on_attach(client, bufnr)
  end,
  capabilities = capabilities
}

-- C/C++/C# 
lspconfig.clangd.setup {
  on_attach = function (client, bufnr)
    on_attach(client, bufnr)
  end,
  capabilities = capabilities
}

lspconfig.cmake.setup {
  on_attach = function (client, bufnr)
    on_attach(client, bufnr)
  end,
  capabilities = capabilities
}

-- Python 
lspconfig.pyright.setup {
  on_attach = function (client, bufnr)
    on_attach(client, bufnr)
  end,
  capabilities = capabilities
}

-- Markdown & Text
lspconfig.ltex.setup {
  on_attach = function (client, bufnr)
    on_attach(client, bufnr)
  end,
  capabilities = capabilities
}
