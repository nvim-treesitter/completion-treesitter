local api = vim.api
local ts = vim.treesitter
local utils = require'ts_utils'

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

return M
