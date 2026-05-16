
local D = {}

D.setup = function ()
  local conditions = require 'heirline.conditions'

  return {
    init = function (self)
      self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
      self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
      self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
      self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    end,
    condition = conditions.has_diagnostics,
    static = {
      icons = require 'agr.core.utils'.diagnostics_signs.text,
    },
    update = { 'DiagnosticChanged', 'BufEnter' },
    {
      provider = function (self)
        return self.errors > 0 and (self.icons[vim.diagnostic.severity.ERROR] .. ' ' .. self.errors)
      end,
      hl = { fg = 'diag_ERROR' },
    },
    {
      provider = function (self)
        return self.errors > 0 and (self.warnings > 0 or self.info > 0 or self.hints > 0) and ' '
      end
    },
    {
      provider = function (self)
        return self.warnings > 0 and (self.icons[vim.diagnostic.severity.WARN] .. ' ' .. self.warnings)
      end,
      hl = { fg = 'diag_WARN' },
    },
    {
      provider = function (self)
        return self.warnings > 0 and (self.info > 0 or self.hints > 0) and ' '
      end
    },
    {
      provider = function (self)
        return self.info > 0 and (self.icons[vim.diagnostic.severity.INFO] .. ' ' .. self.info)
      end,
      hl = { fg = 'diag_INFO' },
    },
    {
      provider = function (self)
        return self.info > 0 and self.hints > 0 and ' '
      end
    },
    {
      provider = function (self)
        return self.hints > 0 and (self.icons[vim.diagnostic.severity.HINT] .. ' ' .. self.hints)
      end,
      hl = { fg = 'diag_HINT' },
    },
  }
end

return D
