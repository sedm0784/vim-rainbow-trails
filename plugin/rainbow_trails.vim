" rainbow-trails.vim
" Author: Rich Cheng <https://normalmo.de>
" Homepage: http://github.com/sedm0784/rainbow-trails
" Copyright: © 2024 Rich Cheng
" Licence: Rainbow Trails uses the Vim licence.
" Version: 0.0.1

scriptencoding utf-8

if exists('g:loaded_rainbow_trails') || &compatible
  finish
endif
let g:loaded_rainbow_trails = 1

command -bar -bang RainbowTrails call rainbow_trails#enable(empty('<bang>'))
