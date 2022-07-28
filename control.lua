script.on_init(function()
    global.ptp = {}
end)


local function update_timer()
  local label = global.ptp.frame.ptp_label
  
  local basesec = math.floor(game.tick/60)
  local seconds = math.floor(basesec) % 60
  local minutes = math.floor(basesec/60) % 60
  local hours = math.floor(basesec/3600)
  if hours > 0 then
    label.caption = string.format("%d:%02d:%02d", hours, minutes, seconds)
  else
    label.caption = string.format("%02d:%02d", minutes, seconds)
  end
end

local function create_gui(event)
  if not game.players[event.player_index] then return end -- satd. prevent error on tutorial

  local player = game.players[event.player_index]
  local screen = player.gui.screen

  global.ptp.frame = screen.add{type="frame", name="ptp_frame"}
  global.ptp.frame.style.padding = {0, 6, 0, 6}
  global.ptp.frame.location = {540, 0}

  local label = global.ptp.frame.add{type="label", name="ptp_label"}
  label.drag_target = global.ptp.frame

  save_gui_location()
  save_gui_location()
  update_timer()
end

local function create_gui2()
  local e = {}
  e.player_index = 1
  create_gui(e)
end

local function reset_gui_location()
  global.ptp.frame.location = {540, 0}
end

function save_gui_location()
  -- buffering gui location to look one previous location due to
  -- on_gui_location_changed is triggerd AFTER on_player_display_resolution_change
  global.ptp.x1 = global.ptp.x2
  global.ptp.y1 = global.ptp.y2
  global.ptp.x2 = global.ptp.frame.location.x
  global.ptp.y2 = global.ptp.frame.location.y
  game.print(string.format("a %d:%d ", global.ptp.x2, global.ptp.y2))
end

local function reposition_gui(event)
  if not global.ptp.x1 then return end

  local player = game.players[event.player_index]
  local currw = player.display_resolution.width
  local currh = player.display_resolution.height
  local prevw = event.old_resolution.width
  local prevh = event.old_resolution.height
  local newx = math.floor(global.ptp.x1 / prevw * currw)
  local newy = math.floor(global.ptp.y1 / prevh * currh)
  global.ptp.frame.location = {newx, newy}

  -- update location
  save_gui_location()
  save_gui_location() -- call twice to override buffering
end


--script.on_event(defines.events.on_player_created, save_gui_location)
--script.on_event(defines.events.on_player_created, save_gui_location) -- call twice to override buffering
script.on_event(defines.events.on_player_created, create_gui)
script.on_configuration_changed(create_gui2) -- a case where the mod has been applied for existing save

script.on_nth_tick(60, update_timer)

script.on_event(defines.events.on_gui_click, function(event)
  if event.element.name == "ptp_label" and event.button == defines.mouse_button_type.right then
    reset_gui_location()
    save_gui_location()
    save_gui_location() -- call twice to override buffering
  end
end)

script.on_event(defines.events.on_gui_location_changed, function(event)
  if event.element.name == "ptp_frame" then
    save_gui_location()
  end
end)

script.on_event(defines.events.on_player_display_resolution_changed, function(event)
  reposition_gui(event)
end)


