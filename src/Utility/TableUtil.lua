--!strict

local TableUtil = {}

-- Gets the type of the table.
-- Will return "Array", "Dictionary", "Mixed", or "Empty."
-- Will return nil if arg #1 isn't a table.
function TableUtil.GetTableType<K, V>(t: { [K]: V }): string?
	if typeof(t) ~= "table" then return nil end
	if next(t) == nil then return "Empty" end

	local isArray = true
	local isDictionary = true

	for k, _ in next, t do
		if typeof(k) == "number" and k % 1 == 0 and k > 0 then
			isDictionary = false
		else
			isArray = false
		end
	end

	return if isArray then "Array"
		elseif isDictionary then "Dictionary"
		else "Mixed"
end

-- Converts a string path to an array.
function TableUtil.StringPathToArray(path: string, sep: string?, ignoreNumericIndices: boolean?): { string | number }
	ignoreNumericIndices = if ignoreNumericIndices ~= nil then ignoreNumericIndices else false

	local pathArray = {}
	local pattern = if sep then "[^%" .. sep .. "]+" else "[^%/]+"

	if path ~= "" then
		for s in string.gmatch(path, pattern) do
			local v: string | number = s

			if not ignoreNumericIndices then
				local num = string.find(s, "^%d")

				if num then
					v = tonumber(num) or s
				end
			end

			table.insert(pathArray, v)
		end
	end

	return pathArray
end

-- Returns a stringified version of a path array.
-- Will just return directly if a string already.
function TableUtil.PathArrayToString(path: string | { string }, sep: string?)
	if type(path) == "string" then
		return path
	else
		return table.concat(path, sep or "/")
	end
end

-- Parses a table with a table of indexes (the more elements, the more nesting) or a string path and returns the value.
function TableUtil.ParseTableGetValue(tbl: {}, path: { string } | string, delimiter: string?, ignoreNumericIndices: boolean?)
	local pathArray: { string | number } = if type(path) == "string"
		then TableUtil.StringPathToArray(path, delimiter, ignoreNumericIndices)
		else path

	for i = 1, #pathArray - 1 do
		tbl = tbl[pathArray[i]]
	end

	return tbl[pathArray[#pathArray]]
end

-- Parses a table with a table of indexes (the more elements, the more nesting) or a string path and sets the value.
function TableUtil.ParseTableSetValue(tbl: {}, path: { string } | string, value: any?, delimiter: string?, ignoreNumericIndices: boolean?)
	local pathArray: { string | number } = if type(path) == "string"
		then TableUtil.StringPathToArray(path, delimiter, ignoreNumericIndices)
		else path

	for i = 1, #pathArray - 1 do
		tbl = tbl[pathArray[i]]
	end

	tbl[pathArray[#pathArray]] = value
end

return TableUtil