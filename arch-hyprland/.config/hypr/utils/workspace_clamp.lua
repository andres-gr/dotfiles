--- Pure Lua replacement for hypr-workspace-clamp shell script.
--- Clamps workspace next/prev navigation to stay within the current monitor's workspace IDs.
--- All state is queried at keypress time (inside the closure) to avoid stale cur_id.
--- dir: 'next' | 'prev', action: nil (navigate) | 'move' | 'movesilent'
--- @param dir 'next' | 'prev'
--- @param action 'move' | 'movesilent' | nil
--- @return function
local workspace_clamp = function(dir, action)
  return function()
    local mon = hl.get_active_monitor()
    if not mon then return end

    local ws_list = hl.get_workspaces()
    local ws_ids = {}
    for _, ws in ipairs(ws_list) do
      if ws.monitor == mon then
        table.insert(ws_ids, ws.id)
      end
    end

    table.sort(ws_ids)

    local current_ws = hl.get_active_workspace()
    if not current_ws then return end

    local min_id = ws_ids[1]
    local max_id = ws_ids[#ws_ids]
    local cur_id = current_ws.id

    if dir == 'next' and cur_id < max_id then
      if action ~= nil then
        hl.dispatch(
          hl.dsp.window.move {
            workspace = 'm+1',
            follow = action ~= 'movesilent',
          }
        )
      else
        hl.dispatch(
          hl.dsp.focus { workspace = 'm+1' }
        )
      end
    elseif dir == 'prev' and cur_id > min_id then
      if action ~= nil then
        hl.dispatch(
          hl.dsp.window.move {
            workspace = 'm-1',
            follow = action ~= 'movesilent',
          }
        )
      else
        hl.dispatch(
          hl.dsp.focus { workspace = 'm-1' }
        )
      end
    end
  end
end

return workspace_clamp
