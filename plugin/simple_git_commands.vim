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

command! GAddAll call simple_git_commands#g_add_all()
command! GResetAll call simple_git_commands#g_reset_all()

command! GCleanM call simple_git_commands#g_clean_m()
command! GCleanU call simple_git_commands#g_clean_u()
command! GClean call simple_git_commands#g_clean()

command! -nargs=1 -complete=customlist,simple_git_commands#_branches GllRebase call simple_git_commands#gll_rebase(<f-args>)
command! GllRebaseContinue call simple_git_commands#gll_rebase_continue()
command! GllRebaseAbort call simple_git_commands#gll_rebase_abort()

command! GResetLatest call simple_git_commands#g_reset_latest()
command! GResetHard call simple_git_commands#g_reset_hard()

command! -bang GDeleteAllMergedBranch call simple_git_commands#g_delete_all_merged_branch(<bang>0)

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
