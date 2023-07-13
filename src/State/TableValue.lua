--!nonstrict

--[[
	Constructs and returns objects which can be used to model independent
	reactive state.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
-- Logging
local logError = require(Package.Logging.logError)
-- State
local updateAll = require(Package.State.updateAll)
-- Utility
local isSimilar = require(Package.Utility.isSimilar)
local TableUtil = require(script.Parent.Parent.Utility.TableUtil)

local class = {}

local CLASS_METATABLE = {__index = class}
local WEAK_KEYS_METATABLE = {__mode = "k"}

--[[
	Updates the value stored in this State object.

	If `force` is enabled, this will skip equality checks and always update the
	state object and any dependents - use this with care as this can lead to
	unnecessary updates.
]]
function class:set(newValue: any, force: boolean?)
	if typeof(newValue) ~= "table" then
		warn(`Set error - The new value must be a table! {debug.traceback("Stack - ")}`)
		return
	end

	local oldValue = self._value
	if force or not isSimilar(oldValue, newValue) then
		self._value = newValue
		updateAll(self)
	end
end

--[[
	Inserts a new value into in this array State object.

	If `doNotAllowDuplicates` is true, it will not insert any duplicate values.
]]
function class:insert<V>(value: V, pos: number?, doNotAllowDuplicates: boolean?)
	if TableUtil.GetTableType(self._value) ~= "Array" then
		warn(`Insert only works for array TableValues! {debug.traceback("Stack:")}`)
		return
	end

	if doNotAllowDuplicates and table.find(self._value, value) then return end

	if pos then
		table.insert(self._value, pos, value)
	else
		table.insert(self._value, value)
	end

	updateAll(self)
end

--[[
	Removes an element (BY INDEX) from the array State object.

	NOTE: This method expects the index of the element, if you are attempting to remove by value, please use method `removeByValue`!
]]
function class:remove(index: number)
	if self._value[index] then
		table.remove(self._value, index)
		updateAll(self)
	end
end

--[[
	Removes an element (BY VALUE) from the array State object.
	Helper method - finds the index of the element so you don't have to. :)

	NOTE: This method expects the value of the element, if you are attempting to remove by index, please use method `remove`!
]]
function class:removeByValue<T>(value: T)
	if typeof(self._value) ~= "table" then
		warn(`RemoveByValue error - The state object's value must be a table! {debug.traceback("Stack - ")}`)
		return
	end

	local i = table.find(self._value, value)

	if i then
		table.remove(self._value, i)
		updateAll(self)
	end
end

--[[
	Assigns a value to the key of this table State object.

	If `deepAssignment` is true, the table will be iterated, assuming key is the path, and assign to the result.
]]
function class:assign<K, V>(key: K, value: V, deepAssignment: boolean?, deliminter: string?, ignoreNumericIndices: boolean?)
	if typeof(self._value) ~= "table" then
		warn(`Assign error - The state object's value must be a table! {debug.traceback("Stack - ")}`)
		return
	end

	if deepAssignment then
		if TableUtil.ParseTableGetValue(self._value, key, deliminter, ignoreNumericIndices) then
			TableUtil.ParseTableSetValue(self._value, key, value, deliminter, ignoreNumericIndices)
			updateAll(self)
		end

	else
		self._value[key] = value
		updateAll(self)
	end
end

--[[
	Returns the interior value of this state object.
]]
function class:_peek(): any
	return self._value
end

function class:get()
	logError("stateGetWasRemoved")
end

local function Value<K, V>(initialValue: { [K]: V }): Types.State<{ [K]: V }>
	if typeof(initialValue) ~= "table" then
		warn("Arg #1 must be a table to create a TableValue state object! Returned blank table.")
		initialValue = {}
	end

	local self = setmetatable({
		type = "State",
		kind = "Value",
		-- if we held strong references to the dependents, then they wouldn't be
		-- able to get garbage collected when they fall out of scope
		dependentSet = setmetatable({}, WEAK_KEYS_METATABLE),
		_value = initialValue
	}, CLASS_METATABLE)

	return self
end

return Value