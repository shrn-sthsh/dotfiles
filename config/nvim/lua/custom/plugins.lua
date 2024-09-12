local plugins = {
  {
    "jose-elias-alvarez/null-ls.nvim",
    event = "VeryLazy",
    opts = function ()
     return require "custom.configs.null-ls"
    end,
  },

  {
    "neovim/nvim-lspconfig",
    config = function ()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end
  },

  {
     "amitds1997/remote-nvim.nvim",
     version = "*", -- Pin to GitHub releases
     dependencies = {
         "nvim-lua/plenary.nvim", -- For standard functions
         "MunifTanjim/nui.nvim", -- To build the plugin UI
         "nvim-telescope/telescope.nvim", -- For picking b/w different remote methods
     },
     config = true,
  },

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- Lua server
        "lua-language-server",

        -- Bash server
        "bash-language-server",

        -- Python3 server
        "pyright",

        -- C/C++/C# server and tools
        "cmake-language-server",
        "codelldb",
        "clang-format",
        "clangd",

        -- Markdown & text server
        "ltex-ls",
      }
    }
  }
}

return plugins
