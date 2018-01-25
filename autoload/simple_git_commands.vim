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

fun! s:git_async_exec(cmd, exit_msg) abort
  call job_start('bash -c "git '.a:cmd.' >/dev/null 2>&1"', {
    \ 'exit_cb': {
    \   channel, status -> [
    \     execute('checktime'),
    \     execute("if ".status." == 0 | echo '".a:exit_msg."' | else | echo 'failed to ".a:cmd.".' | endif", '')
    \   ]
    \ }
  \ })
endf

fun! s:current_branch() abort
  return s:git_exec('rev-parse', '--abbrev-ref HEAD')
endf

fun! simple_git_commands#g_current_branch()
  return s:current_branch()
endf

fun! simple_git_commands#g_insert_current_branch() abort
  let l:pos = getpos('.')
  execute ':normal i' . s:current_branch()
  call setpos('.', l:pos)
endf

fun! simple_git_commands#gsh(bang, option) abort
  try
    let l:current_branch = s:current_branch()

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

    call s:git_async_exec('push '.l:push_opt.' origin '.l:current_branch, 'pushed.')
  catch /failed to rev-parse/
    redraw!
    echo v:exception
  catch /failed to push/
    redraw!
    echo "failed to push '".l:current_branch."' branch."
  endtry
endf

fun! simple_git_commands#g_add_all() abort
  try
    let l:relative_path_to_git_root = s:git_exec('rev-parse', '--show-cdup')

    call s:git_exec('add', l:relative_path_to_git_root.'.')

    checktime
    redraw!
    echo 'added.'
  catch /failed to add/
    redraw!
    echo 'failed to add all.'
  endtry
endf

fun! simple_git_commands#g_reset_all() abort
  try
    call s:git_exec('reset', '')

    checktime
    redraw!
    echo 'reset.'
  catch /failed to reset/
    redraw!
    echo 'failed to reset all.'
  endtry
endf

fun! simple_git_commands#g_clean_m() abort
  try
    if confirm('clean not staged files? ', "&Yes\n&No", 0) != 1
      return 1
    endif

    redraw!

    call s:git_exec('checkout', '.')

    checktime
    redraw!
    echo 'cleaned.'
  catch /failed to checkout/
    redraw!
    echo 'failed to clean.'
  endtry
endf

fun! simple_git_commands#g_clean_u() abort
  try
    if confirm('clean untracked files? ', "&Yes\n&No", 0) != 1
      return 1
    endif

    redraw!

    call s:git_exec('clean', '-f')

    checktime
    redraw!
    echo 'cleaned.'
  catch /failed to clean/
    redraw!
    echo 'failed to clean.'
  endtry
endf

fun! simple_git_commands#g_clean() abort
  try
    if confirm('clean all files? ', "&Yes\n&No", 0) != 1
      return 1
    endif

    redraw!

    call s:git_exec('checkout', '.')
    call s:git_exec('clean', '-f')

    checktime
    redraw!
    echo 'cleaned.'
  catch /failed to checkout/
    redraw!
    echo 'failed to clean.'
  catch /failed to clean/
    redraw!
    echo 'failed to clean.'
  endtry
endf

fun! simple_git_commands#gll_rebase(base_branch) abort
  try
    let l:current_branch = s:current_branch()

    if confirm("rebase '".l:current_branch."' onto '".a:base_branch."'? ", "&Yes\n&No", 0) != 1
      return 1
    endif

    redraw!
    echo "rebasing '".l:current_branch."' branch."

    call s:git_exec('pull --rebase', 'origin '.a:base_branch)

    checktime
    redraw!
    echo 'rebased.'
  catch /failed to rev-parse/
    redraw!
    echo v:exception
  catch /failed to pull --rebase/
    redraw!
    echo "failed to rabase '".l:current_branch."' onto '".a:base_branch."'."
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

fun! simple_git_commands#g_reset_hard() abort
  try
    if confirm("reset 'hard'? ", "&Yes\n&No", 0) != 1
      return 1
    endif

    call s:git_exec('reset', '--hard origin/'.s:current_branch())

    redraw!
    echo 'reset.'
  catch
    redraw!
    echo v:exception
  endtry
endf

fun! simple_git_commands#g_reset_latest() abort
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
