" File: plugin/simple_git_commands.vim
" Author: ToruIwashita <toru.iwashita@gmail.com>
" License: MIT License

let s:cpoptions_save = &cpoptions
set cpoptions&vim

fun! s:git_exec(cmd, args) abort
  let l:results = split(system('\git '.a:cmd.' '.a:args.' 2>/dev/null; echo $?'), "\n")
  let l:exit_status = remove(l:results, -1)

  if l:exit_status
    throw 'failed to '.a:cmd.' command.'
  endif

  return join(l:results, "\n")
endf

fun! simple_git_commands#gsh(bang, option) abort
  try
    let l:current_branch = s:git_exec('symbolic-ref', '--short HEAD')

    if a:option ==# 'force'
      let l:comment = "force push '".l:current_branch."' branch"
      let l:push_opt = '--force-with-lease'
    elseif a:option ==# 'plain'
      let l:comment = "push '".l:current_branch."' branch"
      let l:push_opt = ''
    else
      throw "invalid option '".a:option."'"
    endif

    if !a:bang
      if confirm(l:comment.'?', "&Yes\n&No", 0) != 1
        return 1
      endif
    else
      echo l:comment.'.'
    endif

    call s:git_exec('push', l:push_opt.' origin '.l:current_branch)
    redraw!
    echo 'pushed.'
  catch /failed to symbolic-ref/
    redraw!
    echo v:exception
  catch /failed to push/
    redraw!
    echo "failed to push '".l:current_branch."' branch."
  endtry
endf

fun! simple_git_commands#gll_rebase(base_branch) abort
  try
    let l:current_branch = s:git_exec('symbolic-ref', '--short HEAD')

    if confirm("rebase '".l:current_branch."' against '".a:base_branch."'? ", "&Yes\n&No", 0) != 1
      return 1
    endif

    redraw!
    echo "rebasing '".l:current_branch."' branch."

    call s:git_exec('pull --rebase', 'origin '.a:base_branch)

    checktime
    redraw!
    echo 'rebased.'
  catch /failed to symbolic-ref/
    redraw!
    echo v:exception
  catch /failed to pull --rebase/
    redraw!
    echo "failed to rabase '".l:current_branch."' against '".a:base_branch."'."
  endtry
endf

fun! simple_git_commands#gll_rebase_abort() abort
  try
    redraw!

    call s:git_exec('rebase', '--abort')

    checktime
    redraw!
    echo 'aborted.'
  catch
    redraw!
    echo v:exception
  endtry
endf

fun! simple_git_commands#gll_rebase_continue() abort
  redraw!
  echo 'continue rebasing.'

  execute '!\git rebase --continue'

  checktime
endf

fun! simple_git_commands#greset_latest() abort
  try
    if confirm("reset 'HEAD^'? ", "&Yes\n&No", 0) != 1
      return 1
    endif

    call s:git_exec('reset', 'HEAD^')

    redraw!
    echo 'reset.'
  catch
    redraw!
    echo v:exception
  endtry
endf

fun! simple_git_commands#_branches(...) abort
  return filter(filter(split(s:git_exec('branch', '--no-color')), "v:val !=# '*'"), 'v:val =~ "^'.fnameescape(a:1).'"')
endf

let &cpoptions = s:cpoptions_save
unlet s:cpoptions_save
