local completion = require'completion-treesitter.source'

local M = {}

function M.init()
  completion.register() 
end

return M
