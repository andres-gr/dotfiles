local M = {}

M.setup = function ()
  local mason_nls = require 'mason-null-ls'
  local nls = require 'agr.lazy.plugins.lsp.null_ls'

  nls.setup()

  mason_nls.setup {
    handlers = {
      function (server)
        require 'agr.core.utils'.null_ls_register(server)
      end,
    },
  }

end

return M
