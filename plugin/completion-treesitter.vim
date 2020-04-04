" Last Change: 2020 avr 04

if !exists('g:loaded_completion')
	finish
endif

lua local comp_ts = require'ts_complete'

vnoremap <silent> gt :<C-U>call completion_treesitter#select_incr()<CR>
