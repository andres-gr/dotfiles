--- Creates a combined regex matching any of the given class patterns.
--- Produces: ^(pat1)$|^(pat2)$|^(pat3)$
--- @param classes string[]
--- @return string regex
local match_classes = function(classes)
  if #classes == 0 then return '' end

  local parts = {}
  for _, class in ipairs(classes) do
    parts[#parts + 1] = '^(' .. class .. ')$'
  end

  return table.concat(parts, '|')
end

return match_classes
