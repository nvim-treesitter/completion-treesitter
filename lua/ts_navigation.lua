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

return M
