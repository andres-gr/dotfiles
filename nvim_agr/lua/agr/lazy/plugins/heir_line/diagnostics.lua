
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
      error_icon = vim.fn.sign_getdefined('DiagnosticSignError')[1].text,
      hint_icon = vim.fn.sign_getdefined('DiagnosticSignHint')[1].text,
      info_icon = vim.fn.sign_getdefined('DiagnosticSignInfo')[1].text,
      warn_icon = vim.fn.sign_getdefined('DiagnosticSignWarn')[1].text,
    },
    update = { 'DiagnosticChanged', 'BufEnter' },
    {
      provider = '![',
    },
    {
      provider = function (self)
        -- 0 is just another output, we can decide to print it or not!
        return self.errors > 0 and (self.error_icon .. self.errors)
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
        return self.warnings > 0 and (self.warn_icon .. self.warnings)
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
        return self.info > 0 and (self.info_icon .. self.info)
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
        return self.hints > 0 and (self.hint_icon .. self.hints)
      end,
      hl = { fg = 'diag_HINT' },
    },
    {
      provider = ']',
    },
  }
end

return D
