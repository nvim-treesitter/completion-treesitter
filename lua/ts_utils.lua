-- Treesitter utils

local api = vim.api
local ts = vim.treesitter

local M = {}

-- Copied from runtime treesitter.lua
function M.get_node_text(node, bufnr)
	local start_row, start_col, end_row, end_col = node:range()
	if start_row ~= end_row then
		return nil
	end
	local line = vim.api.nvim_buf_get_lines(bufnr, start_row, start_row+1, true)[1]
	return string.sub(line, start_col+1, end_col)
end

function M.tree_root(bufnr)
	return ts.get_parser(bufnr or 0):parse():root()
end

function M.has_parser(lang)
    return #api.nvim_get_runtime_file('parser/' .. lang .. '.*', false) > 0
end

-- is dest in a parent of source
function M.is_parent(source, dest)
	local current = source
	while current ~= nil do
		if current == dest then
			return true
		end

		current = current:parent()
	end

	return false
end

function M.expression_at_point(tsroot)
	local tsroot = tsroot or M.tree_root()

	local cursor = vim.api.nvim_win_get_cursor(0)
	local current_node = tsroot:named_descendant_for_range(cursor[1] - 1, cursor[2], cursor[1] - 1, cursor[2])
	return current_node
end

function M.smallestContext(tree, parser, source)
	-- Step 1 get current context
	local contexts_query = ts.parse_query(parser.lang, api.nvim_buf_get_var(parser.bufnr, 'completion_context_query'))

	local row_start, _, row_end, _ = tree:range()
	local contexts = {}

	for _, node in contexts_query:iter_captures(tree, parser.bufnr, row_start, row_end) do
		table.insert(contexts, node)
	end

	local current = source
	while not vim.tbl_contains(contexts, current) and current ~= nil do
		current = current:parent()
	end

	return current
end

return M
