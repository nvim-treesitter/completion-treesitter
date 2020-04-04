" Last Change: 2020 avr 04

function! s:visual_node(node_range)
	let [l:cursor_start, l:cursor_end] = a:node_range
	call cursor(l:cursor_start[0]+1, l:cursor_start[1]+1)
	normal v
	call cursor(l:cursor_end[0]+1, l:cursor_end[1])
endfunction

function! completion_treesitter#select_node_at_point()
	call s:visual_node(luaeval('require"ts_textobj".node_at_point_range()'))
endfunction

function! completion_treesitter#select_up()
	let l:sel_start = getpos("'<")
	let l:sel_end = getpos("'>")

	let l:node_range = luaeval(printf(
				\'require"ts_textobj".node_up_range(%d, %d, %d, %d)',
				\l:sel_start[1]-1,
				\l:sel_start[2]-1,
				\l:sel_end[1]-1,
				\l:sel_end[2]-1
				\))
	call s:visual_node(l:node_range)
endfunction

function! completion_treesitter#select_incr()
	if getpos("'<") == getpos("'>")
		call completion_treesitter#select_node_at_point()
	else
		call completion_treesitter#select_up()
	endif
endfunction

function! completion_treesitter#select_context()
	call s:visual_node(luaeval('require"ts_textobj".context_at_point()'))
endfunction

function! completion_treesitter#highlight_usages()
	let l:usages = luaeval('require"ts_textobj".find_usages()')

	call nvim_buf_clear_namespace(0, g:completion_ts_ns, 0, -1)

	for [l:line, l:start, l:end] in l:usages
		call nvim_buf_add_highlight(0, g:completion_ts_ns, 'Visual', l:line, l:start, l:end)
	endfor
endfunction
