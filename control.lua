require "constants"

function update_timer(player)
  local base = math.floor(game.tick/60)
  local seconds = math.floor(base) % 60
  local minutes = math.floor(base/60) % 60
  local hours = math.floor(base/3600)
  local label = player.gui.screen[GUI_FRAME_NAME][GUI_LABEL_NAME]
  if hours > 0 then
    label.caption = string.format("%d:%02d:%02d", hours, minutes, seconds)
  else
    label.caption = string.format("%02d:%02d", minutes, seconds)
  end
end

function create_gui(player)
  local frame = player.gui.screen.add{type="frame", name=GUI_FRAME_NAME}
  frame.style.padding = {0, 6, 0, 6}
  local label = frame.add{type="label", name=GUI_LABEL_NAME}
  label.drag_target = frame
end

function init_gui(player)
  global.ptplus[player.name] = {}
  create_gui(player)
  reset_gui_location(player)
  update_timer(player)
end

function destroy_gui(player)
  if player.gui.screen[GUI_FRAME_NAME] then
    player.gui.screen[GUI_FRAME_NAME].destroy()
  end
end

function reset_gui_location(player)
  local x = settings.get_player_settings(player)["ptplus-x"].value
  local y = settings.get_player_settings(player)["ptplus-y"].value
  set_gui_location(player, x, y)
end

function save_gui_location(player)
  local frame = player.gui.screen[GUI_FRAME_NAME]
  -- Buffering gui location to look one previous location due to on_gui_location_changed() is triggerd AFTER on_player_display_resolution_change()
  global.ptplus[player.name].loc1 = global.ptplus[player.name].loc2
  global.ptplus[player.name].loc2 = {x = frame.location.x, y = frame.location.y}
end

function reposition_gui(event, player)
  local currw = player.display_resolution.width
  local currh = player.display_resolution.height
  local prevw = event.old_resolution.width
  local prevh = event.old_resolution.height
  local x = math.floor(global.ptplus[player.name].loc1.x / prevw * currw)
  local y = math.floor(global.ptplus[player.name].loc1.y / prevh * currh)
  set_gui_location(player, x, y)
end

function snap_gui(player)
  local frame = player.gui.screen[GUI_FRAME_NAME]
  local margin = GUI_SNAP_MARGIN -- snap sensitivity
  local x = frame.location.x
  local y = frame.location.y
  if x < margin then x = 0 end
  if y < margin then y = 0 end
  -- [TODO] how to snap to right and bottom w/o accessing gui's width and height?
  --if x > player.display_resolution.width - margin - ?? then x = player.display_resolution.width end
  --if y > player.display_resolution.width - margin - ?? then y = player.display_resolution.height end
  set_gui_location(player, x, y)
end

function set_gui_location(player, x, y)
  local frame = player.gui.screen[GUI_FRAME_NAME]
  frame.location = {x, y}
  save_gui_location(player)
  save_gui_location(player) -- call twice to override buffering
end

--------------------------------------------------------------------------------
-- event handlers
local function on_nth_tick_60()
  for _, player in pairs(game.players) do
    update_timer(player)
  end
end

local function on_configuration_changed(event)
  for _, player in pairs(game.players) do
    -- re-create global vars and frame
    global.ptplus = {}
    destroy_gui(player)
    init_gui(player)
  end
end

local function on_player_created(event)
  local player = game.players[event.player_index]
  init_gui(player)
end

local function on_gui_click(event)
  if event.element.name == GUI_LABEL_NAME and event.button == defines.mouse_button_type.right then
    local player = game.players[event.player_index]
    reset_gui_location(player)
  end
end

local function on_gui_location_changed(event)
  if event.element.name == GUI_FRAME_NAME then
    local player = game.players[event.player_index]
    snap_gui(player)
  end
end

local function on_player_display_resolution_changed(event)
  local player = game.players[event.player_index]
  reposition_gui(event, player)
end

local function on_runtime_mod_setting_changed(event)
  if event.setting == "ptplus-x" or event.setting == "ptplus-y" then
    local player = game.players[event.player_index]
    reset_gui_location(player)
  end
end

script.on_init(function()
  global.ptplus = {}
end)

script.on_nth_tick(60, on_nth_tick_60)
script.on_configuration_changed(on_configuration_changed)
script.on_event(defines.events.on_player_created, on_player_created)
script.on_event(defines.events.on_gui_click, on_gui_click)
script.on_event(defines.events.on_gui_location_changed, on_gui_location_changed)
script.on_event(defines.events.on_player_display_resolution_changed, on_player_display_resolution_changed)
script.on_event(defines.events.on_runtime_mod_setting_changed, on_runtime_mod_setting_changed)
