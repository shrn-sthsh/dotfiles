---@type ChadrcConfig
local M = {}

M.ui = {
  -- Themes
  theme = 'falcon',
  theme_toggle = { "falcon", "oxocarbon" },
  transparency = false,

---@diagnostic disable-next-line: missing-fields
 changed_themes = {
---@diagnostic disable-next-line: missing-fields
    falcon = {
---@diagnostic disable-next-line: missing-fields
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
vim.opt.foldmethod = "syntax"

-- Terminal color options
vim.opt.termguicolors = true

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

-- File indenting
vim.api.nvim_create_autocmd(
  { "BufReadPost", "BufNewFile" },
  {
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

-- local function get_fullscreen_status()
--   local handle = io.popen("swaymsg -t get_tree")
--
--   -- Check if the handle was successfully created
--   if handle == nil then
--     vim.notify("Error: Failed to execute swaymsg command", vim.log.levels.ERROR)
--     return false  -- Return false if the command failed
--   end
--
--   local result = handle:read("*a")
--   handle:close()
--
--   -- Print the swaymsg result to debug if needed
--   -- vim.notify("swaymsg result: " .. result, vim.log.levels.INFO)
--
--   -- Check if foot terminal is in fullscreen mode
--   if result:match('"app_id": "foot"') and result:match('"fullscreen_mode": 1') then
--     vim.notify("Foot terminal is in fullscreen mode", vim.log.levels.INFO)
--     return true
--   else
--     vim.notify("Foot terminal is NOT in fullscreen mode", vim.log.levels.INFO)
--   end
--
--   return false
-- end
--
-- local function get_screen_dimensions()
--   local handle = io.popen("swaymsg -t get_outputs")
--   if not handle then
--     vim.notify("Error: Failed to execute swaymsg for outputs", vim.log.levels.ERROR)
--     return 0, 0  -- Default values if the command fails
--   end
--
--   local screen_output = handle:read("*a")
--   handle:close()
--
--   local screen_width, screen_height = 0, 0
--   for line in screen_output:gmatch("[^\r\n]+") do
--     local width, height = line:match('"width": (%d+), "height": (%d+)')
--     if width and height then
--       screen_width = tonumber(width)
--       screen_height = tonumber(height)
--       vim.notify("Screen dimensions: " .. screen_width .. "x" .. screen_height, vim.log.levels.INFO)
--       break  -- Use the first output for the screen dimensions
--     end
--   end
--
--   return screen_width, screen_height
-- end
--
-- local function get_window_dimensions()
--   local handle = io.popen("swaymsg -t get_tree | grep -A 10 'app_id: \"foot\"'")
--   if not handle then
--     vim.notify("Error: Failed to execute swaymsg for window dimensions", vim.log.levels.ERROR)
--     return 0, 0  -- Default values if the command fails
--   end
--
--   local window_output = handle:read("*a")
--   handle:close()
--
--   local window_width, window_height = 0, 0
--   for line in window_output:gmatch("[^\r\n]+") do
--     local width, height = line:match('"width": (%d+), "height": (%d+)')
--     if width and height then
--       window_width = tonumber(width)
--       window_height = tonumber(height)
--       vim.notify("Window dimensions: " .. window_width .. "x" .. window_height, vim.log.levels.INFO)
--       break  -- Use the first match for the terminal dimensions
--     end
--   end
--
--   return window_width, window_height
-- end
--
-- local function is_window_fullscreen()
--   local screen_width, screen_height = get_screen_dimensions()
--   local window_width, window_height = get_window_dimensions()
--
--   -- Check if the window dimensions match the screen dimensions
--   local fullscreen = window_width == screen_width and window_height == screen_height
--   vim.notify("Is window fullscreen: " .. tostring(fullscreen), vim.log.levels.INFO)
--   return fullscreen
-- end
--
--
-- local function set_transparency()
--   if is_window_fullscreen() then
--     vim.notify("Setting transparency to 0", vim.log.levels.INFO)
--     vim.opt.winblend = 0
--   else
--     vim.notify("Setting transparency to 20", vim.log.levels.INFO)
--     vim.opt.winblend = 20
--   end
-- end
--
-- -- Set autocommands to trigger when resizing or focus changes
-- vim.api.nvim_create_autocmd({"FocusGained", "VimResized"}, {
--   callback = function()
--     vim.notify("Autocommand triggered", vim.log.levels.INFO)
--     set_transparency()
--   end
-- })
--
-- -- Check and set transparency after startup
-- vim.api.nvim_create_autocmd("VimEnter", {
--   callback = function()
--     set_transparency()
--   end,
-- })
--
-- -- Optionally also adjust transparency on focus change or resize events
-- vim.api.nvim_create_autocmd({"FocusGained", "VimResized"}, {
--   callback = set_transparency
-- })

return M
