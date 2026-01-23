-- ===========================================
-- Neovim Configuration
-- ===========================================
-- Uses lazy.nvim with lazy-loading for fast startup

-- ============================================
-- Options (load before plugins)
-- ============================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Tabs & indentation (2 spaces)
opt.expandtab = true
opt.shiftwidth = 2
opt.softtabstop = 2
opt.tabstop = 2
opt.autoindent = true
opt.smartindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

-- UI
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.showmode = false -- lualine shows mode

-- Behavior
opt.hidden = true
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undo"
opt.updatetime = 250
opt.timeoutlen = 300
opt.completeopt = "menu,menuone,noselect"
opt.splitright = true
opt.splitbelow = true
opt.clipboard = "unnamedplus" -- Use system clipboard for all yanks

-- Line wrapping
opt.wrap = true
opt.linebreak = true
opt.textwidth = 0
opt.wrapmargin = 0

-- Wildmenu
opt.wildmenu = true
opt.wildmode = "longest,list"

-- Visual bell (no beeping)
opt.visualbell = true

-- ============================================
-- Bootstrap lazy.nvim
-- ============================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================
-- Helper Functions
-- ============================================

-- Project picker helper: opens telescope-repo and calls callback with selected project path
-- Usage: with_project_picker(function(path) ... end)
local function with_project_picker(callback)
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  require("telescope").extensions.repo.list({
    search_dirs = { vim.fn.expand("~/code") },
    tail_path = true,
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if selection then
          callback(selection.path)
        end
      end)
      return true
    end,
  })
end

-- Helper to get project name from path
local function project_name(path)
  return vim.fn.fnamemodify(path, ":t")
end

-- ============================================
-- Plugins
-- ============================================
require("lazy").setup({
  -- ==================
  -- Colorschemes
  -- ==================
  {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("gruvbox").setup({
        contrast = "hard",
      })
      vim.cmd.colorscheme("gruvbox")
    end,
  },

  {
    "everviolet/nvim",
    name = "evergarden",
    lazy = true, -- load via <Space>ft colorscheme picker
    priority = 1000,
    opts = {
      theme = {
        variant = "fall", -- 'winter'|'fall'|'spring'|'summer'
        accent = "green",
      },
      integrations = {
        cmp = true,
        gitsigns = true,
        neotree = true,
        rainbow_delimiters = true,
        telescope = true,
        which_key = true,
      },
    },
  },

  -- ==================
  -- Dashboard (alpha-nvim)
  -- ==================
  {
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VimEnter",
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      -- Quick action buttons
      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find file", "<cmd>Telescope find_files<cr>"),
        dashboard.button("r", "  Recent files", "<cmd>Telescope oldfiles<cr>"),
        dashboard.button("p", "  Find project", function() with_project_picker(function(path) vim.cmd("cd " .. vim.fn.fnameescape(path)) end) end),
        dashboard.button("g", "  Live grep", "<cmd>Telescope live_grep<cr>"),
        dashboard.button("n", "  New file", "<cmd>ene<cr>"),
        dashboard.button("s", "  Git status", "<cmd>Git<cr>"),
        dashboard.button("c", "  Config", "<cmd>edit ~/.config/nvim/init.lua<cr>"),
        dashboard.button("q", "  Quit", "<cmd>qa<cr>"),
      }

      -- Footer
      dashboard.section.footer.val = function()
        local stats = require("lazy").stats()
        return "⚡ " .. stats.loaded .. "/" .. stats.count .. " plugins loaded"
      end

      alpha.setup(dashboard.config)

      -- Don't show dashboard when opening a file
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimStarted",
        callback = function()
          local stats = require("lazy").stats()
          dashboard.section.footer.val = "⚡ " .. stats.loaded .. "/" .. stats.count .. " plugins loaded"
          pcall(vim.cmd.AlphaRedraw)
        end,
      })
    end,
  },

  -- ==================
  -- Telescope (fuzzy finder)
  -- ==================
  {
    "nvim-telescope/telescope.nvim",
    branch = "master",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
    },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>/", "<cmd>Telescope live_grep<cr>", desc = "Search in project" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
      { "<leader>fc", "<cmd>Telescope commands<cr>", desc = "Commands" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document symbols" },
      { "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "Workspace symbols" },
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
      { "<leader>fq", "<cmd>Telescope quickfix<cr>", desc = "Quickfix list" },
      { "<leader>*", "<cmd>Telescope grep_string<cr>", desc = "Search word under cursor" },
      { "<leader>ss", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Search in buffer (swiper)" },
      { "<leader>sS", "<cmd>Telescope live_grep grep_open_files=true<cr>", desc = "Search in open buffers" },
      -- Resume and misc
      { "<leader>f.", "<cmd>Telescope resume<cr>", desc = "Resume last picker" },
      { "<leader>'", "<cmd>Telescope registers<cr>", desc = "Registers" },
      { "<leader>gC", "<cmd>Telescope git_bcommits<cr>", desc = "Buffer commits" },
      { "<leader>s/", "<cmd>Telescope search_history<cr>", desc = "Search history" },
      { "<leader>fj", "<cmd>Telescope jumplist<cr>", desc = "Jumplist" },
      { "<leader>ft", "<cmd>Telescope colorscheme<cr>", desc = "Colorschemes" },
      -- Help (<Space>h prefix, doom-style)
      { "<leader>hk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
      { "<leader>hh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
      { "<leader>hm", "<cmd>Telescope man_pages<cr>", desc = "Man pages" },
      { "<leader>hb", "<cmd>WhichKey<cr>", desc = "Browse bindings" },
      {
        "<leader>fF",
        function()
          vim.ui.input({ prompt = "Directory: ", default = "~/", completion = "dir" }, function(dir)
            if dir then
              require("telescope.builtin").find_files({ cwd = vim.fn.expand(dir) })
            end
          end)
        end,
        desc = "Find files in directory",
      },
      {
        "<leader>fG",
        function()
          vim.ui.input({ prompt = "Directory: ", default = "~/", completion = "dir" }, function(dir)
            if dir then
              require("telescope.builtin").live_grep({ cwd = vim.fn.expand(dir) })
            end
          end)
        end,
        desc = "Live grep in directory",
      },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
              ["<M-q>"] = actions.send_to_qflist + actions.open_qflist,
            },
            n = {
              ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
              ["<M-q>"] = actions.send_to_qflist + actions.open_qflist,
            },
          },
          file_ignore_patterns = {
            "node_modules",
            ".git/",
            "target/",
            "dist/",
            "__pycache__/",
            "%.pyc",
            ".venv/",
          },
        },
        pickers = {
          find_files = {
            hidden = true,
          },
        },
      })

      telescope.load_extension("fzf")
      telescope.load_extension("repo")
    end,
  },

  -- ==================
  -- Telescope-repo (find git repositories)
  -- ==================
  {
    "cljoly/telescope-repo.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    keys = {
      {
        "<leader>fpp",
        function()
          with_project_picker(function(path)
            vim.cmd("cd " .. vim.fn.fnameescape(path))
            vim.notify("Changed to: " .. path, vim.log.levels.INFO)
          end)
        end,
        desc = "Project cd",
      },
      {
        "<leader>fpf",
        function()
          with_project_picker(function(path)
            require("telescope.builtin").find_files({
              cwd = path,
              prompt_title = "Files in " .. project_name(path),
            })
          end)
        end,
        desc = "Project find files",
      },
      {
        "<leader>fpg",
        function()
          with_project_picker(function(path)
            require("telescope.builtin").live_grep({
              cwd = path,
              prompt_title = "Grep in " .. project_name(path),
            })
          end)
        end,
        desc = "Project grep",
      },
      {
        "<leader>fpr",
        function()
          with_project_picker(function(path)
            require("telescope.builtin").oldfiles({
              cwd = path,
              cwd_only = true,
              prompt_title = "Recent in " .. project_name(path),
            })
          end)
        end,
        desc = "Project recent files",
      },
      {
        "<leader>fps",
        function()
          with_project_picker(function(path)
            require("spectre").open({
              cwd = path,
              path_display = { "truncate" },
            })
          end)
        end,
        desc = "Project search & replace",
      },
      {
        "<leader>fpb",
        function()
          with_project_picker(function(path)
            require("telescope.builtin").buffers({
              cwd = path,
              cwd_only = true,
              prompt_title = "Buffers in " .. project_name(path),
            })
          end)
        end,
        desc = "Project buffers",
      },
      {
        "<leader>fpt",
        function()
          with_project_picker(function(path)
            vim.cmd("Neotree dir=" .. vim.fn.fnameescape(path))
          end)
        end,
        desc = "Project file tree",
      },
    },
  },

  -- ==================
  -- Spectre (search & replace, like wgrep)
  -- ==================
  {
    "nvim-pack/nvim-spectre",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Spectre",
    keys = {
      { "<leader>sr", '<cmd>lua require("spectre").toggle()<cr>', desc = "Search & replace (project)" },
      { "<leader>sw", '<cmd>lua require("spectre").open_visual({select_word=true})<cr>', desc = "Search word under cursor" },
      { "<leader>sw", '<esc><cmd>lua require("spectre").open_visual()<cr>', mode = "v", desc = "Search selection" },
      { "<leader>sb", '<cmd>lua require("spectre").open_file_search()<cr>', desc = "Search & replace (buffer)" },
    },
    config = function()
      require("spectre").setup({
        -- Use ripgrep
        default = {
          find = {
            cmd = "rg",
            options = { "ignore-case" },
          },
          replace = {
            cmd = "sed",
          },
        },
        -- Keymaps inside Spectre panel (shown for reference)
        -- These are the defaults:
        --   <leader>R  = Replace all
        --   <leader>rc = Replace current line
        --   <leader>v  = View options menu
        --   dd         = Toggle exclude current item
        --   <CR>       = Go to file
        --   o          = Show options
        --   I          = Toggle ignore case
        --   H          = Toggle hidden files
      })
    end,
  },

  -- ==================
  -- LSP & Completion
  -- ==================
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      { "j-hui/fidget.nvim", opts = {} }, -- LSP progress indicator
      { "folke/neodev.nvim", opts = {} }, -- Neovim Lua API completion
    },
    config = function()
      -- Setup mason first
      require("mason").setup()

      -- LSP servers to install and configure
      local servers = {
        terraformls = {},
        pyright = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              -- Poetry: if using in-project venv, pyright finds it automatically
              -- Otherwise, set venvPath in pyrightconfig.json or pyproject.toml
            },
          },
        },
        ts_ls = {},
        yamlls = {
          yaml = {
            schemas = {
              ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
              ["https://json.schemastore.org/github-action.json"] = "/action.yml",
            },
          },
        },
        bashls = {},
        lua_ls = {
          Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      }

      -- LSP keymaps (set when LSP attaches)
      local on_attach = function(_, bufnr)
        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
        end

        map("gd", vim.lsp.buf.definition, "Go to definition")
        map("gD", vim.lsp.buf.declaration, "Go to declaration")
        map("gr", vim.lsp.buf.references, "Go to references")
        map("gi", vim.lsp.buf.implementation, "Go to implementation")
        map("K", vim.lsp.buf.hover, "Hover documentation")
        map("<C-k>", vim.lsp.buf.signature_help, "Signature help")
        map("<leader>ca", vim.lsp.buf.code_action, "Code action")
        map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
        map("<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
        map("[d", vim.diagnostic.goto_prev, "Previous diagnostic")
        map("]d", vim.diagnostic.goto_next, "Next diagnostic")
      end

      -- Capabilities for completion
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

      -- Setup mason-lspconfig
      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(servers),
        automatic_installation = true,
        handlers = {
          -- Default handler for all servers
          function(server_name)
            require("lspconfig")[server_name].setup({
              capabilities = capabilities,
              on_attach = on_attach,
              settings = servers[server_name] or {},
            })
          end,
        },
      })
    end,
  },

  -- Rust (enhanced support via rustaceanvim)
  {
    "mrcjkb/rustaceanvim",
    version = "^4",
    ft = { "rust" },
    config = function()
      vim.g.rustaceanvim = {
        server = {
          on_attach = function(_, bufnr)
            local map = function(keys, func, desc)
              vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
            end
            map("gd", vim.lsp.buf.definition, "Go to definition")
            map("gr", vim.lsp.buf.references, "Go to references")
            map("K", vim.lsp.buf.hover, "Hover documentation")
            map("<leader>ca", vim.lsp.buf.code_action, "Code action")
            map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
          end,
        },
      }
    end,
  },

  -- Completion
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      -- Load VSCode-style snippets
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
        }, {
          { name = "buffer" },
        }),
      })
    end,
  },

  -- ==================
  -- Treesitter
  -- ==================
  {
    "nvim-treesitter/nvim-treesitter",
    build = function()
      -- Install parsers on plugin install/update only
      local parsers = {
        "bash",
        "hcl",
        "terraform",
        "rust",
        "python",
        "typescript",
        "tsx",
        "javascript",
        "yaml",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "vim",
        "vimdoc",
        "toml",
      }
      require("nvim-treesitter.install").install(parsers)
    end,
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      -- No auto-install on file open - parsers are installed via build step
      -- Run :Lazy build nvim-treesitter to install parsers manually if needed
    end,
  },

  -- ==================
  -- Formatting
  -- ==================
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        desc = "Format buffer",
      },
    },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "ruff_format" },
          rust = { "rustfmt" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          javascriptreact = { "prettier" },
          typescriptreact = { "prettier" },
          json = { "prettier" },
          yaml = { "prettier" },
          markdown = { "prettier" },
          terraform = { "terraform_fmt" },
          hcl = { "terraform_fmt" },
          sh = { "shfmt" },
          bash = { "shfmt" },
        },
        format_on_save = function(bufnr)
          -- Disable for certain filetypes
          local disable_filetypes = { sql = true, tex = true, latex = true, nix = true }
          if disable_filetypes[vim.bo[bufnr].filetype] then
            return
          end
          return { timeout_ms = 500, lsp_fallback = true }
        end,
      })
    end,
  },

  -- ==================
  -- Linting
  -- ==================
  {
    "mfussenegger/nvim-lint",
    event = { "BufWritePost" },
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        python = { "ruff" },
      }

      -- Lint on save
      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },

  -- ==================
  -- Quickfix Enhancements
  -- ==================
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    opts = {
      auto_enable = true,
      preview = {
        win_height = 12,
        win_vheight = 12,
        delay_syntax = 80,
        border = "rounded",
        show_title = true,
      },
      filter = {
        fzf = {
          action_for = { ["ctrl-s"] = "split", ["ctrl-v"] = "vsplit" },
          extra_opts = { "--bind", "ctrl-o:toggle-all", "--prompt", "> " },
        },
      },
    },
  },

  {
    "gabrielpoca/replacer.nvim",
    keys = {
      {
        "<leader>qr",
        function()
          require("replacer").run()
        end,
        desc = "Quickfix replace (editable)",
      },
    },
  },

  -- ==================
  -- Git
  -- ==================
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local map = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end

        -- Navigation
        map("n", "]h", gs.next_hunk, "Next hunk")
        map("n", "[h", gs.prev_hunk, "Previous hunk")

        -- Actions
        map("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
        map("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage hunk")
        map("v", "<leader>gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset hunk")
        map("n", "<leader>gS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>gu", gs.undo_stage_hunk, "Undo stage hunk")
        map("n", "<leader>gR", gs.reset_buffer, "Reset buffer")
        map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
        map("n", "<leader>gd", gs.diffthis, "Diff this")
        map("n", "<leader>gD", function() gs.diffthis("~") end, "Diff this ~")
      end,
    },
  },

  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gstatus", "Gblame", "Gpush", "Gpull", "Gdiffsplit" },
    keys = {
      { "<leader>gg", "<cmd>Git<cr>", desc = "Git status" },
      { "<leader>gc", "<cmd>Git commit<cr>", desc = "Git commit" },
      { "<leader>gP", "<cmd>Git push<cr>", desc = "Git push" },
      { "<leader>gl", "<cmd>Git log --oneline<cr>", desc = "Git log" },
    },
  },

  -- ==================
  -- File Explorer
  -- ==================
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle file explorer" },
      { "<leader>E", "<cmd>Neotree reveal<cr>", desc = "Reveal current file" },
    },
    opts = {
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
      window = {
        width = 35,
        mappings = {
          ["<space>"] = "none", -- Don't conflict with leader
        },
      },
    },
  },

  -- ==================
  -- UI
  -- ==================
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
      options = {
        theme = "gruvbox",
        component_separators = "|",
        section_separators = "",
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      extensions = { "fugitive", "neo-tree", "quickfix" },
    },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup({
        delay = 200,
      })
      wk.add({
        { "<leader>f", group = "find" },
        { "<leader>fp", group = "project" },
        { "<leader>h", group = "help" },
        { "<leader>s", group = "search/replace" },
        { "<leader>c", group = "code" },
        { "<leader>g", group = "git" },
        { "<leader>b", group = "buffer" },
        { "<leader>q", group = "quickfix" },
        { "<leader>l", group = "location list" },
        { "<leader>w", group = "window" },
      })
    end,
  },

  -- ==================
  -- Editing
  -- ==================
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },

  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },

  -- Rainbow delimiters
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
  },

  -- ==================
  -- Misc
  -- ==================
  -- Detect tabstop and shiftwidth automatically
  { "tpope/vim-sleuth", event = { "BufReadPost", "BufNewFile" } },

  -- Useful for repeating plugin commands
  { "tpope/vim-repeat", event = "VeryLazy" },

  -- ==================
  -- Barbar (buffer tabline)
  -- ==================
  {
    "romgrk/barbar.nvim",
    dependencies = {
      "lewis6991/gitsigns.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    event = "VeryLazy",
    init = function()
      vim.g.barbar_auto_setup = false
    end,
    opts = {
      animation = true,
      auto_hide = false,
      tabpages = true,
      clickable = true,
      focus_on_close = "left",
      icons = {
        buffer_index = false,
        buffer_number = false,
        button = "",
        diagnostics = {
          [vim.diagnostic.severity.ERROR] = { enabled = true, icon = " " },
          [vim.diagnostic.severity.WARN] = { enabled = false },
          [vim.diagnostic.severity.INFO] = { enabled = false },
          [vim.diagnostic.severity.HINT] = { enabled = false },
        },
        filetype = { enabled = true },
        separator = { left = "▎", right = "" },
        modified = { button = "●" },
        pinned = { button = "󰐃", filename = true },
      },
    },
    keys = {
      { "<A-,>", "<cmd>BufferPrevious<cr>", desc = "Previous buffer" },
      { "<A-.>", "<cmd>BufferNext<cr>", desc = "Next buffer" },
      { "<A-<>", "<cmd>BufferMovePrevious<cr>", desc = "Move buffer left" },
      { "<A->>", "<cmd>BufferMoveNext<cr>", desc = "Move buffer right" },
      { "<A-1>", "<cmd>BufferGoto 1<cr>", desc = "Go to buffer 1" },
      { "<A-2>", "<cmd>BufferGoto 2<cr>", desc = "Go to buffer 2" },
      { "<A-3>", "<cmd>BufferGoto 3<cr>", desc = "Go to buffer 3" },
      { "<A-4>", "<cmd>BufferGoto 4<cr>", desc = "Go to buffer 4" },
      { "<A-5>", "<cmd>BufferGoto 5<cr>", desc = "Go to buffer 5" },
      { "<A-6>", "<cmd>BufferGoto 6<cr>", desc = "Go to buffer 6" },
      { "<A-7>", "<cmd>BufferGoto 7<cr>", desc = "Go to buffer 7" },
      { "<A-8>", "<cmd>BufferGoto 8<cr>", desc = "Go to buffer 8" },
      { "<A-9>", "<cmd>BufferGoto 9<cr>", desc = "Go to buffer 9" },
      { "<A-0>", "<cmd>BufferLast<cr>", desc = "Go to last buffer" },
      { "<A-p>", "<cmd>BufferPin<cr>", desc = "Pin buffer" },
      { "<A-c>", "<cmd>BufferClose<cr>", desc = "Close buffer" },
      { "<leader>bp", "<cmd>BufferPick<cr>", desc = "Pick buffer" },
      { "<leader>bc", "<cmd>BufferClose<cr>", desc = "Close buffer" },
      { "<leader>bC", "<cmd>BufferCloseAllButCurrentOrPinned<cr>", desc = "Close other buffers" },
    },
  },

  -- ==================
  -- Tiny Inline Diagnostic (prettier diagnostics)
  -- ==================
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach",
    priority = 1000, -- needs to load before other LSP plugins
    config = function()
      -- Disable default virtual text diagnostics
      vim.diagnostic.config({ virtual_text = false })
      require("tiny-inline-diagnostic").setup({
        preset = "modern",
        options = {
          show_source = true,
          multiple_diag_under_cursor = true,
          multilines = true,
        },
      })
    end,
  },

  -- ==================
  -- Atone (modern undotree)
  -- ==================
  {
    "XXiaoA/atone.nvim",
    cmd = "Atone",
    keys = {
      { "<leader>u", "<cmd>Atone toggle<cr>", desc = "Toggle undo tree" },
    },
    opts = {
      layout = {
        direction = "left",
        width = 0.25,
      },
      diff_cur_node = {
        enabled = true,
        split_percent = 0.3,
      },
      auto_attach = {
        enabled = true,
      },
      ui = {
        border = "single",
        compact = false,
      },
    },
  },

}, {
  -- lazy.nvim configuration
  install = {
    colorscheme = { "gruvbox" },
  },
  checker = {
    enabled = true,
    notify = false, -- Don't spam notifications about updates
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- ============================================
-- Keymaps (non-plugin)
-- ============================================
local map = vim.keymap.set

-- Escape insert mode with jk
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Buffer navigation
map("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Previous buffer" })

-- Y yanks to end of line
map("n", "Y", "y$", { desc = "Yank to end of line" })

-- Q repeats macro q
map("n", "Q", "@q", { desc = "Replay macro q" })

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- Quickfix navigation (]q/[q preserved for quick jumping)
map("n", "]q", "<cmd>cnext<cr>", { desc = "Next quickfix item" })
map("n", "[q", "<cmd>cprev<cr>", { desc = "Previous quickfix item" })

-- Quickfix management (<Space>q prefix)
map("n", "<leader>qo", "<cmd>copen<cr>", { desc = "Open quickfix" })
map("n", "<leader>qc", "<cmd>cclose<cr>", { desc = "Close quickfix" })
map("n", "<leader>qn", "<cmd>cnext<cr>", { desc = "Next quickfix item" })
map("n", "<leader>qp", "<cmd>cprev<cr>", { desc = "Previous quickfix item" })
map("n", "<leader>qf", "<cmd>cfirst<cr>", { desc = "First quickfix item" })
map("n", "<leader>ql", "<cmd>clast<cr>", { desc = "Last quickfix item" })
map("n", "<leader>qq", "<cmd>cclose<cr>", { desc = "Close quickfix" })

-- Location list (buffer-local quickfix)
map("n", "<leader>lo", "<cmd>lopen<cr>", { desc = "Open location list" })
map("n", "<leader>lc", "<cmd>lclose<cr>", { desc = "Close location list" })
map("n", "]l", "<cmd>lnext<cr>", { desc = "Next location item" })
map("n", "[l", "<cmd>lprev<cr>", { desc = "Previous location item" })

-- Window management
map("n", "<leader>wo", "<cmd>only<cr>", { desc = "Close other windows" })
map("n", "<leader>wf", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative ~= "" then
      vim.api.nvim_win_close(win, true)
    end
  end
end, { desc = "Close floating windows" })

-- Better movement with wrapped lines
map("n", "j", "gj", { desc = "Move down (wrapped)" })
map("n", "k", "gk", { desc = "Move up (wrapped)" })

-- Keep cursor centered when scrolling
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up" })

-- Keep cursor centered when searching
map("n", "n", "nzzzv", { desc = "Next search result" })
map("n", "N", "Nzzzv", { desc = "Previous search result" })

-- Better indenting (stay in visual mode)
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- Pipe selection to command, output to new scratch buffer
-- Usage: Select text, press <Space>|, type command (e.g., jq), press Enter
vim.keymap.set("v", "<leader>|", function()
  vim.ui.input({ prompt = "Pipe to command: " }, function(cmd)
    if cmd and cmd ~= "" then
      -- Get selection
      local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() })
      local input = table.concat(lines, "\n")
      
      -- Run command
      local output = vim.fn.system(cmd, input)
      
      -- Open new scratch buffer with output
      vim.cmd("new")
      vim.bo.buftype = "nofile"
      vim.bo.bufhidden = "wipe"
      vim.bo.swapfile = false
      vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(output, "\n"))
    end
  end)
end, { desc = "Pipe selection to command" })

-- Move lines up/down
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Save file
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })

-- Quit
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- Edit config
map("n", "<leader>vc", "<cmd>edit ~/.config/nvim/init.lua<cr>", { desc = "Edit config" })

-- Lazy plugin manager
map("n", "<leader>L", "<cmd>Lazy<cr>", { desc = "Lazy plugin manager" })

-- ============================================
-- Autocommands
-- ============================================
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Highlight on yank
autocmd("TextYankPost", {
  group = augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- Resize splits when window is resized
autocmd("VimResized", {
  group = augroup("resize_splits", { clear = true }),
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Go to last location when opening a buffer
autocmd("BufReadPost", {
  group = augroup("last_location", { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Close some filetypes with just 'q'
autocmd("FileType", {
  group = augroup("close_with_q", { clear = true }),
  pattern = { "help", "qf", "man", "notify", "spectre_panel" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Auto-create parent directories when saving a file
autocmd("BufWritePre", {
  group = augroup("auto_create_dir", { clear = true }),
  callback = function(event)
    if event.match:match("^%w%w+://") then
      return
    end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})
