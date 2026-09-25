{
  ...
}:
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

        set termguicolors
        set number
        set tabstop=2
        set softtabstop=2
        set shiftwidth=2
        set expandtab
        set nocompatible
        set wildmode=longest,list
        set clipboard=unnamedplus 
      '';

      plugins = [
        {
          plugin = pkgs.vimPlugins.nvim-tree-lua;
          type = "lua";
          config = ''
            require('nvim-tree').setup()

            vim.keymap.set('n', '<leader>e',  ':NvimTreeToggle<CR>',    { desc = "Toggle NvimTree" })
            vim.keymap.set('n', '<leader>ef', ':NvimTreeFindFile<CR>',  { desc = "Find current file in NvimTree" })
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
            vim.keymap.set('n', '<leader>fg', require('telescope.builtin').live_grep, {})
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
                enabled = true;
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
            p.nix
            p.lua
            p.json
            p.python
            p.bash
            p.vim
            p.markdown
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
      ];
    };
  };
}
