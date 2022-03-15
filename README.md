# Zone Manager
Simple, easy to use Zone management module.

## Documentation
#### CreateNewZone( self, Position, Size, Visualize, ... ):

	Creates a new zone and sets the position and size to the ones provided.
	The first argument in ... is the tag override so if you want to create custom tags,
	that's the way to go.

	@params: (self: Dictionary<string>, Position: Vector3, Size: Vector3, Visualize: boolean, ...: any)
	@ret: (Zone: Dictionary<string>, Tag: string)

#### CheckZone( self, ZoneName ):
	Uses GetPartBoundsInBox to check if any parts belonging to a player is within the zone.
	This is essentially the core of the ZoneManager module.

	@params: (self: Dictionary<string>, ZoneName: string)
	@ret: nil

#### GetAllPlayersInZone( self, ZoneName ):
	Self explanatory

	@params: (self: Dictionary<string>, ZoneName: string)
	@ret: Array<number>

#### Start( self ):
	Creates a new thread the constantly loops through the _Zones table and calls check zone with the zone name.
	All of this happens on a new thread to prevent the main thread from yielding.

	@params: (self: Dictionary<string>)
	@ret: nil

#### StopAllZones( self ):
	Turns the property IsActive from true to false if IsActive is already true.

	@params: (self: Dictionary<string>)
	@ret: nil

#### CleanUpZone( self, ZoneName ):
	Removes the zone from the _Zones table

	@params: (self: Dictionary<string>, ZoneName: string)
	@ret: nil