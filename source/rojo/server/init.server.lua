local zone_manager = require(script.ZoneManager).New()
local zone, zone_tag = zone_manager:CreateNewZone(Vector3.new(0, 12.5, 0), Vector3.new(25, 25, 25), false, 'Mald')

zone.OnPlayerEntered:Connect(function(player: Player)
	print(player.Name, 'has entered zone #' .. zone_tag)
end)

zone.OnPlayerExited:Connect(function(player: Player)
	print(player.Name, 'has left zone #' .. zone_tag)
end)

zone_manager:Start()