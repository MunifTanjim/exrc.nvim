function! s:Source(reset)
  lua require("exrc.state").setup()
  if a:reset
    lua require("exrc").source(true)
  else
    lua require("exrc").source()
  endif
endfunction

command! -bang ExrcSource :call <SID>Source(<bang>0)
