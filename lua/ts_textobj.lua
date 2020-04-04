local api = vim.api
local ts = vim.treesitter
local utils = require'ts_utils'

local M = {}

function M.node_at_point_range()
	local node = utils.expression_at_point()

	local start_row, start_col, end_row, end_col = node:range()

	return {{start_row, start_col}, {end_row, end_col}}
end

return M
