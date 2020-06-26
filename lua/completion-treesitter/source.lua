local ts_locals = require'nvim-treesitter.locals'
local parsers = require'nvim-treesitter.parsers'
local ts_utils = require'nvim-treesitter.ts_utils'
local match_api = require'completion.matching'
local api = vim.api

local M = {}

M.match_kinds = {
  var = 'v',
  method = 'm',
  ['function'] = 'f'
}

local function get_smallest_context(source)
  local scopes = ts_locals.get_scopes()
  local current = source

  while current ~= nil and not vim.tbl_contains(scopes, current) do
    current = current:parent()
  end

  return current or nil
end

local function prepare_match(match, kind)
  local matches = {}

  if match.node then
    table.insert(matches, { kind = M.match_kinds[kind] or '', def = match.node })
  else
    -- Recursion alert! Query matches can be nested N times deep (usually only 1 or 2).
    -- Go down until we find a node.
    for name, item in pairs(match) do
      vim.list_extend(matches, prepare_match(item, name))
    end
  end

  return matches 
end

function M.getCompletionItems(prefix, score_func, bufnr)
  if parsers.has_parser() then
    local at_point = ts_utils.get_node_at_cursor()
    local _, line_current, _, _, _ = unpack(vim.fn.getcurpos())

    local complete_items = {}
    -- Support completion-nvim customized label map
    local customized_labels = vim.g.completion_customize_lsp_label or {}

    -- Step 2 find correct completions
    for _, definitions in ipairs(ts_locals.get_definitions(bufnr)) do
      local matches = prepare_match(definitions)

      for _, match in ipairs(matches) do
        local node = match.def
        local node_scope = get_smallest_context(node)
        local start_line_node, _, _= node:start()

        local node_text = ts_utils.get_node_text(node, bufnr)[1]
        local full_text = vim.trim(
          api.nvim_buf_get_lines(bufnr, start_line_node, start_line_node + 1, false)[1] or '')

        if node_text 
          and (not node_scope or ts_utils.is_parent(node_scope, at_point) or match.kind == "f") 
          and (start_line_node <= line_current) then

          match_api.matching(complete_items, prefix, {
            word = node_text,
            kind = customized_labels[match.kind] or match.kind,
            menu = full_text,
            score = score,
            icase = 1,
            dup = 0,
            empty = 1
          })
        end
      end
    end

    return complete_items
  else
    return {}
  end
end

function M.register()
  if require'completion' then
    require'completion'.addCompletionSource('ts', M.complete_item)
  end
end

M.complete_item = {
  item = M.getCompletionItems
}

return M
