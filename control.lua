if not playtime then playtime = {} end

playtime.play_time_seconds = -1

script.on_event(defines.events.on_tick, function(event)
	local previous = playtime.play_time_seconds

	playtime.play_time_seconds = math.floor(game.tick/60)

	if previous ~= playtime.play_time_seconds then
	    local play_time_seconds = math.floor(playtime.play_time_seconds) % 60
	    local play_time_minutes = math.floor(playtime.play_time_seconds/60) % 60
		local play_time_hours = math.floor(playtime.play_time_seconds/3600)
--		local play_time_hours = math.floor(playtime.play_time_seconds/3600) % 24
--        	local play_time_days = math.floor(playtime.play_time_seconds/(24*3600))

		for i, player in pairs(game.connected_players) do
			if player.gui.top.clockGUI == nil then player.gui.top.add{type="button", name="clockGUI"} end
			if play_time_hours > 0 then
			   	player.gui.top.clockGUI.caption = string.format("Total time: %d:%02d:%02d", play_time_hours, play_time_minutes, play_time_seconds)
			else
				player.gui.top.clockGUI.caption = string.format("Total time: %02d:%02d", play_time_minutes, play_time_seconds)
			end
		end
	end
end)

