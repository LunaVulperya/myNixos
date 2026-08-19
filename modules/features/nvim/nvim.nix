{ ... }: {
  flake.homeModules.nvim = { pkgs, ... }: {
    home.packages = with pkgs; [
      # core tools LazyVim/telescope expect on PATH
      ripgrep
      fd
      gcc
      nodejs

      # ── LSP servers (replaces Mason auto-install) ──────────────
      lua-language-server
      nil                                    # nix
      rust-analyzer                          # rust
      pyright                                # python
      typescript-language-server             # typescript (top-level, pkgs-by-name)
      vscode-langservers-extracted           # json/html/css (top-level, pkgs-by-name)
      # NOTE: vscode-langservers-extracted has an open nixpkgs issue
      # (#531366) where its servers fail to launch with an ESM
      # "require is not defined" error on some unstable revisions.
      # If jsonls/html/css LSP breaks, that's the likely cause —
      # check the issue for a fix or swap to an alternative JSON LSP.

      # ── formatters ──────────────────────────────────────────────
      stylua                                 # lua
      alejandra                              # nix
      ruff                                   # python (formatter + linter)
      rustfmt                                # rust
      prettier                               # ts/json/etc (top-level)

      # ── linters ─────────────────────────────────────────────────
      eslint                                 # top-level
    ];

    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };

    xdg.configFile = {
      "nvim/init.lua".text = ''
        vim.g.mapleader = " "
        vim.g.maplocalleader = "\\"

        local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
        if not vim.loop.fs_stat(lazypath) then
          vim.fn.system({
            "git", "clone", "--filter=blob:none",
            "https://github.com/folke/lazy.nvim.git",
            "--branch=stable", lazypath,
          })
        end
        vim.opt.rtp:prepend(lazypath)

        require("config.lazy")
      '';

      "nvim/lua/config/options.lua".text = ''
        local opt = vim.opt

        -- mouse, fully on, in every mode
        opt.mouse = "a"
        opt.mousemodel = "popup_setpos"
        opt.mousescroll = "ver:3,hor:6"

        -- system clipboard integration (works with wl-clipboard on niri/Wayland)
        opt.clipboard = "unnamedplus"

        opt.number = true
        opt.relativenumber = true
        opt.termguicolors = true
        opt.signcolumn = "yes"
        opt.scrolloff = 8
      '';

      "nvim/lua/config/lazy.lua".text = ''
        require("lazy").setup({
          spec = {
            { "LazyVim/LazyVim", import = "lazyvim.plugins" },

            -- AstroNvim-equivalent batteries
            { import = "lazyvim.plugins.extras.ui.mini-animate" },
            { import = "lazyvim.plugins.extras.editor.mini-files" },
            { import = "lazyvim.plugins.extras.editor.dashboard-nvim" },
            { import = "lazyvim.plugins.extras.dap.core" },
            { import = "lazyvim.plugins.extras.test.core" },
            { import = "lazyvim.plugins.extras.coding.mini-surround" },
            { import = "lazyvim.plugins.extras.coding.yanky" },
            { import = "lazyvim.plugins.extras.formatting.prettier" },
            { import = "lazyvim.plugins.extras.linting.eslint" },

            -- language presets (LSP/formatter binaries come from Nix, not Mason)
            { import = "lazyvim.plugins.extras.lang.typescript" },
            { import = "lazyvim.plugins.extras.lang.json" },
            { import = "lazyvim.plugins.extras.lang.python" },
            { import = "lazyvim.plugins.extras.lang.rust" },
            { import = "lazyvim.plugins.extras.lang.nix" },

            { import = "plugins" },
          },
          defaults = { lazy = false, version = false },
          install = { colorscheme = { "tokyonight", "habamax" } },
          checker = { enabled = true },
        })
      '';

      "nvim/lua/plugins/theme.lua".text = ''
        return {
          { "folke/tokyonight.nvim", opts = { style = "storm" } },
          { "LazyVim/LazyVim", opts = { colorscheme = "tokyonight" } },
        }
      '';

      "nvim/lua/plugins/breadcrumbs.lua".text = ''
        return {
          {
            "Bekaboo/dropbar.nvim",
            event = "BufReadPost",
            config = function()
              require("dropbar").setup()
            end,
          },
        }
      '';

      # ── disable Mason entirely ──────────────────────────────────
      # all LSP servers / formatters / linters above come from Nix
      # (home.packages), pinned in flake.lock, built at rebuild time.
      # nvim-lspconfig's default server definitions just call the
      # binary name (e.g. "rust-analyzer") — which now resolves to
      # the Nix store path already on $PATH, so no per-server `cmd`
      # overrides are needed.
      "nvim/lua/plugins/disable-mason.lua".text = ''
        return {
          { "williamboman/mason.nvim", enabled = false },
          { "williamboman/mason-lspconfig.nvim", enabled = false },
          { "WhoIsSethDaniel/mason-tool-installer.nvim", enabled = false },
        }
      '';
    };
  };
}
