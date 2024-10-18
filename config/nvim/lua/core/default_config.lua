local M = {}

M.options = {
  nvchad_branch = "v2.0",
}

M.ui = {
  ------------------------------- base46 -------------------------------------
  -- hl = highlights
  hl_add = {},
  hl_override = {},
  changed_themes = {},
  theme_toggle = { "onedark", "one_light" },
  theme = "onedark", -- default theme
  transparency = false,
  lsp_semantic_tokens = false, -- needs nvim v0.9, just adds highlight groups for lsp semantic tokens

  -- https://github.com/NvChad/base46/tree/v2.0/lua/base46/extended_integrations
  extended_integrations = {}, -- these aren't compiled by default, ex: "alpha", "notify"

  -- cmp themeing
  cmp = {
    icons = true,
    lspkind_text = true,
    style = "default", -- default/flat_light/flat_dark/atom/atom_colored
    border_color = "grey_fg", -- only applicable for "default" style, use color names from base30 variables
    selected_item_bg = "colored", -- colored / simple
  },

  telescope = { style = "borderless" }, -- borderless / bordered

  ------------------------------- nvchad_ui modules -----------------------------
  statusline = {
    theme = "default", -- default/vscode/vscode_colored/minimal
    -- default/round/block/arrow separators work only for default statusline theme
    -- round and block will work for minimal theme only
    separator_style = "default",
    overriden_modules = nil,
  },

  -- lazyload it when there are 1+ buffers
  tabufline = {
    show_numbers = false,
    enabled = true,
    lazyload = true,
    overriden_modules = nil,
  },

  -- nvdash (dashboard)
  nvdash = {
    load_on_startup = true,

    -- header = {
    --    '                        _..gggggppppp.._                       ',
    --    '                   _.gd$$$$$$$$$$$$$$$$$$bp._                  ',
    --    '                .g$$$$$$P^^""j$$b""""^^T$$$$$$p.               ',
    --    '             .g$$$P^T$$b    d$P T;       ""^^T$$$p.            ',
    --    '           .d$$P^"  :$; `  :$;                "^T$$b.          ',
    --    '         .d$$P\'      T$b.   T$b                  `T$$b.        ',
    --    '        d$$P\'      .gg$$$$bpd$$$p.d$bpp.           `T$$b       ',
    --    '       d$$P      .d$$$$$$$$$$$$$$$$$$$$bp.           T$$b      ',
    --    '      d$$P      d$$$$$$$$$$$$$$$$$$$$$$$$$b.          T$$b     ',
    --    '     d$$P      d$$$$$$$$$$$$$$$$$$P^^T$$$$P            T$$b    ',
    --    '    d$$P    \'-\'T$$$$$$$$$$$$$$$$$$bggpd$$$$b.           T$$b   ',
    --    '   :$$$      .d$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$p._.g.     $$$;  ',
    --    '   $$$;     d$$$$$$$$$$$$$$$$$$$$$$$P^"^T$$$$P^^T$$$;    :$$$  ',
    --    '  :$$$     :$$$$$$$$$$$$$$:$$$$$$$$$_    "^T$bpd$$$$,     $$$; ',
    --    '  $$$;     :$$$$$$$$$$$$$$bT$$$$$P^^T$p.    `T$$$$$$;     :$$$ ',
    --    ' :$$$      :$$$$$$$$$$$$$$P `^^^\'    "^T$p.    lb`TP       $$$;',
    --    ' :$$$      $$$$$$$$$$$$$$$              `T$$p._;$b         $$$;',
    --    ' $$$;      $$$$$$$$$$$$$$;                `T$$$$:Tb        :$$$',
    --    ' $$$;      $$$$$$$$$$$$$$$                        Tb    _  :$$$',
    --    ' :$$$     d$$$$$$$$$$$$$$$.                        $b.__Tb $$$;',
    --    ' :$$$  .g$$$$$$$$$$$$$$$$$$$p...______...gp._      :$`^^^\' $$$;',
    --    '  $$$;  `^^\'T$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$p.    Tb._, :$$$ ',
    --    '  :$$$       T$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$b.   "^"  $$$; ',
    --    '   $$$;       `$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$b      :$$$  ',
    --    '   :$$$        $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$;     $$$;  ',
    --    '    T$$b    _  :$$`$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$;   d$$P   ',
    --    '     T$$b   T$g$$; :$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$  d$$P    ',
    --    '      T$$b   `^^\'  :$$ "^T$$$$$$$$$$$$$$$$$$$$$$$$$$$ d$$P     ',
    --    '       T$$b        $P     T$$$$$$$$$$$$$$$$$$$$$$$$$;d$$P      ',
    --    '        T$$b.      \'       $$$$$$$$$$$$$$$$$$$$$$$$$$$$P       ',
    --    '         `T$$$p.   bug    d$$$$$$$$$$$$$$$$$$$$$$$$$$P\'        ',
    --    '           `T$$$$p..__..g$$$$$$$$$$$$$$$$$$$$$$$$$$P\'          ',
    --    '             "^$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$^"            ',
    --    '                "^T$$$$$$$$$$$$$$$$$$$$$$$$$$P^"               ',
    --    '                    """^^^T$$$$$$$$$$P^^^"""                   ',
    -- },

    header = {
      "⠀⠀     ⠀⠀ ⠀⠀⠀⠀⣀⣤⣴⣶⠾⡿⠿⠿⠿⠷⣶⣦⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀       ",
      "⠀     ⠀⠀ ⠀⠀⣠⣴⡿⣿⡛⠹⣇⣀⠀⡀⠀⠀⠀⠀⠀⠉⠛⢿⣦⣄⠀⠀⠀⠀⠀       ",
      "⠀⠀      ⠀⣠⣾⠟⣁⣤⣬⣽⣿⣿⣿⣿⣿⣿⣿⣷⣤⣄⠀⠀⠀⠈⠻⣷⣄⠀⠀⠀       ",
      "⠀⠀      ⣴⣿⢁⣾⣿⣿⣿⣿⣿⣿⣿⣿⣯⣭⣝⣿⣿⣟⠃⠀⠀⠀⠀⠈⢿⣦⠀⠀       ",
      "      ⠀⣼⡟⢈⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠛⠻⢿⣿⣷⣶⣤⣀⣄⠀⠀⢻⣧⠀       ",
      "      ⢰⣿⠀⣿⣿⣿⣿⣿⣿⣧⢿⣿⣿⠿⠟⠛⠶⣄⡀⠙⠿⣾⣿⣿⣿⠁⠀⠀⣿⡆       ",
      "      ⣾⡇⠀⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠈⠙⣶⣤⣀⣟⣯⡋⠀⠀⠀⢸⣷       ",
      "      ⣿⡇⢀⣿⣿⣿⣿⣿⣿⣿⣦⡀⠀⠀⠀⠀⠀⠀⣀⡀⠉⠉⠉⠈⣧⠀⠀⠠⣸⣿       ",
      "      ⢿⡇⠾⠟⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⣀⠹⣦⣀⡠⢻⡿       ",
      "      ⠸⣿⠀⠀⠈⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠙⠒⠒⣿⠇       ",
      "       ⢻⣧⠀⠀⢰⣿⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⣼⡟⠀       ",
      "        ⠻⣷⡐⠴⠏⠀⠿⠛⠻⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⣾⠟⠀⠀       ",
      "        ⠀⠙⢿⣦⣄⣀⠁⠀⠀⢀⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⠀⠀⠀       ",
      "  ⠀⠀⠀     ⠙⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠋⠀⠀⠀⠀⠀        ",
      "        ⠀⠀⠀⠀⠀⠀⠉⠛⠻⠿⢿⣿⣿⣿⣿⡿⠿⠟⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀       ",
      "                                           ",
      "aude, nam Jove est gladius et scutum tuum! "
    },

    buttons = {
      { "  Find File", "Spc f f", "Telescope find_files" },
      { "󰈚  Recent Files", "Spc f o", "Telescope oldfiles" },
      { "󰈭  Find Word", "Spc f w", "Telescope live_grep" },
      { "  Bookmarks", "Spc m a", "Telescope marks" },
      { "  Themes", "Spc t h", "Telescope themes" },
      { "  Mappings", "Spc c h", "NvCheatsheet" },
    },
  },

  cheatsheet = { theme = "grid" }, -- simple/grid

  lsp = {
    -- show function signatures i.e args as you type
    signature = {
      disabled = false,
      silent = true, -- silences 'no signature help available' message from appearing
    },
  },
}

M.plugins = "" -- path i.e "custom.plugins", so make custom/plugins.lua file

M.lazy_nvim = require "plugins.configs.lazy_nvim" -- config for lazy.nvim startup options

M.mappings = require "core.mappings"

return M
