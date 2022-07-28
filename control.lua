if not ptp then ptp = {} end

function update_timer()
  -- nothing to do if no player
  if not game then return end
  if not game.players[1] then return end

  -- generate gui
  local label = get_ptp_label()
  
  -- update timer
  local sec = math.floor(game.tick/60)
  local seconds = math.floor(sec) % 60
  local minutes = math.floor(sec/60) % 60
  local hours = math.floor(sec/3600)
  if hours > 0 then
    label.caption = string.format("%d:%02d:%02d", hours, minutes, seconds)
  else
    label.caption = string.format("%02d:%02d", minutes, seconds)
  end
end

function get_ptp_label()
  local screen = game.players[1].gui.screen
  if not screen.ptp_frame then
    local frame = screen.add{type="frame", name="ptp_frame"}
    frame.style.padding = {0, 6, 0, 6}
    frame.location = {540, 0}
    local label = frame.add{type="label", name="ptp_label"}
    label.drag_target = frame
  end
  return screen.ptp_frame.ptp_label
end

function save_frame_location()
  if not game then return end
  if not game.players[1] then return end
  ptp.x = game.players[1].gui.screen.ptp_frame.location.x
  ptp.y = game.players[1].gui.screen.ptp_frame.location.y
  game.print(string.format("%d:%d ", x, y))
end

script.on_init(update_timer)
script.on_load(update_timer)
script.on_nth_tick(60, update_timer)

script.on_init(save_frame_location)
script.on_load(save_frame_location)

script.on_event(defines.events.on_gui_click, function(event)
  if event.element.name == "ptp_label" then
    x = game.players[1].gui.screen.ptp_frame.location.x
    y = game.players[1].gui.screen.ptp_frame.location.y
  end
end)

script.on_event(defines.events.on_gui_location_changed, function(event)
  if event.element.name == "ptp_frame" then
    x = game.players[1].gui.screen.ptp_frame.location.x
    y = game.players[1].gui.screen.ptp_frame.location.y
  end
end)

script.on_event(defines.events.on_player_display_resolution_changed, function(event)
  local player = game.players[1]
  local w = player.display_resolution.width
  local h = player.display_resolution.height
  local x = player.gui.screen.ptp_frame.location.x
  local y = player.gui.screen.ptp_frame.location.y
  game.print(string.format("%d:%d  %d:%d", w, h, x, y))
end)


-- reset position
--script.on_event(defines.events.on_gui_click, function(event)
--  if event.element.name == "ptp_label" then
--    local x = game.players[1].gui.screen.ptp_frame.location.x
--    local y = game.players[1].gui.screen.ptp_frame.location.y
--    game.print(string.format("%d:%d", x, y))
--    game.players[1].gui.screen.ptp_frame.location = {540, 0}
--  end
--end)
