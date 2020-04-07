local api = vim.api
local ts = vim.treesitter
local utils = require'ts_utils'

local M = {}

function M.getCompletionItems(prefix, score_func, bufnr)
    if utils.has_parser() then
        local tstree = utils.tree_root()

        -- Get all identifiers
		local ident_query = utils.prepare_def_query(""):gsub("@def", "")

        local row_start, _, row_end, _ = tstree:range()

        local tsquery = utils.parse_query(ident_query)

        local at_point = utils.expression_at_point()
        local context_here = utils.context_at_point()

        local complete_items = {}

        -- Step 2 find correct completions
		for pattern, match in tsquery:iter_matches(tstree, bufnr, row_start, row_end) do
			for id, node in pairs(match) do
				local name = tsquery.captures[id] -- name of the capture in the query
				local node_text = utils.get_node_text(node)
				local _, node_scope = utils.get_definition(tstree, node)

				-- Only consider items in current scope, and not already met
				local score = score_func(prefix, node_text)
				if score < #prefix/2
					and (utils.is_parent(at_point, node_scope) or name == "f")
					then
						table.insert(complete_items, {
							word = node_text,
							kind = name,
							score = score,
							icase = 1,
							dup = 0,
							empty = 1, })
				end
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
