local api = vim.api
local ts = vim.treesitter
local utils = require'ts_utils'

local M = {}

local function prepare_match(query, match)
	local object = {}
	for id, node in pairs(match) do
		local name = query.captures[id] -- name of the capture in the query
		if string.len(name) == 1 then
			object.kind = name
		else
			object[name] = node
		end
	end

	return object
end

function M.getCompletionItems(prefix, score_func, bufnr)
    if utils.has_parser() then
        local tstree = utils.tree_root()

        -- Get all identifiers
		local ident_query = utils.prepare_def_query("")

        local row_start, _, row_end, _ = tstree:range()

        local tsquery = utils.parse_query(ident_query)

        local at_point = utils.expression_at_point()
		local _, line_current, _, _, _ = unpack(vim.fn.getcurpos())

        local complete_items = {}

        -- Step 2 find correct completions
		for pattern, match in tsquery:iter_matches(tstree, bufnr, row_start, row_end) do
			local obj = prepare_match(tsquery, match)

			local node = obj.def
			local node_text = utils.get_node_text(node)
			local node_scope = utils.smallestContext(tstree, node)
			local start_line_node, _, _= node:start()

			-- Only consider items in current scope, and not already met
			local score = score_func(prefix, node_text)
			if score < #prefix/2
				and (utils.is_parent(at_point, node_scope) or obj.kind == "f")
				and (start_line_node <= line_current)
				then
					table.insert(complete_items, {
						word = node_text,
						kind = obj.kind,
						score = score,
						icase = 1,
						dup = 0,
						empty = 1, })
				end
			end

        return complete_items
    else
        return {}
    end
end

M.complete_item = {
	item = M.getCompletionItems
}

if require'source' then
    require'source'.addCompleteItems('ts', M.complete_item)
end

return M
