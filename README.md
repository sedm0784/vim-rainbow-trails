# 🌈 Rainbow Trails

TRANSFORM your BORING, regular Vim cursor into a delightful UNICORN that scatters RAINBOW dust as it GALLOPS around the buffer.[^1]

Fork from: [sedm0784/vim-rainbow-trails](https://github.com/sedm0784/vim-rainbow-trails)

![A short Vim session. Vim is showing the :help page for the Rainbow Trails plugin. The command :Rainbow Trails is entered, and then the cursor is moved rapidly around the window, leaving rainbows behind it as it zips about.](https://normalmo.de/plugins/images/rainbow-trailser.gif)

# Installation instructions

## LazyGit

1. Create a file inside the plugins folder with:

```lua
  {
    "sedm0784/vim-rainbow-trails",
    enabled = true, 
    lazy = false
  }
```

If you want it to autoload put this on your init file

```lua  
vim.api.nvim_create_autocmd("BufEnter", { command = ":RainbowTrails", })

```

## NvChad

Add the lines above in your .config/nvim/lua/custom/plugins.lua list 
Put the autoload if required on your .config/nvim/lua/custom/chadrc.lua file

Enjoy!

# Running it

Then run `:helptags ALL` in Vim to generate the [documentation](doc/rainbow-trails.txt), and `:RainbowTrails` to start the FUN.
