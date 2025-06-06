- [x] Refactor: lspZero will stop getting updates , move to [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
- [] Look into quickfix list & how to use them
- [] Look into nvim-dap to add debuggers
    - [] Try out all the different dap's with small examples
- [] Extract theme colors & remove all hardcoded colors to handle theme switching better  
- [x] create a keymap for :%!jq . to format json
- [x] Optimize config, use nvim --startuptime saveOutput.txt to help analyze
- [x] Create a keymap to copy entire file to clipboard regardless of where in file cursor is located
- [x] Add [Themery](https://github.com/zaldih/themery.nvim) to be able to change themes fast
- [x] Add nvim tree for file explorer
- [x] Add Harpoon
  - [x] Migrate to harpoon2 (https://github.com/ThePrimeagen/harpoon/tree/harpoon2?tab=readme-ov-file)
  - [x] Increase size of harpoon menu window
- [x] Fix yank highlight
- [x] vim-maximizer - Toggle split window between maximized and split
- [x] which key - so i can see all keybinds
- [x] Fix formating with leader l f 
- [x] [nvim-ts-autotag](https://github.com/windwp/nvim-ts-autotag) use this plugin to auto close html tags
- [x] nvim undo tree - https://github.com/mbbill/undotree
- [x] Fix folds & folding
- [x] create fallback for leader f to find files if vim is used in a non git folder
- [x] add snippets functionality via lspZero [Add an external collection of snippets](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/autocomplete.md#add-an-external-collection-of-snippets)
- [x] Fix so you can see workspace diagnostics (look into leader l w in lvim)
- [x] make the command <leader> st live grep ignore stuff in lock files
- [x] Take a look at LazyVim keybinds for ideas [LazyVim Keymaps](https://www.lazyvim.org/keymaps)
- [x] fix fancy startup dashboard with dashboard or alpha like lazyvim
- [x] create persistent undotree
- [x] Migrate to [Lazy](https://github.com/folke/lazy.nvim)
- [x] Customize Lualine
- [x] Look into vue lsp functionality with a small example[lspZero](https://lsp-zero.netlify.app/blog/configure-volar-v2.html)
- [x] Add integration to gitsigns(https://github.com/lewis6991/gitsigns.nvim)

- [x] Add colorizer to show hex colors[colorizer](https://github.com/norcalli/nvim-colorizer.lua)
  - [x] Add a command to turn on & off the colorizer in whichkey

#### Interesting plugins to look into later
- [x] Kitty scrollback [kitty-scrollback](https://github.com/mikesmithgh/kitty-scrollback.nvim)
- [] Database client for neovim [nvim-dbee](https://github.com/kndndrj/nvim-dbee)
- Look into interesting packages in mini to add features / replace existing ones:
    - [x] mini.ai, Extend the a/i textobjects[mini.ai](https://github.com/echasnovski/mini.ai)
    - [x] [mini.surround](https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-surround.md)
- [x] autoSession - auto-session will try to restore an existing session for the current cwd if one exists.(https://github.com/rmagatti/auto-session)
- [x] wtf.nvim - A Neovim plugin to help you work out what the fudge that diagnostic means and how to fix it!(https://github.com/piersolenski/wtf.nvim)
- [] Kuala A minimal [REST-Client Interface for Neovim](https://github.com/mistweaverco/kulala.nvim)
- [] look into setting up [go.nvim](https://github.com/ray-x/go.nvim)
- [x] Establish good command workflow and quit bad habit[hardtime](https://github.com/m4xshen/hardtime.nvim)

### Nvim Tree Settings & Configuration
- [x] Make it so if you toggle the explorer when a file is open it opens up nvim-tree navigates to that folder
- [x] Remove .git folder from explorer view (Propbably no need to implement this)
- [x] Fix so if you open a file directly nvimtree does not open first
- [x] Change so the tree doesnt use symbols instead it highlights the color of the name of of file if its dirty/new in git

### Toggleterm
- [x] Add intigration to lazygit

# Resources & Inspo
* [Lunarvim repo](https://www.lunarvim.org/)
* [Neovim-from-scratch](https://github.com/LunarVim/Neovim-from-scratch)
* [nvim-basic-ide](https://github.com/LunarVim/nvim-basic-ide)
* [Josean Martinez Youtube Video](https://www.youtube.com/watch?v=vdn_pKJUda8&list=LL&index=1)
* [ThePrimeagen Youtube Video](https://www.youtube.com/watch?v=w7i4amO_zaE&list=LL)
* [lspzero](https://github.com/VonHeikemen/lsp-zero.nvim)
* [ftplugin](https://neovim.io/doc/user/filetype.html) & [usage of ftplugin](https://www.reddit.com/r/neovim/comments/x3zp6t/usage_of_afterftplugin_directory_for/)
* [LazyVim](https://www.lazyvim.org/)
* [Kickstart](https://github.com/nvim-lua/kickstart.nvim)
