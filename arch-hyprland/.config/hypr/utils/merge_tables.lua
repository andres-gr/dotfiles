--- Merges two tables
--- @param t1 table
--- @param t2 table
--- @return table merged_table New merged table
local merge_tables = function(t1, t2)
  local merged_table = t1

  for _, v in pairs(t2) do
    table.insert(merged_table, v)
  end

  return merged_table
end

return merge_tables
