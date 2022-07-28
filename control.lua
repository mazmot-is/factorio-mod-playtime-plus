script.on_init(function(event)
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

local function create_gui()
  if not game.players[1] then return end -- satd. prevent error on tutorial
  if game.players[1].gui.screen.ptp_frame then
     global.ptp.frame = game.players[1].gui.screen.ptp_frame
     return
  end

  local player = game.players[1]

  local frame = player.gui.screen.add{type="frame", name="ptp_frame"}
  global.ptp.frame = frame
  frame.style.padding = {0, 6, 0, 6}
  reset_gui_location()

  local label = frame.add{type="label", name="ptp_label"}
  label.drag_target = frame

  save_gui_location()
  save_gui_location()
  update_timer()
end

local function create_gui_wo_index()
  local e = {}
  e.player_index = 1
  create_gui(e)
end

function reset_gui_location()
  global.ptp.frame.location = {settings.global["ptp-x"].value, settings.global["ptp-y"].value}
end

function save_gui_location()
  -- buffering gui location to look one previous location due to
  -- on_gui_location_changed is triggerd AFTER on_player_display_resolution_change
  global.ptp.x1 = global.ptp.x2
  global.ptp.y1 = global.ptp.y2
  global.ptp.x2 = global.ptp.frame.location.x
  global.ptp.y2 = global.ptp.frame.location.y
  -- log(string.format("a %d:%d ", global.ptp.x2, global.ptp.y2))
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

  save_gui_location()
  save_gui_location() -- call twice to override buffering
end


--script.on_event(defines.events.on_player_created, reset_gui_location)
--script.on_event(defines.events.on_player_created, save_gui_location)
--script.on_event(defines.events.on_player_created, save_gui_location) -- call twice to override buffering
script.on_event(defines.events.on_player_created, create_gui)
script.on_configuration_changed(create_gui_wo_index) -- a case where the mod has been applied for existing save
--script.on_event(defines.events.on_player_demoted, create_gui)

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

