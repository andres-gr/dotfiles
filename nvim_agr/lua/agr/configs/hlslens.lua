local hls_status, hls = pcall(require, 'scrollbar.handlers.search')
if not hls_status then return end

hls.setup()
