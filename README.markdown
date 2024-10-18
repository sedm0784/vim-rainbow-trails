# 🌈 Rainbow Trails

TRANSFORM your BORING, regular Vim cursor into a delightful UNICORN that scatters RAINBOW dust as it GALLOPS around the buffer.[^1]

![A short Vim session. Vim is showing the :help page for the Rainbow Trails plugin. The command :Rainbow Trails is entered, and then the cursor is moved rapidly around the window, leaving rainbows behind it as it zips about.](https://normalmo.de/plugins/images/rainbow-trailser.gif)

## I want rainbows! How do I get them?!

Install in Vim or Neovim with your normal package manager, or just use the built in [packages](https://vimhelp.org/repeat.txt.html#packages) feature:

```shell
mkdir -p ~/.vim/pack/plugins/start
git clone https://github.com/sedm0784/vim-rainbow-trails.git ~/.vim/pack/plugins/start
```

Then run `:helptags ALL` in Vim to generate the [documentation](doc/rainbow-trails.txt), and `:RainbowTrails` to start the FUN.

## This is so cool! I want PERMANENT rainbows!

No problem! Create a file at `~/.vim/after/plugin/rainbow_trails.vim` with the contents:

```vim
RainbowTrails
```

Now Vim will enable the rainbows immediately after loading the plugin.

## I am a BUSINESSMAN and I want to use Rainbow Trails in a BUSINESS meeting at my BUSINESS where we make sprockets.

Rainbow Trails is ENTERPRISE-READY. But maybe the Rainbows are too FANCY for your workplace. Never fear! The level of fanciness is entirely configurable. For instance:

![Another short Vim session. This time, when the cursor is moves, the trails are in greyscale.](https://normalmo.de/rainbow-greys.gif)

For BUSINESS-certified rainbows, file a request to your IT department to install these [:highlight](https://vimhelp.org/syntax.txt.html#%3Ahighlight) commands in your vimrc.

```vim
highlight RainbowRed guibg=#808080 ctermbg=244
highlight RainbowOrange guibg=#6c6c6c ctermbg=242
highlight RainbowYellow guibg=#585858 ctermbg=240
highlight RainbowGreen guibg=#444444 ctermbg=238
highlight RainbowBlue guibg=#303030 ctermbg=236
highlight RainbowIndigo guibg=#1c1c1c ctermbg=234
highlight RainbowViolet guibg=#080808 ctermbg=232
```

## Do the rainbows work in terminal Vim?

Of course! Rainbow Trails works NATIVELY in terminals where `'termguicolors'` is enabled, and I have METICULOUSLY selected an appropriate set of colours for use in 256-colour terminals. If you have fewer than 256 colours available, you may wish to configure the highlighting further. (See above.)

## I have more... *specific* configuration requirements.

Rainbow Trails suits all needs. Fast rainbows? Slow rainbows? Double rainbows? All the way? Consult the [:help](doc/rainbow-trails.txt). There's a rainbow for everyone!

[^1]: Unicorn not included.
