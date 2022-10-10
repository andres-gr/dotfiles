local colorizer_status_ok, colorizer = pcall(require, 'colorizer')
if not colorizer_status_ok then return end

colorizer.setup {
  filetypes = { '*' },
  user_default_options = {
    RGB = true, -- #RGB hex codes
    RRGGBB = true, -- #RRGGBB hex codes
    RRGGBBAA = true, -- #RRGGBBAA hex codes
    -- css = false, -- Enable all css features: rgb_fn, hsl_fn, names, RGB, RRGGBB
    css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
    -- hsl_fn = false, -- CSS hsl() and hsla() functions
    mode = 'background', -- Set the display mode
    names = false, -- 'Name' codes like Blue
    -- rgb_fn = false, -- CSS rgb() and rgba() functions
  },
}

