--- Creates classes regex string from a table of classes strings
--- @param classes string[]
--- @return string regex A classes regex string
local match_classes = function(classes)
  if #classes == 0 then
    return ''
  end

  local result = '^('

  for i, class in ipairs(classes) do
    if i == 1 then
      result = result .. class .. ')$'
      break
    end

    result = result .. '|^(' .. class .. ')$'
  end

  return result
end

return match_classes
