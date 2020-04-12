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
	local root = utils.tree_root()
	local line_content = api.nvim_buf_get_lines(0, lnum-1, lnum, false)[1]

	local non_blank = line_content:find("%S")

	if non_blank then
		local start_index = non_blank - 1

		local node_here = root:named_descendant_for_range(lnum -1, start_index, lnum-1, start_index)

		local function is_multiline(node)
			local start, _, stop, _ = node:range()
			return start ~= stop
		end


		-- To determine fold level, count nr of multiline node up from here
		local level = 0
		while node_here ~= nil do
			if is_multiline(node_here) then
				level = level + 1
			end
			node_here = node_here:parent()
		end

		return tostring(level)
	else
		return '='
	end
end

return M
