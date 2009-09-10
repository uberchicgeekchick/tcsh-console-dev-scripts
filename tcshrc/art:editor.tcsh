#!/bin/tcsh -f
alias	vim-enhanced	"vim-enhanced --noplugin -X -p";
alias	vim	"vim-enhanced";
alias	vi	"vim-enhanced";
alias	ex	"ex -E -n --noplugin -X";
setenv	EDITOR	"vim-enhanced";
bindkey	"^Z" run-fg-editor;

