local U = {}

local function dump (o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

local key_down = vim.api.nvim_replace_termcodes('<Down>', true, true, true)

U.dump = dump
U.key_down = key_down

return U

