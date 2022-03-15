--[[
	[ZoneManager.lua]:
	Simple, easy to use zone module.

	[Methods]:
		CreateNewZone( self, Position, Size, Visualize, ... ):
			Creates a new zone and sets the position and size to the ones provided.
			The first argument in ... is the tag override so if you want to create custom tags,
			that's the way to go.

			@params: (self: Dictionary<string>, Position: Vector3, Size: Vector3, Visualize: boolean, ...: any)
			@ret: (Zone: Dictionary<string>, Tag: string)

		CheckZone( self, ZoneName ):
			Uses GetPartBoundsInBox to check if any parts belonging to a player is within the zone.
			This is essentially the core of the ZoneManager module.

			@params: (self: Dictionary<string>, ZoneName: string)
			@ret: nil

		GetAllPlayersInZone( self, ZoneName ):
			Self explanatory

			@params: (self: Dictionary<string>, ZoneName: string)
			@ret: Array<number>

		Start( self ):
			Creates a new thread the constantly loops through the _Zones table and calls check zone with the zone name.
			All of this happens on a new thread to prevent the main thread from yielding.

			@params: (self: Dictionary<string>)
			@ret: nil

		StopAllZones( self ):
			Turns the property IsActive from true to false if IsActive is already true.

			@params: (self: Dictionary<string>)
			@ret: nil

		CleanUpZone( self, ZoneName ):
			Removes the zone from the _Zones table

			@params: (self: Dictionary<string>, ZoneName: string)
			@ret: nil

	Author: @Vyon
--]]

-- Services
local players = game:GetService('Players')

-- Modules
local signal = require(script.Signal)

-- Constants
local CHECK_TIME = .1

-- Main Module
local zone_manager = {}
zone_manager.__index = zone_manager

-- Private Functions
-- Because Roblox doesn't natively support a table.length method I have to do it :)
local function TableLength(table: Dictionary<string> | Array<number>)
	local length = 0

	for _, _ in pairs(table) do
		length += 1
	end

	return length
end

local function GetVisualizationFolder()
	if (workspace:FindFirstChild('ZoneVisualization')) then
		return workspace.ZoneVisualization
	else
		local zones = Instance.new('Folder', workspace)
		zones.Name = 'ZoneVisualization'

		return zones
	end
end

-- Methods:
function zone_manager:_GetZoneByName(zone_name: string)
	return self.Zones[zone_name]
end

function zone_manager:CreateNewZone(position: Vector3, size: Vector3, visualize: boolean, ...)
	local args = {...}

	-- Variadic Arguments
	local tag

	-- Check if the zone is to be visualized
	if (visualize) then
		local part = Instance.new('Part', GetVisualizationFolder())
		part.Anchored = true
		part.CanCollide = false
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		part.Color = Color3.new(1, 0, 0)
		part.Transparency = .75
		part.Size = size
		part.Position = position
	end

	-- Check Variadics
	if (typeof(args[1]) == 'string' and #args[1] > 0) then
		tag = args[1]
	end

	tag = tag or string.format('Zone%d', TableLength(self.Zones) + 1)

	local zone = {}
	-- Properties:
	zone._Players = {}
	zone._Position = position
	zone._Size = size

	-- Signals:
	zone.OnPlayerEntered = signal.New()
	zone.OnPlayerExited = signal.New()

	self.Zones[tag] = zone

	return zone, tag
end

function zone_manager:CheckZone(zone_name: string)
	local zone = self:_GetZoneByName(zone_name)

	local params = OverlapParams.new()
	params.FilterDescendantsInstances = GetVisualizationFolder():GetChildren()
	params.FilterType = Enum.RaycastFilterType.Blacklist

	local results = workspace:GetPartBoundsInBox(CFrame.new(zone._Position), zone._Size, params)
	local found_players = {}

	for _, part in ipairs(results) do
		local character = part:FindFirstAncestorOfClass('Model')

		if (character and players:GetPlayerFromCharacter(character)) then
			local player = players:GetPlayerFromCharacter(character)

			table.insert(found_players, player)

			if (not table.find(zone._Players, player)) then
				table.insert(zone._Players, player)

				zone.OnPlayerEntered:Fire(player)
			end
		end
	end

	for _, player in ipairs(zone._Players) do
		if (not table.find(found_players, player)) then
			zone.OnPlayerExited:Fire(player)
			table.remove(zone._Players, table.find(zone._Players, player))
		end
	end
end

function zone_manager:GetAllPlayersInZone(zone_name: string)
	return self.Zones[zone_name]._Players
end

function zone_manager:Start()
	-- Make sure the ZoneManager doesn't start more than once.
	if (self.IsActive) then
		return
	else
		self.IsActive = true
	end

	task.spawn(function()
		while self.IsActive do
			for zone_name, _ in pairs(self.Zones) do
				-- Create new thread to check the zone so we don't yield the current thread from checking other zones.
				task.spawn(self.CheckZone, self, zone_name)
			end

			task.wait(CHECK_TIME)
		end
	end)
end

-- Kills the thread that is created from ZoneManager:Start()
function zone_manager:StopAllZones()
	self.IsActive = false
end

-- Remove zone from the zones table so it can be gced
function zone_manager:CleanUpZone(zone_name: string)
	self.Zones[zone_name] = nil
end

return {
	New = function()
		local self = {}
		self.IsActive = false
		self.Zones = {}

		setmetatable(self, zone_manager)

		return self
	end
}