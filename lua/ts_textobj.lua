local api = vim.api
local ts = vim.treesitter
local utils = require'ts_utils'

local high_ns = api.nvim_get_namespaces()['completion-treesitter']

local M = {}

local function node_range_to_vim(node)
	if node then
		local start_row, start_col, end_row, end_col = node:range()

		return {{start_row, start_col}, {end_row, end_col}}
	else
		return {{}, {}}
	end
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
	local node = utils.expression_at_point()
	local tree = utils.tree_root()

	return node_range_to_vim(utils.smallestContext(tree, node) or tree)
end

function M.find_definition()
	local node = utils.expression_at_point()

	if node:type() == api.nvim_buf_get_var(0, 'completion_ident_type_name') then
		local tree = utils.tree_root()

		local def, _ = utils.get_definition(tree, node)

		return node_range_to_vim(def)
	else
		return node_range_to_vim()
	end
end

local function get_usages(tree, node)
		-- Get definition
		local definition, scope = utils.get_definition(tree, node)

		local ident_query = '((%s) @ident (eq? @ident "%s"))'
		local ident_type = api.nvim_buf_get_var(bufnr, 'completion_ident_type_name')

		local row_start, _, row_end, _ = tree:range()

		local tsquery = utils.parse_query(string.format(ident_query, ident_type, utils.get_node_text(node)))

		local usages = {}

		for id, usage in tsquery:iter_captures(scope, 0, row_start, row_end) do
			table.insert(usages, usage)
		end
		return usages
end

function M.find_usages()
	local node = utils.expression_at_point()

	if node:type() == api.nvim_buf_get_var(0, 'completion_ident_type_name') then
		local tree = utils.tree_root()
		local positions = {}

		for _, usage in ipairs(get_usages(tree, node)) do
			local start_row, start_col, _, end_col = usage:range()
			table.insert(positions, {start_row, start_col, end_col})
		end
		return positions
	else
		return {}
	end
end

return M
