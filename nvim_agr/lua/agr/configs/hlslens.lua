local hls_status, hls = pcall(require, 'hlslens')
if not hls_status then return end

hls.setup()
