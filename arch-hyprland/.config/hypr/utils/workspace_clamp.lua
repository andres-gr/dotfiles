--- Pure Lua replacement for hypr-workspace-clamp shell script.
--- Clamps workspace next/prev navigation to stay within the current monitor's regular workspace IDs.
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
    local regular_ws_ids = {} -- Only regular workspace IDs (for clamping)
    for _, ws in ipairs(ws_list) do
      if ws.monitor == mon then
        -- Consider a workspace "regular" if its ID is a positive integer
        -- Special workspaces (like scratchpad, minimized) typically have non-positive IDs
        if type(ws.id) == "number" and ws.id > 0 and math.floor(ws.id) == ws.id then
          table.insert(regular_ws_ids, ws.id)
        end
      end
    end

    table.sort(regular_ws_ids)

    local current_ws = hl.get_active_workspace()
    if not current_ws then return end

    -- Use regular workspaces for clamping boundaries
    local min_id = regular_ws_ids[1]
    local max_id = regular_ws_ids[#regular_ws_ids]
    local cur_id = current_ws.id

    -- Only allow navigation if within regular workspace boundaries
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
