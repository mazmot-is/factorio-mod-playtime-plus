local ptplus = {}

local function update_timer()
  local base = math.floor(game.tick/60)
  local seconds = math.floor(base) % 60
  local minutes = math.floor(base/60) % 60
  local hours = math.floor(base/3600)
  local label = ptplus.frame["ptplus-label"]
  if hours > 0 then
    label.caption = string.format("%d:%02d:%02d", hours, minutes, seconds)
  else
    label.caption = string.format("%02d:%02d", minutes, seconds)
  end
end

local function create_gui(player)
  local frame = player.gui.screen.add{type="frame", name="ptplus-frame"}
  frame.style.padding = {0, 6, 0, 6}
  local label = frame.add{type="label", name="ptplus-label"}
  label.drag_target = frame

  ptplus.frame = frame
end

local function init_gui()
  reset_gui_location()
  update_timer()
end

function reset_gui_location()
  ptplus.frame.location = {settings.global["ptplus-x"].value, settings.global["ptplus-y"].value}
  save_gui_location()
  save_gui_location() -- call twice to override buffering
end

function save_gui_location()
  -- buffering gui location to look one previous location due to
  -- on_gui_location_changed() is triggerd AFTER on_player_display_resolution_change()
  ptplus.x1 = ptplus.x2
  ptplus.y1 = ptplus.y2
  ptplus.x2 = ptplus.frame.location.x
  ptplus.y2 = ptplus.frame.location.y
end

local function reposition_gui(event)
  if not ptplus.x1 then return end -- nothing to do if no buffer

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

local function snap_gui(player)
  local margin = 15 -- snap sensitivity
  local x = ptplus.frame.location.x
  local y = ptplus.frame.location.y
  if x < margin then x = 0 end
  if y < margin then y = 0 end
  --if x > player.display_resolution.width - margin then x = player.display_resolution.width end
  --if y > player.display_resolution.width - margin then y = player.display_resolution.height end
  ptplus.frame.location = {x, y}
end
--------------------------------------------------------------------------------
-- event handlers

local function on_player_created(event)
  create_gui(game.players[event.player_index])
  init_gui()
end

local function on_nth_tick_1() -- an altenative to on_init() and on_load() to access game.players[1]
  script.on_nth_tick(1, nil) -- remove myself immediately to run at once

  local player = game.players[1]
  -- if gui not eixsts (e.g., load saved data that does not use ptplus)
  if not player.gui.screen["ptplus-frame"] then
    create_gui(player)
  end
  ptplus.frame = player.gui.screen["ptplus-frame"]
  init_gui()
end

local function on_nth_tick_60()
   update_timer()
end

local function on_gui_click(event)
  if event.element.name == "ptplus-label" and event.button == defines.mouse_button_type.right then
    reset_gui_location()
  end
end

local function on_gui_location_changed(event)
  if event.element.name == "ptplus-frame" then
    snap_gui(game.players[event.player_index])
    save_gui_location()
  end
end

local function on_player_display_resolution_changed(event)
  reposition_gui(event)
end

local function on_runtime_mod_setting_changed(event)
  if event.setting == "ptplus-x" or event.setting == "ptplus-y" then
    reset_gui_location()
  end
end

--------------------------------------------------------------------------------
-- events
script.on_event(defines.events.on_player_created, on_player_created)
script.on_nth_tick(1, on_nth_tick_1)
script.on_nth_tick(60, on_nth_tick_60)
script.on_event(defines.events.on_gui_click, on_gui_click)
script.on_event(defines.events.on_gui_location_changed, on_gui_location_changed)
script.on_event(defines.events.on_player_display_resolution_changed, on_player_display_resolution_changed)
script.on_event(defines.events.on_runtime_mod_setting_changed, on_runtime_mod_setting_changed)
