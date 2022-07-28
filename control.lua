local ptplus = {}

local function update_timer()
  local base = math.floor(game.tick/60)
  local seconds = math.floor(base) % 60
  local minutes = math.floor(base/60) % 60
  local hours = math.floor(base/3600)
  local label = ptplus.frame.ptplus_label
  if hours > 0 then
    label.caption = string.format("%d:%02d:%02d", hours, minutes, seconds)
  else
    label.caption = string.format("%02d:%02d", minutes, seconds)
  end
end

local function create_gui(player)
  local frame = player.gui.screen.add{type="frame", name="ptplus_frame"}
  ptplus.frame = frame
  frame.style.padding = {0, 6, 0, 6}
  local label = frame.add{type="label", name="ptplus_label"}
  label.drag_target = frame
end

local function init_gui()
  reset_gui_location()
  save_gui_location()
  save_gui_location()
  update_timer()
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
end

local function reposition_gui(event)
  if not ptplus.x1 then return end -- can nothing to do

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

--------------------------------------------------------------------------------
-- event handlers

local function on_player_created(event)
  create_gui(game.players[event.player_index])
end

local function on_nth_tick_1() -- an altenative to on_init() and on_load() to access game.players[1]
  script.on_nth_tick(1, nil) -- remove myself immediately to run at once

  -- if gui not eixsts (e.g., load saved data that did not use ptplus)
  if not game.players[1].gui.screen.ptplus_frame then
     create_gui(game.players[1])
  end
  ptplus.frame = game.players[1].gui.screen.ptplus_frame
  init_gui()
end

local function on_nth_tick_60()
   update_timer()
end

local function on_gui_click(event)
  if event.element.name == "ptplus_label" and event.button == defines.mouse_button_type.right then
    reset_gui_location()
    save_gui_location()
    save_gui_location() -- call twice to override buffering
  end
end

local function on_gui_location_changed(event)
  if event.element.name == "ptplus_frame" then
    save_gui_location()
  end
end

local function on_player_display_resolution_changed(event)
  reposition_gui(event)
end

--------------------------------------------------------------------------------
-- events
script.on_event(defines.events.on_player_created, on_player_created)
script.on_nth_tick(1, on_nth_tick_1)
script.on_nth_tick(60, on_nth_tick_60)
script.on_event(defines.events.on_gui_click, on_gui_click)
script.on_event(defines.events.on_gui_location_changed, on_gui_location_changed)
script.on_event(defines.events.on_player_display_resolution_changed, on_player_display_resolution_changed)

