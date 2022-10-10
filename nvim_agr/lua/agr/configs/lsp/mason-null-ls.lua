local mason_nls_status_ok, mason_nls = pcall(require, 'mason-null-ls')
if not mason_nls_status_ok then return end

mason_nls.setup {}

mason_nls.setup_handlers {
  function (server)
    require 'agr.core.utils'.null_ls_register(server)
  end,
}

