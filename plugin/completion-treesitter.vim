" Last Change: 2020 avr 04

if !exists('g:loaded_completion')
	finish
endif

lua local comp_ts = require'ts_complete'

function! s:text_obj_decl(mapping, funcname)
	execute printf("vnoremap <silent> %s :<C-U>call %s()<CR>", a:mapping, a:funcname)
	execute printf("omap <silent> %s :normal v%s<CR>", a:mapping, a:mapping)
endfunction

call s:text_obj_decl('gn', 'completion_treesitter#select_incr')
call s:text_obj_decl('gf', 'completion_treesitter#select_context')
