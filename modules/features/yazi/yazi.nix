{ inputs, ... }: {
  flake.homeModules.yazi = { pkgs, ... }: {
    programs.yazi = {
      enable = true;
      enableFishIntegration = true;

      settings = {
        mgr = {
          show_hidden = true;
          sort_by = "natural";
        };

        # fixes the "lags when scrolling fast" feeling — yazi was decoding
        # and pushing an image preview to kitty for every file you skip
        # past. image_delay debounces that so fast j/k doesn't try to
        # render previews for files you're just flying over.
        preview = {
          image_delay = 100; # ms to wait before sending a preview to the terminal
          image_filter = "triangle"; # default quality/speed balance
          image_quality = 70; # slightly below default (75) for faster caching
        };
      };

      keymap = {
        mgr.prepend_keymap = [
          {
            on = ";";
            run = "plugin bunny";
            desc = "Start bunny.yazi";
          }
          {
            on = "g";
            run = "shell 'lazygit' --block";
            desc = "Open lazygit here";
          }
          {
            on = "<C-p>";
            run = "plugin command-palette";
            desc = "Fuzzy-search & run any keybind";
          }
        ];
      };

      plugins = {
        bunny = inputs.bunny-yazi;
        command-palette = inputs.command-palette-yazi;
      };

      initLua = ''
        require("bunny"):setup({
          hops = {
            { key = "~", path = "~", desc = "Home" },
            { key = "c", path = "~/.config", desc = "Config files" },
            { key = "n", path = "/nix/store", desc = "Nix store" },
            { key = "d", path = "~/Desktop", desc = "Desktop" },
            { key = "D", path = "~/Documents", desc = "Documents" },
          },
        })

        -- persistent keybind hint bar, bottom-right of the status line.
        -- press ~ (or F1) for the full searchable keybind list, or
        -- <C-p> for the fuzzy command-palette plugin.
        Status:children_add(function()
          return ui.Line({
            ui.Span(" ; "):fg("#0a0514"):bg("#a600ff"),
            ui.Span("hop "):fg("#c77dff"),
            ui.Span(" g "):fg("#0a0514"):bg("#a600ff"),
            ui.Span("git "):fg("#c77dff"),
            ui.Span(" ^p "):fg("#0a0514"):bg("#a600ff"),
            ui.Span("cmds "):fg("#c77dff"),
            ui.Span(" ~ "):fg("#0a0514"):bg("#a600ff"),
            ui.Span("help "):fg("#c77dff"),
          })
        end, 500, Status.RIGHT)
      '';

      theme = {
        mgr = {
          cwd = {
            fg = "#c77dff";
          };

          hovered = {
            fg = "#0a0514";
            bg = "#ff00c8";
          };
          preview_hovered = {
            underline = true;
          };

          find_keyword = {
            fg = "#f2e9ff";
            bold = true;
            italic = true;
          };
          find_position = {
            fg = "#ff00c8";
            bg = "reset";
            italic = true;
          };

          marker_copied = {
            fg = "#c77dff";
            bg = "#c77dff";
          };
          marker_cut = {
            fg = "#ff0044";
            bg = "#ff0044";
          };
          marker_marked = {
            fg = "#a600ff";
            bg = "#a600ff";
          };
          marker_selected = {
            fg = "#ff00c8";
            bg = "#ff00c8";
          };

          tab_active = {
            fg = "#0a0514";
            bg = "#a600ff";
          };
          tab_inactive = {
            fg = "#c77dff";
            bg = "#1a0530";
          };
          tab_width = 1;

          border_symbol = "│";
          border_style = {
            fg = "#4a3b6b";
          };

          syntect_theme = "";
        };

        mode = {
          normal_main = {
            fg = "#0a0514";
            bg = "#a600ff";
            bold = true;
          };
          normal_alt = {
            fg = "#a600ff";
            bg = "#1a0530";
          };

          select_main = {
            fg = "#0a0514";
            bg = "#ff00c8";
            bold = true;
          };
          select_alt = {
            fg = "#ff00c8";
            bg = "#1a0530";
          };

          unset_main = {
            fg = "#0a0514";
            bg = "#ff0044";
            bold = true;
          };
          unset_alt = {
            fg = "#ff0044";
            bg = "#1a0530";
          };
        };

        status = {
          overall = {
            fg = "#f2e9ff";
          };
          sep_left = {
            open = "";
            close = "";
          };
          sep_right = {
            open = "";
            close = "";
          };

          perm_type = {
            fg = "#c77dff";
          };
          perm_read = {
            fg = "#f2e9ff";
          };
          perm_write = {
            fg = "#ff00c8";
          };
          perm_exec = {
            fg = "#a600ff";
          };
          perm_sep = {
            fg = "#4a3b6b";
          };

          progress_label = {
            fg = "#f2e9ff";
            bold = true;
          };
          progress_normal = {
            fg = "#a600ff";
            bg = "#1a0530";
          };
          progress_error = {
            fg = "#ff0044";
            bg = "#1a0530";
          };
        };

        input = {
          border = {
            fg = "#ff00c8";
          };
          title = { };
          value = { };
          selected = {
            reversed = true;
          };
        };

        select = {
          border = {
            fg = "#ff00c8";
          };
          active = {
            fg = "#f2e9ff";
          };
          inactive = { };
        };

        tasks = {
          border = {
            fg = "#ff00c8";
          };
          title = { };
          hovered = {
            underline = true;
          };
        };

        which = {
          mask = {
            bg = "#0a0514";
          };
          cand = {
            fg = "#c77dff";
          };
          rest = {
            fg = "#4a3b6b";
          };
          desc = {
            fg = "#f2e9ff";
          };
          separator = "  ";
          separator_style = {
            fg = "#4a3b6b";
          };
        };

        confirm = {
          border = {
            fg = "#ff00c8";
          };
          title = { };
          content = { };
          list = { };
          btn_yes = {
            fg = "#0a0514";
            bg = "#a600ff";
          };
          btn_no = {
            fg = "#f2e9ff";
          };
        };

        notify = {
          title_info = {
            fg = "#c77dff";
          };
          title_warn = {
            fg = "#ff00c8";
          };
          title_error = {
            fg = "#ff0044";
          };
        };

        filetype = {
          rules = [
            {
              mime = "image/*";
              fg = "#c77dff";
            }
            {
              mime = "video/*";
              fg = "#ff00c8";
            }
            {
              mime = "audio/*";
              fg = "#a600ff";
            }
            {
              mime = "application/zip";
              fg = "#ff0044";
            }
            {
              mime = "application/x-tar";
              fg = "#ff0044";
            }
            {
              url = "*/";
              fg = "#a600ff";
              is_dir = true;
            }
          ];
        };
      };
    };
  };
}
