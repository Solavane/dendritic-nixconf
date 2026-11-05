{
  flake.modules.homeManager.neovim = { pkgs, ... }:
  let
    love2d-api = pkgs.fetchFromGitHub {
      owner = "LuaCATS";
      repo  = "love2d";
      rev   = "main";
      hash  = "sha256-Mjp2ECqtyW/bLsDz1vgDDsX2CVIQ04Cx1xawzpQjoK8=";
    };
  in
  {
    modules.homeManager.mango.apps = [ "neovim" ];

    programs.neovim = {

      enable         = true;
      viAlias        = true;
      vimAlias       = true;
      defaultEditor  = true;
      waylandSupport = true;
      withRuby       = false;
      withPython3    = false;

      extraPackages = with pkgs; [
        nixd
        lua-language-server
        vscode-langservers-extracted  # jsonls
        pyright
        bash-language-server
        shellcheck    
      ];

      extraConfig = ''
        let mapleader = " "
        set number
        set relativenumber

        set expandtab
        set tabstop=2
        set softtabstop=2
        set shiftwidth=2

        set linebreak 
        set showbreak=>>> 

        set ignorecase
        set smartcase

        set termguicolors
        set cursorline
        set scrolloff=8

        set autoindent
        set clipboard=unnamedplus 
        set mouse=
        set nocompatible
        set signcolumn=yes
        set wildmode=longest,list
      '';

      initLua = ''
        local ok, m = pcall(require, "matugen")
        if ok then m.setup() end
      '';

      plugins = [
        {
          plugin = pkgs.vimPlugins.nvim-tree-lua;
          type = "lua";
          config = ''
            vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1

            require('nvim-tree').setup({
              view = {
                number = true;
                relativenumber = true;
              }
            })

            vim.keymap.set('n', '<leader>ee',  ':NvimTreeToggle<CR>',    { desc = "Toggle NvimTree" })
            vim.keymap.set('n', '<leader>ef', ':NvimTreeFindFile<CR>',  { desc = "Find current file in NvimTree" })
            vim.keymap.set('n', '<leader>ec', ':NvimTreeCollapse<CR>',  { desc = "Colapse all folders" })
          '';
        }
        {
          plugin = pkgs.vimPlugins.vim-startify;
          type = "viml";
          config = "let g:startify_change_to_vcs_root = 0";
        }
        {
          plugin = pkgs.vimPlugins.telescope-nvim;
          type = "lua"; 
          config = ''
            require('telescope').setup()
            
            vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, {})
            vim.keymap.set('n', '<leader>fr', require('telescope.builtin').oldfiles, {})
            vim.keymap.set('n', '<leader>fg', require('telescope.builtin').live_grep, {})
            vim.keymap.set('n', '<leader>fc', require('telescope.builtin').grep_string, {})
          '';
      }
      {
          plugin = pkgs.vimPlugins.indent-blankline-nvim;
          type = "lua";
          config = ''
            require("ibl").setup({
              indent = {
                char = "│",
              },
              scope = {
                enabled = false;
                show_start = false;
                show_end = false;
              },
            })        
          '';
        }
        {
          plugin = pkgs.vimPlugins.nvim-lspconfig;
          type = "lua";
          config = ''
            vim.lsp.config('lua_ls', {
              capabilities = require('blink.cmp').get_lsp_capabilities(),
              settings = {
                Lua = {
                  diagnostics = {
                    globals = { 'love' },
                  },
                  workspace = {
                    library = { "${love2d-api}" },
                    checkThirdParty = false,
                  },
                },
              },
            })

            vim.lsp.enable({ 'nixd', 'lua_ls', 'jsonls', 'pyright', 'bashls' })

            vim.diagnostic.config({
              virtual_text = true,
              signs = true,
              underline = true,
              update_in_insert = false,
            })

            vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
            vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Next diagnostic" })
            vim.keymap.set('n', '<leader>dd', vim.diagnostic.open_float, { desc = "Show diagnostic" })
          '';
        }
        {
          plugin = pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [
            p.bash
            p.json
            p.lua
            p.markdown
            p.markdown_inline
            p.nix
            p.python
            p.vim
          ]);
          type = "lua";
          config = ''
            vim.api.nvim_create_autocmd('FileType', {
              pattern = { 'nix', 'lua', 'json', 'python', 'bash', 'vim', 'markdown' },
              callback = function()
                vim.treesitter.start()
              end,
            })
          '';
        }
        {
          plugin = pkgs.vimPlugins.nvim-web-devicons;
          type = "lua";
          config = "require('nvim-web-devicons').setup()";
        }
        {
          plugin = pkgs.vimPlugins.blink-cmp;
          type = "lua";
          config = ''
            require('blink.cmp').setup({
              keymap = { preset = 'super-tab' },  -- Tab accepts/jumps, S-Tab goes back
              completion = {
                documentation = { auto_show = true, auto_show_delay_ms = 200 },
                menu = { draw = { treesitter = { 'lsp' } } },
              },
              signature = { enabled = true },
              sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
            })
          '';
        }
        pkgs.vimPlugins.friendly-snippets
        pkgs.vimPlugins.base16-nvim
        {
          plugin = pkgs.vimPlugins.lualine-nvim;
          type = "lua";
          config = ''
            local theme = 'auto'
            local ok, c = pcall(require, "matugen")
            if ok and type(c) == "table" and c.bg then
              local function mode(color)
                return {
                  a = { bg = color,    fg = c.bg, gui = 'bold' },
                  b = { bg = c.bg_alt, fg = c.fg },
                  c = { bg = c.bg,     fg = c.fg_alt },
                }
              end
              theme = {
                normal   = mode(c.primary),
                insert   = mode(c.green),
                visual   = mode(c.magenta),
                replace  = mode(c.error),
                command  = mode(c.yellow),
                inactive = mode(c.fg_alt),
              }
            end

            local round_l = vim.fn.nr2char(0xe0b6)
            local round_r = vim.fn.nr2char(0xe0b4)

            require('lualine').setup({
              options = {
                theme = theme,
                globalstatus = true,
                section_separators = { left = round_r, right = round_l },
                component_separators = "",
              },
              sections = {
                lualine_a = { { 'mode', separator = { left = round_l }, right_padding = 2 } },
                lualine_b = { 'branch', 'diff' },
                lualine_c = { { 'filename', path = 1 }, 'diagnostics' },
                lualine_x = { 'lsp_status', 'filetype' },
                lualine_y = { 'progress' },
                lualine_z = { { 'location', separator = { right = round_r }, left_padding = 2 } },
              },
            })
          '';
        }
        {
          plugin = pkgs.vimPlugins.nvim-autopairs;
          type = "lua";
          config = "require('nvim-autopairs').setup()";
        }
        {
          plugin = pkgs.vimPlugins.render-markdown-nvim;
          type = "lua";
          config = ''
            require('render-markdown').setup({})
            vim.keymap.set('n', '<leader>mr', '<cmd>RenderMarkdown toggle<CR>', { desc = "Toggle markdown rendering" })
          '';
        }
        {
          plugin = pkgs.vimPlugins.which-key-nvim;
          type = "lua";
          config = ''
            require('which-key').setup({ delay = 300 })
            vim.keymap.set('n', '<leader>?', function()
              require('which-key').show({ global = false })
            end, { desc = "Buffer-local keymaps" })
          '';
        }
      ];
    };
  };
}
