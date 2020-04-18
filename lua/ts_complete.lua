local api = vim.api
local ts = vim.treesitter
local utils = require'ts_utils'

local M = {}

local function node_contains(node, point)
	local start_row, start_col, end_row, end_col = node:range()
	return start_row == end_row and start_row == ( point[1] - 1 ) and
	start_col <= (point[2] - 1) and end_col >= (point[2] - 1)
end

local function expected_completion(bufnr, root)
	local query_string = table.concat(api.nvim_buf_get_var(0, "completion_expected_suggestion"))
	local query = utils.parse_query(query_string)

	local cursor = vim.api.nvim_win_get_cursor(0)

	for pattern, match in query:iter_matches(root, bufnr, cursor[1]-1, cursor[1]) do
		local obj = utils.prepare_match(query, match)
		if node_contains(obj.pref, cursor) then
			return obj
		end
	end
end

local function infer_type(bufnr, root, node)
	local node_def = utils.get_definition(root, node)
	if node_def.type ~= nil then
		if node_def.type:named_child_count() > 0 then
			return infer_type(node_def.type)
		else
			return node_def.type
		end
	end
end

function M.getCompletionItems(prefix, score_func, bufnr)
	if utils.has_parser() then
		local tstree = utils.tree_root()

		-- Get all identifiers
		local ident_query = utils.prepare_def_query("@declaration")

		local row_start, _, row_end, _ = tstree:range()

		local tsquery = utils.parse_query(ident_query)

		local at_point = utils.expression_at_point()
		local text_at_point = utils.get_node_text(at_point)
		local expect = expected_completion(bufnr, tstree)

		local _, line_current, _, _, _ = unpack(vim.fn.getcurpos())

		local complete_items = {}

		local should_complete

		if expect == nil then
			-- Classic completion, without members
			should_complete = function (suggestion)
				if suggestion.kind ~= 'm' then
					local start_line_node, _, _= suggestion.def:start()
					local node_scope = utils.smallestContext(tstree, suggestion.def)
					return (start_line_node <= line_current)
					and (suggestion.kind =='f' or utils.is_parent(at_point, node_scope)), suggestion.def
				else
					return false, suggestion.def
				end
			end
		else
			should_complete = function (suggestion)
				if expect.kind == suggestion.kind then
					-- Compute associated informations
					if expect.assoc ~= nil and suggestion.assoc ~= nil then
						local expect_text = utils.get_node_text(expect.assoc)
						local sugg_text = utils.get_node_text(suggestion.assoc)
						return (expect_text == sugg_text), suggestion.def
					elseif expect.type ~= nil and suggestion.type ~= nil then
						-- In this case we need to check the type of the suggestion against expected one
						local expect_type = infer_type(bufnr, tstree, expect.type)
						if expect_type ~= nil then
							local expect_text_type = utils.get_node_text(expect_type)
							local suggestion_text_type = utils.get_node_text(suggestion.type)
							return (expect_text_type == suggestion_text_type), suggestion.def
						else
							return true, suggestion.def
						end
					else
						return true, suggestion.def
					end
				else
					return false, suggestion.def
				end
			end
		end

		local corrected_prefix = string.match(prefix, "[%w_]*$")

		-- Step 2 find correct completions
		for pattern, match in tsquery:iter_matches(tstree, bufnr, row_start, row_end) do
			local obj = utils.prepare_match(tsquery, match)

			local should, node = should_complete(obj)

			local start_line_node, _, _= node:start()
			local node_text = utils.get_node_text(node, bufnr, start_line_node)
			local full_text = utils.get_node_text(obj.declaration, bufnr, start_line_node)

			-- Only consider items in current scope
			local score = score_func(corrected_prefix, node_text)
			if score < #corrected_prefix/2
				and should
				and node_text ~= prefix
				then
					table.insert(complete_items, {
						word = node_text,
						kind = obj.kind,
						score = score,
						icase = 1,
						dup = 0,
						empty = 1,
						user_data = vim.fn.json_encode({hover=full_text}),
					})
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
