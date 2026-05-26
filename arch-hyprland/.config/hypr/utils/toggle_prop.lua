--- Toggle window properties (opaque / no_blur) per-window.
--- Tracks toggle state in a Lua table keyed by window address.

local toggle = function(prop)
  return function()
    hl.dispatch(hl.dsp.window.set_prop {
      prop = prop,
      value = 'toggle',
    })
  end
end

return {
  no_blur = toggle 'no_blur',
  opaque = toggle 'opaque',
}
