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
	local parser = utils.get_parser()
	local node = utils.expression_at_point()
	local tree = utils.tree_root()

	return node_range_to_vim(utils.smallestContext(tree, parser, node) or tree)
end

local function get_definition(parser, tree, node)
	local node_text = utils.get_node_text(node)
	local final_query = utils.prepare_def_query(string.format('(eq? @def "%s")', node_text))

	local tsquery = ts.parse_query(parser.lang, final_query)
	local row_start, _, row_end, _ = tree:range()
	-- Get current context, and search upwards
	local current_context = node
	repeat
		current_context = utils.smallestContext(tree, parser, current_context)
		for _, def in tsquery:iter_captures(current_context, parser.bufnr, row_start, row_end) do
			return def, current_context
		end

		current_context = current_context:parent()
	until current_context == nil

	return node, tree
end

function M.find_definition()
	local parser = utils.get_parser()
	local node = utils.expression_at_point()

	if node:type() == api.nvim_buf_get_var(parser.bufnr, 'completion_ident_type_name') then
		local tree = utils.tree_root()

		local def, _ = get_definition(parser, tree, node)

		return node_range_to_vim(def)
	else
		return node_range_to_vim()
	end
end

function M.find_usages()
	local parser = utils.get_parser()
	local node = utils.expression_at_point()

	if node:type() == api.nvim_buf_get_var(parser.bufnr, 'completion_ident_type_name') then
		local tree = utils.tree_root()

		-- Get definition
		local definition, scope = get_definition(parser, tree, node)

		local ident_query = '((%s) @ident (eq? @ident "%s"))'
		local ident_type = api.nvim_buf_get_var(parser.bufnr, 'completion_ident_type_name')

		local row_start, _, row_end, _ = tree:range()

		local tsquery = ts.parse_query(parser.lang, string.format(ident_query, ident_type, utils.get_node_text(node)))

		local usages = {}

		for id, usage in tsquery:iter_captures(scope, parser.bufnr, row_start, row_end) do
			local start_row, start_col, _, end_col = usage:range()
			table.insert(usages, {start_row, start_col, end_col})
		end
		return usages
	else
		return {}
	end
end

return M
