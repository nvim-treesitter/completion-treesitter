" Last Change: 2020 avr 09

if !exists('g:loaded_completion')
	finish
endif

lua local comp_ts = require'ts_complete'

if !exists('g:complete_ts_highlight_at_point')
	let g:complete_ts_highlight_at_point = 0
endif

if !exists('g:complete_ts_default_mappings')
	let g:complete_ts_default_mappings = 1
end

function! s:text_obj_decl(mapping, funcname)
	execute printf("vnoremap <silent> %s :<C-U>call %s()<CR>", a:mapping, a:funcname)
	execute printf("omap <silent> %s :normal v%s<CR>", a:mapping, a:mapping)
endfunction

let g:completion_ts_ns = nvim_create_namespace('completion-treesitter')

if g:complete_ts_default_mappings
	call s:text_obj_decl('gtn', 'completion_treesitter#select_incr')
	call s:text_obj_decl('gtc', 'completion_treesitter#select_context')
else
	call s:text_obj_decl('<Plug>(completion-treesitter-incremental)', 'completion_treesitter#select_incr')
	call s:text_obj_decl('<Plug>(completion-treesitter-context)', 'completion_treesitter#select_context')
endif

augroup CompletionTS
	autocmd CursorHold *.c,*.py,*.lua call completion_treesitter#highlight_usages()
	autocmd CursorMoved *.c,*.py,*.lua call nvim_buf_clear_namespace(0, g:completion_ts_ns, 0, -1)
	autocmd InsertEnter *.c,*.py,*.lua call nvim_buf_clear_namespace(0, g:completion_ts_ns, 0, -1)
augroup END
