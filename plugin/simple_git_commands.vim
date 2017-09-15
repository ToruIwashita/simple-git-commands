" File: plugin/simple_git_commands.vim
" Author: ToruIwashita <toru.iwashita@gmail.com>
" License: MIT License

if exists('g:loaded_simple_git_commands')
  finish
endif
let g:loaded_simple_git_commands = 1

let s:cpoptions_save = &cpoptions
set cpoptions&vim

command! -bang Gsh call simple_git_commands#gsh(<bang>0, 'plain')
command! -bang GshForce call simple_git_commands#gsh(<bang>0, 'force')

command! -bang GResetAll call simple_git_commands#g_reset_all()

command! -bang GCleanM call simple_git_commands#g_clean_m()
command! -bang GCleanU call simple_git_commands#g_clean_u()
command! -bang GClean call simple_git_commands#g_clean()

command! -nargs=1 -complete=customlist,simple_git_commands#_branches GllRebase call simple_git_commands#gll_rebase(<f-args>)
command! GllRebaseContinue call simple_git_commands#gll_rebase_continue()
command! GllRebaseAbort call simple_git_commands#gll_rebase_abort()

command! GresetLatest call simple_git_commands#greset_latest()

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
