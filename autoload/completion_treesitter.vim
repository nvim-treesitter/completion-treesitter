" Last Change: 2020 avr 04

function! completion_treesitter#select_node_at_point()
	let [l:cursor_start, l:cursor_end] = luaeval('require"ts_textobj".node_at_point_range()')

	call cursor(l:cursor_start[0]+1, l:cursor_start[1]+1)
	normal v
	call cursor(l:cursor_end[0]+1, l:cursor_end[1])
endfunction
