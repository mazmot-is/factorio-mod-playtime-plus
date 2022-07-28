function update_timer()
  -- nothing to do if no player
  if not game then return end
  if not game.players[1] then return end

  -- generate gui if the first loop
  if not playtime_label then
    local frame = game.players[1].gui.screen.add{type="frame"}
    frame.style.padding = {0, 8, 0, 8}
    frame.location = {540, 0}
    playtime_label = frame.add{type="label"}
    playtime_label.drag_target = frame
  end

  -- update timer
  local sec = math.floor(game.tick/60)
  local seconds = math.floor(sec) % 60
  local minutes = math.floor(sec/60) % 60
  local hours = math.floor(sec/3600)
  if hours > 0 then
    playtime_label.caption = string.format("%d:%02d:%02d", hours, minutes, seconds)
  else
    playtime_label.caption = string.format("%02d:%02d", minutes, seconds)
  end
end

script.on_init(update_timer)
script.on_load(update_timer)
script.on_nth_tick(60, update_timer)
