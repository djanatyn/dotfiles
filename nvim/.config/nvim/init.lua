-- ===========================================
-- Neovim Configuration (simplified)
-- ===========================================
-- Uses lazy.nvim with lazy-loading for fast startup
-- Optimized for quick edits -- no project management, dashboards, or IDE features

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
-- Plugins
-- ============================================
require("lazy").setup({
  -- ==================
  -- Colorscheme
  -- ==================
  {
    "UtkarshVerma/molokai.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("molokai")
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
      { "<leader>ff", "<cmd>Telescope find_files<cr>",                desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",                 desc = "Live grep" },
      { "<leader>/",  "<cmd>Telescope live_grep<cr>",                 desc = "Search in project" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",                   desc = "Buffers" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>",                  desc = "Recent files" },
      { "<leader>*",  "<cmd>Telescope grep_string<cr>",               desc = "Search word under cursor" },
      { "<leader>ss", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Search in buffer" },
      { "<leader>f.", "<cmd>Telescope resume<cr>",                    desc = "Resume last picker" },
      { "<leader>ft", "<cmd>Telescope colorscheme<cr>",               desc = "Colorschemes" },
      { "<leader>hk", "<cmd>Telescope keymaps<cr>",                   desc = "Keymaps" },
      { "<leader>hh", "<cmd>Telescope help_tags<cr>",                 desc = "Help tags" },
      { "<leader>hb", "<cmd>WhichKey<cr>",                            desc = "Browse bindings" },
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
            },
            n = {
              ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
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
    },
    config = function()
      -- Setup mason
      require("mason").setup()

      -- LSP servers to install and configure
      local servers = {
        terraformls = {},
        pyright = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
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

  -- Completion
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    config = function()
      local cmp = require("cmp")

      cmp.setup({
        -- Use native Neovim snippets (0.10+) for LSP snippet expansion
        snippet = {
          expand = function(args)
            vim.snippet.expand(args.body)
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
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
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
      { "<leader>gg", "<cmd>Git<cr>",               desc = "Git status" },
      { "<leader>gc", "<cmd>Git commit<cr>",         desc = "Git commit" },
      { "<leader>gP", "<cmd>Git push<cr>",           desc = "Git push" },
      { "<leader>gl", "<cmd>Git log --oneline<cr>",  desc = "Git log" },
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
        theme = "auto",
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
      extensions = { "fugitive", "quickfix" },
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
        { "<leader>h", group = "help" },
        { "<leader>s", group = "search" },
        { "<leader>c", group = "code" },
        { "<leader>g", group = "git" },
        { "<leader>q", group = "quickfix" },
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

  -- ==================
  -- Misc
  -- ==================
  -- Detect tabstop and shiftwidth automatically
  { "tpope/vim-sleuth", event = { "BufReadPost", "BufNewFile" } },

  -- Useful for repeating plugin commands
  { "tpope/vim-repeat", event = "VeryLazy" },

}, {
  -- lazy.nvim configuration
  install = {
    colorscheme = { "molokai" },
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
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

-- Y yanks to end of line
map("n", "Y", "y$", { desc = "Yank to end of line" })

-- Q repeats macro q
map("n", "Q", "@q", { desc = "Replay macro q" })

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- Quickfix navigation
map("n", "]q", "<cmd>cnext<cr>", { desc = "Next quickfix item" })
map("n", "[q", "<cmd>cprev<cr>", { desc = "Previous quickfix item" })
map("n", "<leader>qo", "<cmd>copen<cr>", { desc = "Open quickfix" })
map("n", "<leader>qc", "<cmd>cclose<cr>", { desc = "Close quickfix" })

-- Location list
map("n", "]l", "<cmd>lnext<cr>", { desc = "Next location item" })
map("n", "[l", "<cmd>lprev<cr>", { desc = "Previous location item" })

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
  pattern = { "help", "qf", "man", "notify" },
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
