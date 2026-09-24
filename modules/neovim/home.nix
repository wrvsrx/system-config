{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.my_config.neovim;
in
{
  imports = [ ./options.nix ];

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nodejs
      efm-langserver
      tree-sitter
      # Provides inotifywait; Neovim's LSP file watcher uses it on Linux when
      # workspace/didChangeWatchedFiles is explicitly enabled.
      inotify-tools
      lazygit
    ];
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withPython3 = true;
      withNodeJs = true;
      withRuby = false;

      # Initial Lua configuration
      initLua =
        # lua
        ''
          if vim.env.PROF then
            local snacks = '${pkgs.vimPlugins.snacks-nvim}'
            vim.opt.rtp:append(snacks)
            require("snacks.profiler").startup({})
          end

          -- Load custom init.lua
          ${builtins.readFile ./init.lua}
        '';

      plugins = with pkgs.vimPlugins; [
        lz-n
        {
          plugin = auto-session;
          type = "lua";
          config = ''
            vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'

            require('auto-session').setup({
              suppressed_dirs = { vim.fn.expand('~/'), '/' },
              session_lens = {
                picker = 'snacks',
              },
            })

            vim.keymap.set('n', '<leader>qs', '<cmd>AutoSession search<cr>', { desc = 'Search Sessions' })
            vim.keymap.set('n', '<leader>qS', '<cmd>AutoSession save<cr>', { desc = 'Save Session' })
            vim.keymap.set('n', '<leader>qr', '<cmd>AutoSession restore<cr>', { desc = 'Restore Session' })
            vim.keymap.set('n', '<leader>qd', '<cmd>AutoSession delete<cr>', { desc = 'Delete Session' })
            vim.keymap.set('n', '<leader>qt', '<cmd>AutoSession toggle<cr>', { desc = 'Toggle Session Autosave' })
          '';
        }
        # Snacks.nvim - core UI and utility functions
        {
          plugin = snacks-nvim;
          type = "lua";
          config = ''
            require('snacks').setup({
              indent = { enabled = true },
              notifier = { enabled = true },
              input = { enabled = true },
              -- enable picker to get better vim.ui.select
              picker = { enabled = true },
            })

            -- Keymaps for snacks
            local function map(mode, lhs, rhs, opts)
              vim.keymap.set(mode, lhs, rhs, opts or {})
            end

            -- Top Pickers & Explorer
            map("n", "<leader><space>", function() require('snacks').picker.smart() end, { desc = "Smart Find Files" })
            map("n", "<leader>,", function() require('snacks').picker.buffers() end, { desc = "Buffers" })
            map("n", "<leader>/", function() require('snacks').picker.grep() end, { desc = "Grep" })
            map("n", "<leader>:", function() require('snacks').picker.command_history() end, { desc = "Command History" })
            map("n", "<leader>e", function() require('snacks').explorer() end, { desc = "File Explorer" })

            -- Find
            map("n", "<leader>fb", function() require('snacks').picker.buffers() end, { desc = "Buffers" })
            map("n", "<leader>fc", function() require('snacks').picker.files({ cwd = vim.fn.stdpath("config") }) end, { desc = "Find Config File" })
            map("n", "<leader>ff", function() require('snacks').picker.files() end, { desc = "Find Files" })
            map("n", "<leader>fg", function() require('snacks').picker.git_files() end, { desc = "Find Git Files" })
            map("n", "<leader>fp", function() require('snacks').picker.projects() end, { desc = "Projects" })
            map("n", "<leader>fr", function() require('snacks').picker.recent() end, { desc = "Recent" })

            -- Git
            map("n", "<leader>gb", function() require('snacks').picker.git_branches() end, { desc = "Git Branches" })
            map("n", "<leader>gl", function() require('snacks').picker.git_log() end, { desc = "Git Log" })
            map("n", "<leader>gL", function() require('snacks').picker.git_log_line() end, { desc = "Git Log Line" })
            map("n", "<leader>gs", function() require('snacks').picker.git_status() end, { desc = "Git Status" })
            map("n", "<leader>gS", function() require('snacks').picker.git_stash() end, { desc = "Git Stash" })
            map("n", "<leader>gd", function() require('snacks').picker.git_diff() end, { desc = "Git Diff (Hunks)" })
            map("n", "<leader>gf", function() require('snacks').picker.git_log_file() end, { desc = "Git Log File" })

            -- GitHub
            map("n", "<leader>gi", function() require('snacks').picker.gh_issue() end, { desc = "GitHub Issues (open)" })
            map("n", "<leader>gI", function() require('snacks').picker.gh_issue({ state = "all" }) end, { desc = "GitHub Issues (all)" })
            map("n", "<leader>gp", function() require('snacks').picker.gh_pr() end, { desc = "GitHub Pull Requests (open)" })
            map("n", "<leader>gP", function() require('snacks').picker.gh_pr({ state = "all" }) end, { desc = "GitHub Pull Requests (all)" })

            -- Search
            map("n", "<leader>sb", function() require('snacks').picker.lines() end, { desc = "Buffer Lines" })
            map("n", "<leader>sB", function() require('snacks').picker.grep_buffers() end, { desc = "Grep Open Buffers" })
            map("n", "<leader>sg", function() require('snacks').picker.grep() end, { desc = "Grep" })
            map({"n", "x"}, "<leader>sw", function() require('snacks').picker.grep_word() end, { desc = "Visual selection or word" })
            map("n", '<leader>s"', function() require('snacks').picker.registers() end, { desc = "Registers" })
            map("n", '<leader>s/', function() require('snacks').picker.search_history() end, { desc = "Search History" })
            map("n", "<leader>sa", function() require('snacks').picker.autocmds() end, { desc = "Autocmds" })
            map("n", "<leader>sc", function() require('snacks').picker.command_history() end, { desc = "Command History" })
            map("n", "<leader>sC", function() require('snacks').picker.commands() end, { desc = "Commands" })
            map("n", "<leader>d", function() require('snacks').picker.diagnostics() end, { desc = "Diagnostics" })
            map("n", "<leader>D", function() require('snacks').picker.diagnostics_buffer() end, { desc = "Buffer Diagnostics" })
            map("n", "<leader>sh", function() require('snacks').picker.help() end, { desc = "Help Pages" })
            map("n", "<leader>sH", function() require('snacks').picker.highlights() end, { desc = "Highlights" })
            map("n", "<leader>si", function() require('snacks').picker.icons() end, { desc = "Icons" })
            map("n", "<leader>sj", function() require('snacks').picker.jumps() end, { desc = "Jumps" })
            map("n", "<leader>sk", function() require('snacks').picker.keymaps() end, { desc = "Keymaps" })
            map("n", "<leader>sl", function() require('snacks').picker.loclist() end, { desc = "Location List" })
            map("n", "<leader>sm", function() require('snacks').picker.marks() end, { desc = "Marks" })
            map("n", "<leader>sM", function() require('snacks').picker.man() end, { desc = "Man Pages" })
            map("n", "<leader>sp", function() require('snacks').picker.lazy() end, { desc = "Search for Plugin Spec" })
            map("n", "<leader>sq", function() require('snacks').picker.qflist() end, { desc = "Quickfix List" })
            map("n", "<leader>sR", function() require('snacks').picker.resume() end, { desc = "Resume" })
            map("n", "<leader>su", function() require('snacks').picker.undo() end, { desc = "Undo History" })
            map("n", "<leader>uC", function() require('snacks').picker.colorschemes() end, { desc = "Colorschemes" })

            -- LSP
            map("n", "gd", function() require('snacks').picker.lsp_definitions() end, { desc = "Goto Definition" })
            map("n", "gD", function() require('snacks').picker.lsp_declarations() end, { desc = "Goto Declaration" })
            map("n", "grr", function() require('snacks').picker.lsp_references({ auto_confirm = false }) end, { nowait = true, desc = "References" })
            map("n", "gI", function() require('snacks').picker.lsp_implementations() end, { desc = "Goto Implementation" })
            map("n", "gy", function() require('snacks').picker.lsp_type_definitions() end, { desc = "Goto T[y]pe Definition" })
            map("n", "gai", function() require('snacks').picker.lsp_incoming_calls() end, { desc = "C[a]lls Incoming" })
            map("n", "gao", function() require('snacks').picker.lsp_outgoing_calls() end, { desc = "C[a]lls Outgoing" })
            map("n", "<leader>ss", function() require('snacks').picker.lsp_symbols() end, { desc = "LSP Symbols" })
            map("n", "<leader>sS", function() require('snacks').picker.lsp_workspace_symbols() end, { desc = "LSP Workspace Symbols" })

            -- Other
            map("n", "<leader>z", function() require('snacks').zen() end, { desc = "Toggle Zen Mode" })
            map("n", "<leader>Z", function() require('snacks').zen.zoom() end, { desc = "Toggle Zoom" })
            map("n", "<leader>.", function() require('snacks').scratch() end, { desc = "Toggle Scratch Buffer" })
            map("n", "<leader>S", function() require('snacks').scratch.select() end, { desc = "Select Scratch Buffer" })
            map("n", "<leader>n", function() require('snacks').notifier.show_history() end, { desc = "Notification History" })
            map("n", "<leader>bd", function() require('snacks').bufdelete() end, { desc = "Delete Buffer" })
            map("n", "<leader>cR", function() require('snacks').rename.rename_file() end, { desc = "Rename File" })
            map({"n", "v"}, "<leader>gB", function() require('snacks').gitbrowse() end, { desc = "Git Browse" })
            map("n", "<leader>gg", function() require('snacks').lazygit() end, { desc = "Lazygit" })
            map("n", "<leader>un", function() require('snacks').notifier.hide() end, { desc = "Dismiss All Notifications" })
            map("n", "<c-/>", function() require('snacks').terminal() end, { desc = "Toggle Terminal" })
            map("n", "<c-_>", function() require('snacks').terminal() end, { desc = "which_key_ignore" })
            map({"n", "t"}, "]]", function() require('snacks').words.jump(vim.v.count1) end, { desc = "Next Reference" })
            map({"n", "t"}, "[[", function() require('snacks').words.jump(-vim.v.count1) end, { desc = "Prev Reference" })
          '';
        }
        # Outline.nvim for code structure viewing
        {
          plugin = outline-nvim;
          type = "lua";
          config = ''
            require('lz.n').load {
              'outline.nvim',
              after = function()
                require('outline').setup({})
              end,
              keys = {
                { "<leader>o", "<cmd>Outline<cr>", desc = "Toggle Outline" },
              },
            }
          '';
          optional = true;
        }

        vim-matchup

        # Catppuccin colorscheme
        {
          plugin = catppuccin-nvim;
          type = "lua";
          config = ''
            vim.cmd.colorscheme("catppuccin-mocha")
          '';
        }

        # Git signs in the gutter
        {
          plugin = gitsigns-nvim;
          type = "lua";
          config = ''
            require('lz.n').load {
              'gitsigns.nvim',
              after = function()
                require('gitsigns').setup({})
              end,
              event = 'DeferredUIEnter',
            }
          '';
          optional = true;
        }

        # LSP configuration
        {
          plugin = nvim-lspconfig;
          type = "lua";
          config = ''
            -- Format keymap
            vim.keymap.set('n', '=', '<cmd>lua vim.lsp.buf.format()<cr>', {})

            -- Diagnostic configuration
            vim.diagnostic.config({
              virtual_lines = true,
              signs = false,
              update_in_insert = true,
            })

            -- Enable inlay hints
            vim.lsp.inlay_hint.enable()

            -- Enable codelens
            vim.lsp.codelens.enable()

            -- Custom LSP configuration from other modules
            ${cfg.lspConfig}
          '';
        }
        # Show available LSP code actions in the sign column
        {
          plugin = nvim-lightbulb;
          type = "lua";
          config = ''
            require('nvim-lightbulb').setup({
              autocmd = {
                enabled = true,
              },
              sign = {
                enabled = true,
                text = "▸",
              },
              virtual_text = {
                enabled = false,
              },
            })
          '';
        }
        # Table mode for Markdown tables
        {
          plugin = vim-table-mode;
          type = "lua";
          config = ''
            vim.g.table_mode_corner = '|'
          '';
        }

        # Completion engine
        {
          plugin = blink-cmp;
          type = "lua";
          config = ''
            require('lz.n').load {
              'blink.cmp',
              after = function()
                require('blink.cmp').setup({
                  sources = {
                    default = {
                      "lsp",
                      "path",
                      "snippets",
                    },
                  },
                  completion = {
                    list = {
                      selection = {
                        preselect = true,
                        auto_insert = false,
                      },
                    },
                    documentation = {
                      auto_show = true,
                    },
                  },
                })
              end,
              event = 'InsertEnter',
            }
          '';
          optional = true;
        }

        # Status line
        {
          plugin = lualine-nvim;
          type = "lua";
          config = ''
            require('lz.n').load {
              'lualine.nvim',
              after = function()
                require('lualine').setup({
                  options = {
                    icons_enabled = false,
                    section_separators = "",
                    component_separators = "",
                  },
                  sections = {
                    lualine_a = {
                      "mode",
                      "lsp_status",
                    },
                    lualine_c = {
                      {
                        "filename",
                        file_status = true,
                        path = 1,
                      },
                    },
                    lualine_x = { "%S" },
                  },
                })
              end,
              event = 'DeferredUIEnter',
            }
          '';
          optional = true;
        }
        # Git integration
        vim-fugitive

        # Auto-pairs for brackets, quotes, etc.
        {
          plugin = blink-pairs;
          type = "lua";
          config = ''
            local function reopen_blink_cmp_for_djot_and_plumb()
              -- Typing "[" or "(" can make blink.pairs insert the closing pair after blink.cmp has
              -- opened its completion menu, which closes the menu before it becomes visible.
              --
              -- Re-open it after the pair insertion has settled so link completions still show up.
              if vim.bo.filetype == 'djot' or vim.bo.filetype == 'plumb' then
                vim.defer_fn(function()
                  require('blink.cmp').show()
                end, 10)
              end
            end

            local function allow_pair_and_reopen_blink_cmp()
              reopen_blink_cmp_for_djot_and_plumb()
              return true
            end

            require('blink.pairs').setup({
              mappings = {
                cmdline = false,
                pairs = {
                  ['('] = { { ')', when = allow_pair_and_reopen_blink_cmp } },
                  ['['] = {
                    {
                      ']',
                      when = allow_pair_and_reopen_blink_cmp,
                      space =
                        function(ctx)
                          return not (ctx.ts:is_language('markdown') or ctx.ts:is_language('djot'))
                        end,
                    },
                  },
                },
              },
              highlights = { enabled = false },
            })

            -- A buffer-local mapping takes precedence over blink.pairs' global mapping. Override
            -- only backticks in plumb instead of disabling every auto-pair in the buffer.
            vim.api.nvim_create_autocmd('FileType', {
              pattern = 'plumb',
              callback = function(args)
                vim.keymap.set('i', '`', '`', {
                  buffer = args.buf,
                  desc = 'Insert backtick without auto-pairing',
                })
              end,
            })
          '';
        }

        # Surround text objects
        vim-surround

        # Enhanced search/jump motions
        {
          plugin = flash-nvim;
          type = "lua";
          config = ''
            require('flash').setup({
              modes = {
                search = {
                  enabled = true,
                },
              },
            })
          '';
        }

        # Treesitter parsers and queries for syntax highlighting
        (
          let
            filetypes = [
              "nix"
              "python"
              "c"
              "cpp"
              "cuda"
              "haskell"
              "json"
              "markdown"
              "plumb"
              "rust"
              "djot"
              "yaml"
            ];
            grammars = map (filetype: nvim-treesitter-parsers.${filetype}) filetypes;
            queries = map (grammar: grammar.associatedQuery) grammars;
            filetypesLua = lib.concatMapStringsSep ", " builtins.toJSON filetypes;
          in
          {
            plugin = pkgs.symlinkJoin {
              name = "neovim-treesitter-runtime";
              paths = grammars ++ queries;
            };
            type = "lua";
            config = ''
              vim.api.nvim_create_autocmd('FileType', {
                pattern = { ${filetypesLua} },
                callback = function(ev)
                  vim.treesitter.start(ev.buf)
                end,
              })
            '';
          }
        )

        # Line diff utilities
        linediff-vim

        # Oil.nvim for file management
        {
          plugin = oil-nvim;
          type = "lua";
          config = ''
            require('lz.n').load {
              'oil.nvim',
              after = function()
                require('oil').setup({})
              end,
              event = 'DeferredUIEnter',
            }
          '';
          optional = true;
        }

        # Agda support
        nvim-hs-vim
        vim-textobj-user
        cornelis

        # Lean support
        plenary-nvim
        {
          plugin = lean-nvim;
          type = "lua";
          config = ''
            require('lz.n').load {
              'lean.nvim',
              after = function()
                 require('lean').setup({
                   mappings = true,
                   abbreviations = {
                     enable = true,
                   },
                 })
              end,
              ft = 'lean',
            }
          '';
          optional = true;
        }

        # Which-key for keybinding help
        which-key-nvim

        # Kitty scrollback integration
        {
          plugin = kitty-scrollback-nvim;
          type = "lua";
          config = ''
            require('kitty-scrollback').setup({})
          '';
        }

        # Sidekick for AI assistance
        {
          plugin = sidekick-nvim;
          type = "lua";
          config = ''
            require('sidekick').setup({
              cli = {
                mux = {
                  enabled = true,
                  backend = "zellij",
                },
                tools = {
                  codex = {
                    cmd = { "codex-wrapper" },
                  };
                },
              },
            })

            vim.keymap.set("n", "<leader>aa", function()
              require("sidekick.cli").toggle()
            end, { desc = "Sidekick: Toggle AI CLI" })
          '';
        }

        # Lua development support
        {
          plugin = lazydev-nvim;
          type = "lua";
          config = ''
            require('lz.n').load {
              'lazydev.nvim',
              after = function()
                require('lazydev').setup({})
              end,
              ft = 'lua',
            }
          '';
          optional = true;
        }

      ];
    };

    home.shellAliases = {
      v = "nvim";
    };
  };
}
