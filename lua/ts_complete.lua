local api = vim.api
local ts = vim.treesitter
local utils = require'ts_utils'

local M = {}

local function smallestContext(tree, parser, source)
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

function M.getCompletionItems(prefix, score_func, bufnr)
    if utils.has_parser(api.nvim_buf_get_option(bufnr, 'ft')) then
        local parser = ts.get_parser(bufnr)
        local tstree = parser:parse():root()

        -- Get all identifiers
        local ident_query = api.nvim_buf_get_var(bufnr, 'completion_ident_query')

        local row_start, _, row_end, _ = tstree:range()

        local tsquery = ts.parse_query(parser.lang, ident_query)

        local at_point = utils.expression_at_point(tstree)
        local context_here = smallestContext(tstree, parser, at_point)

        local complete_items = {}
        local found = {}

        -- Step 2 find correct completions
        for id, node in tsquery:iter_captures(tstree, parser.bufnr, row_start, row_end) do
            local name = tsquery.captures[id] -- name of the capture in the query
            local node_text = utils.get_node_text(node)

            -- Only consider items in current scope, and not already met
            local score = score_func(prefix, node_text)
            if score < #prefix/2
                and (utils.is_parent(node, context_here) or smallestContext(tstree, parser, node) == nil or name == "func")
                and not vim.tbl_contains(found, node_text) then
                table.insert(complete_items, {
                    word = node_text,
                    kind = name,
                    score = score,
                    icase = 1,
                    dup = 1,
                    empty = 1,
                })
                table.insert(found, node_text)
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
