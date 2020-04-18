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

function M.node_incremental()
	local _, sel_start_line, sel_start_col, _ = unpack(vim.fn.getpos("'<"))
	local _, sel_end_line, sel_end_col, _ = unpack(vim.fn.getpos("'>"))

	if utils.has_parser() then
		local root = utils.tree_root()
		local node = root:named_descendant_for_range(sel_start_line-1, sel_start_col-1, sel_end_line-1, sel_end_col)
		local node_start_row, node_start_col, node_end_row, node_end_col = node:range()

		if (sel_start_line-1) == node_start_row and (sel_start_col-1) == node_start_col
			and (sel_end_line-1) == node_end_row and sel_end_col == node_end_col then
			return node_range_to_vim(node:parent() or node)
		else
			return node_range_to_vim(node)
		end
	else
		return node_range_to_vim()
	end
end

function M.context_incremental()
	local _, sel_start_line, sel_start_col, _ = unpack(vim.fn.getpos("'<"))
	local _, sel_end_line, sel_end_col, _ = unpack(vim.fn.getpos("'>"))

	if utils.has_parser() then
		local root = utils.tree_root()
		local node = utils.smallestContext(root,
		root:named_descendant_for_range(sel_start_line-1, sel_start_col-1, sel_end_line-1, sel_end_col))

		local node_start_row, node_start_col, node_end_row, node_end_col = node:range()

		if (sel_start_line-1) == node_start_row and (sel_start_col-1) == node_start_col
			and (sel_end_line-1) == node_end_row and sel_end_col == node_end_col then
			return node_range_to_vim(utils.smallestContext(root, node:parent() or node))
		else
			return node_range_to_vim(node)
		end
	else
		return node_range_to_vim()
	end
end

function M.find_definition()
	if not utils.has_parser() then
		return node_range_to_vim()
	end

	local node = utils.expression_at_point()
	if node:type() == api.nvim_buf_get_var(0, 'completion_ident_type_name') then
		local tree = utils.tree_root()

		local def, _ = utils.get_definition(tree, node)

		if def ~= nil then
			return node_range_to_vim(def.def)
		else
			return node_range_to_vim(node)
		end
	else
		return node_range_to_vim()
	end
end

local function get_usages(tree, node)
	-- Get definition
	local _, scope = utils.get_definition(tree, node)

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
	if not utils.has_parser() then
		return {}
	end

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
