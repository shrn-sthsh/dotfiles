---@type ChadrcConfig
local M = {}

M.ui = {
  -- Themes
  theme = 'falcon',
  theme_toggle = { "falcon", "oxocarbon" },
  transparency = true,

 changed_themes = {
    falcon = {
      base_30 = {
        -- black = "#ffffff", -- status bar text
        -- one_bg = "#ffffff", -- status bar icon
        -- one_bg2 = "#202040", -- file tree break & level highlight
        -- one_bg3 = "#ffffff",
        grey = "#B4B4B9", -- line number & LSP definition box
        grey_fg = "#DFDFE5", -- comments & LSP variables & functions
        -- grey_fg2 = "#ffffff",
      },
    },
  },

  -- Italicize comments
  hl_override = {
    Comment = { italic = true },
    ["@comment"] = { italic = true },
  },
}

M.plugins = "custom.plugins"

-- Folds based on syntax
vim.api.nvim_set_option("foldmethod", "syntax")

-- Terminal color options
vim.api.nvim_set_option("termguicolors", true)

-- Increase highlighted text timeout
vim.api.nvim_create_autocmd(
  "TextYankPost", {
    group = vim.api.nvim_create_augroup("highlight_yank", {}),
    desc = "Highlight selection on yank",
    pattern = "*",
    callback = function()
      vim.highlight.on_yank { higroup = "IncSearch", timeout = 1000 }
    end,
  }
)

-- Language based indenting
vim.api.nvim_create_autocmd(
  "FileType", {
    pattern = {"cpp", "py"},
    callback = function()
      vim.opt.shiftwidth = 4
      vim.opt.tabstop = 4
      vim.opt.softtabstop = 4
    end
  }
)

vim.api.nvim_create_autocmd(
  "FileType", {
    pattern = "sh",
    callback = function()
      vim.opt.shiftwidth = 2
      vim.opt.tabstop = 2
      vim.opt.softtabstop = 2
    end
  }
)

return M
