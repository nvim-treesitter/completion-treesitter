-- Code navigation using Treesitter

local api = vim.api
local ts = vim.treesitter
local utils = require'ts_utils'

local M = {}

function M.list_definitions()
	local bufnr = api.nvim_get_current_buf()
	local ident_query = utils.parse_query(utils.prepare_def_query("@declaration"))

	local root = utils.tree_root()
	local row_start, _, row_end, _ = root:range()

	local qf_list = {}

	for pattern, match in ident_query:iter_matches(root, bufnr, row_start, row_end) do
		local def = utils.prepare_match(ident_query, match)
		local lnum, col, _ = def.def:range()
		local text = utils.get_node_text(def.def)

		table.insert(qf_list, {
			bufnr = bufnr,
			lnum = lnum + 1,
			col = col + 1,
			text = text,
			type = def.kind,
		})
	end

	vim.fn.setqflist(qf_list, 'r')
end

function M.get_fold_indic(lnum)
	if utils.has_parser() then

		local function smallest_multiline_containing(node)
			for index = 0,(node:named_child_count() -1) do
				local child = node:named_child(index)
				local start, _, stop, _ = child:range()

				if start ~= stop and start <= (lnum -1) and stop >= (lnum -1) then
					return smallest_multiline_containing(child)
				end
			end

			return node
		end

		local multiline_here = smallest_multiline_containing(utils.tree_root())

		local start, _, stop, _ = multiline_here:range()

		if start == (lnum -1) then
			return 'a1'
		elseif stop == (lnum -1) then
			return 's1'
		else
			return '='
		end
	else
		return '0'
	end
end

return M
