--- If the focused window is Steam, minimize it instead of closing.
--- Called on close (mod+Q, Alt+F4) to prevent accidentally killing Steam.
local dont_kill_steam = function()
  local window = hl.get_active_window()

  return function()
    if window and window.class == 'Steam' then
      -- Move to minimized workspace instead of closing
      hl.dispatch(
        hl.dsp.window.move {
          workspace = 'special:minimized',
          follow = false,
        }
      )
    else
      -- Close the window
      hl.dispatch(hl.dsp.window.close())
    end
  end
end

return dont_kill_steam
