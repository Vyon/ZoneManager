--[[
	This module was written by @Vyon, and is another way to create and handle custom signals without the use of filthy instances like
	bindable events! (jokes)

	[Signal.lua]:
	[Methods]:
		New():
			Constructs an object from the signal class.

			@params: None
			@ret: (signal: Dictionary<string>)

		Connect( self, callback ):
			Creates a new thread to handle the callback.

			@params: (self: Dictionary<string>, callback: Function)
			@ret: (connection: Dictionary<string>)

		Disconnect():
			Closes the handler thread and removes it from _Callbacks for cleanup

			@params: None
			@ret: nil

		Fire( self, ... ):
			Loops through all saved callbacks and fires to each of them with the given arguments

			@params: (self: Dictionary<string>, ...: any)
			@ret: nil

		Wait():
			Yields the current thread until the fire method is used.

			@params: None
			@ret: (arguments: Array<number>)
--]]

local signal = {}
signal.__index = signal
signal.__type = 'LunarScriptSignal'

function signal.New()
	local self = setmetatable({}, signal)
	self._Callbacks = {}
	self._Args = nil

	return self
end

function signal:Connect(callback: any)
	local index = #self._Callbacks + 1
	table.insert(self._Callbacks, callback)

	return {
		Disconnect = function()
			self._Callbacks[index] = nil
		end
	}
end

function signal:Fire(...)
	for _, callback in pairs(self._Callbacks) do
		task.spawn(callback, ...)
	end

	self._Args = {...}

	task.wait()

	self._Args = nil
end

function signal:Wait()
	local _Args = nil

	repeat _Args = self._Args task.wait() until _Args
	return _Args
end

return signal