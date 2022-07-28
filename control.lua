local ptplus = {}

local function update_timer()
  local label = ptplus.frame.ptplus_label
  
  local base = math.floor(game.tick/60)
  local seconds = math.floor(base) % 60
  local minutes = math.floor(base/60) % 60
  local hours = math.floor(base/3600)
  if hours > 0 then
    label.caption = string.format("%d:%02d:%02d", hours, minutes, seconds)
  else
    label.caption = string.format("%02d:%02d", minutes, seconds)
  end
end

function create_gui()
  if not game.players[1] then return end -- satd. prevent error on tutorial
  if game.players[1].gui.screen.ptplus_frame then
     ptplus.frame = game.players[1].gui.screen.ptplus_frame
     return
  end

  local player = game.players[1]

  local frame = player.gui.screen.add{type="frame", name="ptplus_frame"}
  ptplus.frame = frame
  frame.style.padding = {0, 6, 0, 6}
  reset_gui_location()

  local label = frame.add{type="label", name="ptplus_label"}
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
  ptplus.frame.location = {settings.global["ptplus-x"].value, settings.global["ptplus-y"].value}
end

function save_gui_location()
  -- buffering gui location to look one previous location due to
  -- on_gui_location_changed is triggerd AFTER on_player_display_resolution_change
  ptplus.x1 = ptplus.x2
  ptplus.y1 = ptplus.y2
  ptplus.x2 = ptplus.frame.location.x
  ptplus.y2 = ptplus.frame.location.y
  -- log(string.format("a %d:%d ", ptplus.x2, ptplus.y2))
end

local function reposition_gui(event)
  if not ptplus.x1 then return end

  local player = game.players[event.player_index]
  local currw = player.display_resolution.width
  local currh = player.display_resolution.height
  local prevw = event.old_resolution.width
  local prevh = event.old_resolution.height
  local newx = math.floor(ptplus.x1 / prevw * currw)
  local newy = math.floor(ptplus.y1 / prevh * currh)
  ptplus.frame.location = {newx, newy}

  save_gui_location()
  save_gui_location() -- call twice to override buffering
end


--script.on_event(defines.events.on_player_created, reset_gui_location)
--script.on_event(defines.events.on_player_created, save_gui_location)
--script.on_event(defines.events.on_player_created, save_gui_location) -- call twice to override buffering
script.on_event(defines.events.on_player_created, create_gui)
--script.on_configuration_changed(create_gui_wo_index) -- a case where the mod has been applied for existing save
--script.on_event(defines.events.on_player_demoted, create_gui)

script.on_nth_tick(1, function(event)
  create_gui()
  game.print("a")
  script.on_nth_tick(1, nil) -- remove myself immediately
end)

script.on_nth_tick(60, update_timer)

script.on_event(defines.events.on_gui_click, function(event)
  if event.element.name == "ptplus_label" and event.button == defines.mouse_button_type.right then
    reset_gui_location()
    save_gui_location()
    save_gui_location() -- call twice to override buffering
  end
end)

script.on_event(defines.events.on_gui_location_changed, function(event)
  if event.element.name == "ptplus_frame" then
    save_gui_location()
  end
end)

script.on_event(defines.events.on_player_display_resolution_changed, function(event)
  reposition_gui(event)
end)

