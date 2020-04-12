" Last Change: 2020 avril 12

function! s:visual_node(node_range)
	let [l:cursor_start, l:cursor_end] = a:node_range
	if !empty(l:cursor_start) && !empty(l:cursor_end)
		call cursor(l:cursor_start[0]+1, l:cursor_start[1]+1)
		normal v
		call cursor(l:cursor_end[0]+1, l:cursor_end[1])
	endif
endfunction

function! completion_treesitter#foldexpr()
	return luaeval(printf('require"ts_navigation".get_fold_indic(%d)', v:lnum))
endfunction

function! completion_treesitter#select_incr()
	call s:visual_node(luaeval('require"ts_textobj".node_incremental()'))
endfunction

function! completion_treesitter#select_context()
	call s:visual_node(luaeval('require"ts_textobj".context_incremental()'))
endfunction

function! completion_treesitter#highlight_usages()
	let l:usages = luaeval('require"ts_textobj".find_usages()')
	let [l:buf, l:cur_line, l:cur_col, l:offset, l:curswant] = getcurpos()

	call nvim_buf_clear_namespace(l:buf, g:completion_ts_ns, 0, -1)

	for [l:line, l:start, l:end] in l:usages
		if (g:complete_ts_highlight_at_point ||
					\ !(( l:line + 1 ) == l:cur_line && l:start < l:cur_col && ( l:end + 1 ) > l:cur_col))
			call nvim_buf_add_highlight(l:buf, g:completion_ts_ns, 'Visual', l:line, l:start, l:end)
		endif
	endfor

	let [l:start, l:end] = luaeval('require"ts_textobj".find_definition()')

	if !empty(l:start) && !empty(l:end) && l:start[0] == l:end[0] &&
				\ ( g:complete_ts_highlight_at_point ||
				\ !(( l:start[0] + 1 ) == l:cur_line && l:start[1] < l:cur_col && ( l:end[1] + 1 ) > l:cur_col) )
		call nvim_buf_add_highlight(l:buf, g:completion_ts_ns, 'Search', l:start[0], l:start[1], l:end[1])
	endif
endfunction

function! completion_treesitter#smart_rename()
	let l:name_new = input('New name : ', expand('<cword>'))

	let l:usages = luaeval('require"ts_textobj".find_usages()')

	for [l:line_nr, l:start, l:end] in reverse(l:usages)
		let l:line = nvim_buf_get_lines(0, l:line_nr, l:line_nr+1, v:false)[0]
		call nvim_buf_set_lines(0, l:line_nr, l:line_nr+1, v:false, [ l:line[:(l:start - 1)] . l:name_new . l:line[l:end:] ])
	endfor
endfunction
