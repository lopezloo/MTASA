-- PTPM NoSQL data mining

addEventHandler ( "onResourceStart", getRootElement(), function()
	if (source==getResourceRootElement(getThisResource())) then
		-- File management
		local files = { 
			joins = 		"joins.log",
			geo = 			"geo.log",
			deaths = 		"deaths.log",
			performance = 	"performance.log"
		}

		local filePointers = {}

		for id,fileName in pairs(files) do
			if fileExists(fileName) then
				-- Set up append
				local fh = fileOpen ( fileName , true )
				filePointers[id] = fileGetSize(fh)
				fileClose(fh)
			else
				-- Create file
				local newFile = fileCreate(fileName)
				if not newFile then
					outputDebugString("FATAL: Can't create file " .. filename)
					-- die()
					return
				end
				filePointers[id] = 0
			end
		end

		function appendToFile( fileID, theString)
			local fileName = files[fileID]
			local filePos = filePointers[fileID]
			local fh = fileOpen ( fileName )
			fileSetPos ( fh, filePos )
			fileWrite( fh, theString .. "\n")
			filePointers[fileID] = fileGetPos( fh )
			fileClose(fh)
		end
		
		function getElementPositionTwoDecimals(p)
			x,y,z = getElementPosition ( p )
			return math.floor(x*100)/100,math.floor(y*100)/100,math.floor(z*100)/100
		end

		-- Identification (on join)
		-- datetime,<arbitrary rand id (aID; analytics ID)>,nick
		-- it's a random string of 16 chars with 26*2 possibilities (52^16 possibilities)
		function createRandomAnalyticsID()
			local s = ""
			for i = 1, 16 do
				if math.random(1,2)==1 then
					s = s .. string.char(math.random(65, 90))
				else
					s = s .. string.char(math.random(97, 122))
				end
			end
			return s
		end
		
		function getPlayerAID(thePlayer)
			-- Give new ID if they don't have one (when analytics script reloads)	
			local aID = getElementData ( thePlayer, "aID" )
			if aID == false then
				aID = createRandomAnalyticsID()
				outputChatBox(getPlayerName(thePlayer) .. " GETS NEW ID: " .. aID )
				setElementData ( thePlayer, "aID", aID )
			end			
			
			outputDebugString("Req AID for " .. getPlayerName(thePlayer) .. " = " .. aID)
			return aID
		end

		function now()
			local t = getRealTime( )
			return t.timestamp
		end

		addEventHandler( "onPlayerConnect", getRootElement(),
			function ( playerNick )
				-- Attach Analytics ID to client/player
				local aID = createRandomAnalyticsID()
				
				outputChatBox(getPlayerName(thePlayer) .. " GETS NEW ID: " .. aID )
				setElementData ( source, "aID", aID )
				outputDebugString(playerNick .. " = " .. aID)
				
				-- Log join
				appendToFile("joins", now() .. "," .. aID .. "," .. playerNick)
			end
		)

		-- Geo logging (at 10 second interval)
		-- datetime,aID,class=> skinid,x,y,z,interior
		setTimer ( function() 
			for _, p in ipairs( getElementsByType( "player" ) ) do
				if p and isElement( p ) then
					local aID = getPlayerAID(p)
					local x,y,z = getElementPositionTwoDecimals ( p )
					local interior = getElementInterior ( p )
					local playerSkin = getElementModel ( p )
					
					appendToFile("geo", now() .. "," .. aID .. "," .. playerSkin .. "," .. x.. "," .. y.. "," .. z.. "," .. interior)
				end
			end
		end, 10000, 0)


		-- Log player deaths (on death)
		-- datetime,aID[vic],skin[vic],x,y,z,interior,aID[attacker],skin[attacker],weapon,bodypart
		addEventHandler( "onPlayerWasted", getRootElement( ),
			function ( _, attacker, weapon, bodypart )
				local aID = getPlayerAID(source)
				local x,y,z = getElementPositionTwoDecimals ( source )
				local interior = getElementInterior ( source )
				local playerSkin = getElementModel ( source )
				
				outputChatBox("vic=" .. getPlayerName(source ) .. " / " .. aID)
				
				local attackerData = ",,,"-- Four empty cols if there is no attacker
				if (isElement(attacker) and  getElementType ( attacker ) == "player" ) then
					local aaID = getPlayerAID(attacker)
					local attackerSkin = getElementModel ( attacker )
					outputChatBox("killer=" .. getPlayerName(attacker ) .. " / " .. aaID)
					
					attackerData = aaID .. "," .. attackerSkin .. "," .. weapon .. "," .. bodypart
				end
				
				outputChatBox(now() .. "," .. aID .. "," .. playerSkin .. "," .. x .. "," .. y .. "," .. z.. "," .. interior .. "," .. attackerData)
				appendToFile("deaths", now() .. "," .. aID .. "," .. playerSkin .. "," .. x .. "," .. y .. "," .. z.. "," .. interior .. "," .. attackerData)
			end
		)

		-- Log performance data (30 seconds after join)
		-- datetime,aID,ping,exports.admin.country,screenWidth,screenHeight,mtaVersion, dxGetStatus:VideoCardName,dxGetStatus:VideoCardRAM,dxGetStatus:VideoCardName,dxGetStatus:SettingWindowed,dxGetStatus:SettingDrawDistance,dxGetStatus:Setting32BitColor,dxGetStatus:SettingFOV

	end
end)