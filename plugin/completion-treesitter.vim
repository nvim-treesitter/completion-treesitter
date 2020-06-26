" Last Change: 2020 avril 12

if !exists('g:loaded_completion') || exists('g:loaded_completion_ts_ns')
	finish
endif

lua require'completion-treesitter'.init()
