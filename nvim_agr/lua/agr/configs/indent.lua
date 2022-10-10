local indent_status_ok, indent = pcall(require, 'indent-o-matic')
if not indent_status_ok then return end

indent.setup {}

