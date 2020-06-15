" Last Change: 2020 avril 12

if !exists('g:loaded_completion') || exists('g:loaded_completion_ts_ns')
	finish
endif

lua local comp_ts = require'ts_complete'

if !exists('g:complete_ts_highlight_at_point')
	let g:complete_ts_highlight_at_point = 0
endif

if !exists('g:complete_ts_default_mappings')
	let g:complete_ts_default_mappings = 1
end

function! s:text_obj_decl(plug_mapping, default_mapping, funcname)
	let l:formatted_plug = printf('<Plug>(%s)', a:plug_mapping)
	if empty(hasmapto(l:formatted_plug))
		execute printf('vmap %s %s', a:default_mapping, l:formatted_plug)
		execute printf('omap %s %s', a:default_mapping, l:formatted_plug)
	endif

	execute printf("vnoremap <silent> %s :<C-U>call %s()<CR>", l:formatted_plug, a:funcname)
	execute printf("omap <silent> %s :normal v%s<CR>", l:formatted_plug, l:formatted_plug)
endfunction

let g:completion_ts_ns = nvim_create_namespace('completion-treesitter')

call s:text_obj_decl('completion-treesitter-node', 'grn', 'completion_treesitter#select_incr')
call s:text_obj_decl('completion-treesitter-context', 'grc','completion_treesitter#select_context')

command! -nargs=0 CompletionTSSymbols call luaeval("require'ts_navigation'.list_definitions()") | copen

augroup CompletionTS
	autocmd CursorHold *.c,*.py,*.lua,*.ts,*.js,*.java call completion_treesitter#highlight_usages()
	autocmd CursorMoved *.c,*.py,*.lua,*.ts,*.js,*.java call nvim_buf_clear_namespace(0, g:completion_ts_ns, 0, -1)
	autocmd InsertEnter *.c,*.py,*.lua,*.ts,*.js,*.java call nvim_buf_clear_namespace(0, g:completion_ts_ns, 0, -1)
augroup END
