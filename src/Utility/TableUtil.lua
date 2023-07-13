--!strict

--#REVIEW: Consider moving to a separate Wally package for those who only want this module.

-- // LOCAL // --
--#TODO: Require the Fusion package module directly once all types are exposed.
local FusionPubTypes = require(script.Parent.Parent.PubTypes)
local Fusion = require(script.Parent.Parent)

--------------------------------------------------

local FusionUtil = {}

-- Checks to see if a passed value is a Fusion state object.
function FusionUtil.IsState<T>(data: FusionPubTypes.StateObject<T> | T | any): boolean
	if type(data) == "table" and data.type == "State" then
		return true
	end

	return false
end

-- Gets the value from a Fusion value or returns a default value. Optional type checker for third argument.
-- (Originally from: https://github.com/boatbomber/PluginEssentials/blob/main/src/StudioComponents/Util/getState.lua)
function FusionUtil.GetState<T>(data: FusionPubTypes.StateObject<T> | T | any, default: FusionPubTypes.StateObject<T> | T, mustBeKind: string?): FusionPubTypes.StateObject<T> | any
	local stateKind = mustBeKind or "Value"
	local isInputAState = FusionUtil.Unwrap(data, false) ~= data
	local isDefaultAState = FusionUtil.Unwrap(default, false) ~= default

	if isInputAState and (mustBeKind == nil or data.kind == mustBeKind) then
		return data
	elseif data ~= nil then
		return Fusion[stateKind](FusionUtil.Unwrap(data))
	end

	return if isDefaultAState
		then default
		else Fusion[stateKind](default)
end

-- Returns if a Fusion value, wrap into a Fusion value and return if not.
function FusionUtil.ToValue<T>(data: FusionPubTypes.Value<T> | T): FusionPubTypes.Value<T>
	if type(data) == "table" and data.type == "State" then
		return data
	end

	return Fusion.Value(data)
end

-- Returns if a Fusion value, wrap into a Fusion value IF NOT NIL and return if not.
function FusionUtil.ToValueNotNil<T>(data: FusionPubTypes.Value<T> | T, default: T): FusionPubTypes.Value<T>
	if type(data) == "table" and data.type == "State" then
		return data
	end

	return if data ~= nil
		then Fusion.Value(data)
		else Fusion.Value(default)
end

-- Returns if a Fusion value, wrap into a Fusion value IF NOT NIL and return if not.
function FusionUtil.ToValueFormat<T>(data: Fusion.Value<T> | T, format: (data: FusionPubTypes.Value<T> | T) -> (FusionPubTypes.Value<T>)): FusionPubTypes.Value<T>
	if type(data) == "table" and data.type == "State" then
		return data
	end

	return format(data)
end

-- Gets from a Fusion value.
-- (Originally from: https://github.com/boatbomber/PluginEssentials/blob/main/src/StudioComponents/Util/unwrap.lua)
function FusionUtil.Unwrap<T>(data: FusionPubTypes.StateObject<T> | T, useDependency: boolean?): T
	if type(data) == "table" and data.type == "State" then
		return data:get(useDependency)
	end

	return data :: T
end

-- Gets from a Fusion value or defaults to the non nil value.
function FusionUtil.UnwrapNotNil<T>(data: FusionPubTypes.StateObject<T> | T, defaultValue: T, useDependency: boolean?): T
	if type(data) == "table" and data.type == "State" then
		return data:get(useDependency)
	end

	if data ~= nil then
		return data :: T
	else
		return defaultValue
	end
end

return FusionUtil