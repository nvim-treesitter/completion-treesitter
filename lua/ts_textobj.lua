local api = vim.api
local ts = vim.treesitter
local utils = require'ts_utils'

local high_ns = api.nvim_get_namespaces()['completion-treesitter']

local M = {}

local function node_range_to_vim(node)
	local start_row, start_col, end_row, end_col = node:range()

	print("Selected :", node:type())

	return {{start_row, start_col}, {end_row, end_col}}
end

function M.node_at_point_range()
	local node = utils.expression_at_point()
	return node_range_to_vim(node)
end

function M.node_up_range(start_row, start_col, end_row, end_col)
	local root = utils.tree_root()
	local node = root:named_descendant_for_range(start_row, start_col, end_row, end_col)
	return node_range_to_vim(node:parent() or node)
end

function M.context_at_point()
	local parser = ts.get_parser(0)
	local node = utils.expression_at_point()
	local tree = utils.tree_root()

	return node_range_to_vim(utils.smallestContext(tree, parser, node) or tree)
end

function M.find_usages()
	local parser = ts.get_parser(0)
	local node = utils.expression_at_point()
	local tree = utils.tree_root()
	local context = utils.smallestContext(tree, parser, node) or tree

	local ident_query = api.nvim_buf_get_var(bufnr, 'completion_use_query')

	local row_start, _, row_end, _ = tree:range()

	local tsquery = ts.parse_query(parser.lang, string.format(ident_query, utils.get_node_text(node)))

	local usages = {}

	for id, usage in tsquery:iter_captures(context, parser.bufnr, row_start, row_end) do
		local start_row, start_col, _, end_col = usage:range()
		table.insert(usages, {start_row, start_col, end_col})
	end
	return usages
end

return M
