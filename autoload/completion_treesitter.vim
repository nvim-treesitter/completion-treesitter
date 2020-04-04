" Last Change: 2020 avr 04

function! completion_treesitter#select_node_at_point()
	let [l:cursor_start, l:cursor_end] = luaeval('require"ts_textobj".node_at_point_range()')

	call cursor(l:cursor_start[0]+1, l:cursor_start[1]+1)
	normal v
	call cursor(l:cursor_end[0]+1, l:cursor_end[1])
endfunction

function! completion_treesitter#select_up()
	let l:sel_start = getpos("'<")
	let l:sel_end = getpos("'>")

	let [l:cursor_start, l:cursor_end] = luaeval(printf(
				\'require"ts_textobj".node_up_range(%d, %d, %d, %d)',
				\l:sel_start[1]-1,
				\l:sel_start[2]-1,
				\l:sel_end[1]-1,
				\l:sel_end[2]-1
				\))

	call cursor(l:cursor_start[0]+1, l:cursor_start[1]+1)
	normal v
	call cursor(l:cursor_end[0]+1, l:cursor_end[1])
endfunction


function! completion_treesitter#select_incr()
	if getpos("'<") == getpos("'>")
		call completion_treesitter#select_node_at_point()
	else
		call completion_treesitter#select_up()
	endif
endfunction
