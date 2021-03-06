-- returns a table from data that looks like this: "26,150;31,400;37,300"
function commaPairedStringToTable(str)
	local explodedTable = {}

	if not str or #str == 0 then
		return explodedTable
	end
	
	tokens = split(str, string.byte(';'))
	
	if tokens then
		for i, pair in ipairs(tokens) do
			local first = gettok(pair, 1, 44)
			local second = gettok(pair, 2, 44)

			if tonumber(first) then
				first = tonumber(first)
			end

			if tonumber(second) then
				second = tonumber(second)
			end

			explodedTable[i] = {first, second}
		end
	end

	return explodedTable
end


function weaponListToString(weapons, includeAmmo, orderFn)
	if #weapons == 0 then
		return "- No Weapons -"
	end

	local texts = {}

	for i, pair in ipairs(weapons) do
		if pair[1] and pair[2] and pair[1] ~= 0 and pair[2] ~= 0 then
			texts[#texts + 1] = getWeaponNameFromID(pair[1])

			if includeAmmo then
				texts[#texts] = texts[#texts] .. " (" .. tostring(pair[2]) .. ")"
			end
		end
	end	

	if orderFn then
		table.sort(texts, orderFn)
	end

	return table.concat(texts, "\n")
end

function getRunningMapFriendlyNameWrapped()
	local the = ""

	if runningMapName == "ptpm-desert" or runningMapName == "ptpm-country" or runningMapName == "ptpm-factory" then
		the = "the "
	end

	return the .. runningMapFriendlyName
end


function isVehicleOccupied(vehicle)
	local occupants = getVehicleOccupants(vehicle)

	if not occupants then
		return false
	end
	
	for _,_ in pairs(occupants) do
		return true
	end

	return false
end


function getPointOnCircle(radius, rotation)
	return radius * math.cos(math.rad(rotation)), radius * math.sin(math.rad(rotation))
end


function stripColourCodes(s)
	local strippedString = s
	local substitutions = 0

	while true do
		strippedString, substitutions = string.gsub(strippedString, "#%x%x%x%x%x%x", "")

		if substitutions == 0 then
			break
		end
	end

	return strippedString
end

function distanceSquared(aX, aY, aZ, bX, bY, bZ)
	local vX = aX - bX
	local vY = aY - bY
	local vZ = aZ - bZ

	return vX*vX + vY*vY + vZ*vZ
end

function lerp(startValue, endValue, t)
	return startValue + ((endValue - startValue) * t)
end

function getColour(colourName)
	if classColours[colourName] then
		return classColours[colourName]
	end

	if colour[colourName] then
		return colour[colourName]
	end

	return
end

function getCurrentPM()
	return currentPM
end

function isVehicleHeavy(vehicle, model)
	if not model then
		model = getElementModel(vehicle)
	end

	-- hydra or hunter or rhino
	return model == 520 or model == 425 or model == 432
end