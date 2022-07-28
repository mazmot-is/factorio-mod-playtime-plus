if not playtime then playtime = {} end

playtime.play_time_seconds = 0

-- script.on_event(defines.events.on_tick, function(event)
script.on_nth_tick(60, function(event)
  if playtime.play_time_seconds == 0 then
    playtime.play_time_seconds = math.floor(game.tick/60)
  end
  
  local play_time_seconds = math.floor(playtime.play_time_seconds) % 60
  local play_time_minutes = math.floor(playtime.play_time_seconds/60) % 60
  local play_time_hours = math.floor(playtime.play_time_seconds/3600)
--local play_time_hours = math.floor(playtime.play_time_seconds/3600) % 24
--local play_time_days = math.floor(playtime.play_time_seconds/(24*3600))

--/c local x = game.player.gui.screen.add{type="frame", style_mods={margin=0}} x.location={540,0} x.caption=string.format("Total time: %d:%02d:%02d", 0,30,30)

  for i, player in pairs(game.connected_players) do
    if player.gui.screen.clockGUI == nil then
      player.gui.screen.add{type = "button", name = "clockGUI"}
      player.gui.screen.clockGUI.location = {540, 0}
    end
    if play_time_hours > 0 then
      player.gui.screen.clockGUI.caption = string.format("in-game: %d:%02d:%02d", play_time_hours, play_time_minutes, play_time_seconds)
    else
      player.gui.screen.clockGUI.caption = string.format("in-game: %02d:%02d", play_time_minutes, play_time_seconds)
    end
  end
  
  playtime.play_time_seconds = playtime.play_time_seconds + 1
end)

