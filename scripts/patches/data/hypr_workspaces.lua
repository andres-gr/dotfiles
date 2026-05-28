local workspaces = {
  {
    monitor = 'desc:{{main_monitor}}',
    workspace = 'prim'
  },
  {
    monitor = 'desc:{{secondary_monitor}}',
    workspace = 'sec'
  },
}

for _, ws in ipairs(workspaces) do
  for i = 1, 4, 1 do
    local workspace = ws.workspace == 'prim' and i or i + 4

    hl.workspace_rule {
      workspace = tostring(workspace),
      monitor = ws.monitor,
      default = i == 1,
      persistent = true,
      default_name = ws.workspace .. i,
    }
  end
end
