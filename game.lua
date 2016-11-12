
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )

-- Configure image sheet
local sheetOptions =
{
    frames =
    {
        {   -- 1) asteroid 1
            x = 0,
            y = 0,
            width = 102,
            height = 85
        },
        {   -- 2) asteroid 2
            x = 0,
            y = 85,
            width = 90,
            height = 83
        },
        {   -- 3) asteroid 3
            x = 0,
            y = 168,
            width = 100,
            height = 97
        },
        {   -- 4) ship
            x = 0,
            y = 265,
            width = 98,
            height = 79
        },
        {   -- 5) laser
            x = 98,
            y = 265,
            width = 14,
            height = 40
        },
    }
}
local sheetOptions2 =
{
    frames =
    {
        {   -- 1) mega asteroid 1
            x = 0,
            y = 69,
            width = 109,
            height = 90
        },
        {   -- 2) mega asteroid 2
            x = 0,
            y = 166,
            width = 104,
            height = 100
        },
        {   -- 3) mega laser
			x = 11,
            y = 8,
            width = 56,
            height = 46
        },
        {   -- 4) power up
			x = 87,
            y = 2,
            width = 26,
            height = 26
        },
        {   -- 5) big asteroid
			x = 130,
            y = 1,
            width = 185,
            height = 152
        },
        {   -- 6) custom mega shot
			x = 122,
            y = 159,
            width = 63,
            height = 63
        },
        {   -- 7) custom shot
			x = 119,
            y = 227,
            width = 24,
            height = 54
        },
    }
}
local spaceshipOptions =
{
    frames =
    {
        {   -- 1) spaceship 1
            x = 0,
            y = 0,
            width = 269,
            height = 175
        },
        {   -- 2) spaceship 2
            x = 45,
            y = 185,
            width = 197,
            height = 207
        },
        {   -- 3) spaceship 3
            x = 0,
            y = 415,
            width = 281,
            height = 271
        },
        {   -- 4) spaceship 4
            x = 44,
            y = 703,
            width = 197,
            height = 247
        },
        {   -- 5) laser 1
            x = 303,
            y = 79,
            width = 39,
            height = 124
        },
        {   -- 6) laser 2
            x = 355,
            y = 276,
            width = 45,
            height = 141
        },
        {   -- 7) laser 3
            x = 287,
            y = 485,
            width = 58,
            height = 203
        },
        {   -- 8) laser 4
            x = 290,
            y = 861,
            width = 50,
            height = 127
        },
        {   -- 9) megalaser 1
            x = 253,
            y = 0,
            width = 144,
            height = 71
        },
        {   -- 10) megalaser 2
            x = 250,
            y = 214,
            width = 140,
            height = 58
        },
        {   -- 11) megalaser 3
            x = 273,
            y = 382,
            width = 87,
            height = 98
        },
        {   -- 12) megalaser 4
            x = 246,
            y = 696,
            width = 144,
            height = 138
        },
    }
}
local objectSheet = graphics.newImageSheet( "gameObjects.png", sheetOptions )
local objectSheet2 = graphics.newImageSheet( "gameObjects2.png", sheetOptions2 )
local modSheet = graphics.newImageSheet( "modObjects.png", spaceshipOptions )

-- Initialize variables
local lives = 3
local score = 0
local powerlevel = 0
local powerCount = 500
local died = false
local bigAstroid = false
local hitCount = 0;
local minuteCount = 1
local megaShotProfile
local simpleShotProfile
local shipName

local asteroidsTable = {}
local powerTable = {}
local bigAstroidTable = {}
local modProfile

local ship
local gameLoopTimer
local gameLoop2Timer
local fireLoopTimer
local gameClockTimer
local livesText
local scoreText
local playNameText
local powerText
local hitText
local gameTime
local startTime

local backGroup
local mainGroup
local uiGroup

local volume
local volumeLow
local mute = false

-- Sound effects
local explosionSound
local fireSound
local musicTrack
local levelupSound
local bossTrack

local _W = display.contentWidth; -- Get the width of the screen
local _H = display.contentHeight; -- Get the height of the screen
local scrollSpeed = 2; -- Set Scroll Speed of background
local bg1
local bg2
local bg3

local leftWall
local rightWall 
local topWall
local botWall

local function updateText()
	livesText.text = "Lives: " .. lives
	scoreText.text = "Score: " .. score
	powerText.text = "Power: " .. powerlevel
end


local function createAsteroid()

	local whatAsteriod = math.random ( 10 )
	local whereFrom
	if ((whatAsteriod % 5) ~= 0) then

	 	whereFrom = math.random( 3 )
		local newAsteroid = display.newImageRect( mainGroup, objectSheet, whereFrom, 102, 85 )
		table.insert( asteroidsTable, newAsteroid )	
		physics.addBody( newAsteroid, "dynamic", { radius=40, bounce=0.8 } )	
		newAsteroid.myName = "asteroid"


		if ( whereFrom == 1 ) then
			-- From the left
			newAsteroid.x = -60
			newAsteroid.y = math.random( 500 )
			newAsteroid:setLinearVelocity( math.random( 40,120 ), math.random( 20,60 ) )
		elseif ( whereFrom == 2 ) then
			-- From the top
			newAsteroid.x = math.random( display.contentWidth )
			newAsteroid.y = -60
			newAsteroid:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
		elseif ( whereFrom == 3 ) then
			-- From the right
			newAsteroid.x = display.contentWidth + 60
			newAsteroid.y = math.random( 500 )
			newAsteroid:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
		end

		newAsteroid:applyTorque( math.random( -6,6 ) )
	else

		whereFrom = math.random( 2 )
		local megaAsteroid = display.newImageRect( mainGroup, objectSheet2, whereFrom, 160, 125 )
		table.insert( asteroidsTable, megaAsteroid )
		physics.addBody( megaAsteroid, "dynamic", { radius=50, bounce=0.9 } )
		megaAsteroid.myName = "megaroid"

		if ( whereFrom == 1 ) then
			-- From the left
			megaAsteroid.x = math.random( display.contentWidth )
			megaAsteroid.y = -60
			megaAsteroid:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
		elseif ( whereFrom == 2 ) then
			-- From the right
			megaAsteroid.x = display.contentWidth + 60
			megaAsteroid.y = math.random( 500 )
			megaAsteroid:setLinearVelocity( math.random( -100,-60 ), math.random( 20,60 ) )
		end
		
		megaAsteroid:applyTorque( math.random( -6,20 ) )
	end
end

local function createBigAsteroid()

	local newBig = display.newImageRect( mainGroup, objectSheet2, 5, 600, 600 )
	table.insert( bigAstroidTable, newBig )	
	physics.addBody( newBig, "dynamic", { radius=300, bounce=0.8 } )	
	newBig.myName = "big"

	-- From the top
	newBig.x = display.contentCenterX + 10
	newBig.y = -120
	newBig:setLinearVelocity( 0, 40)
	newBig:applyTorque( math.random( -4,4 ) )

end

local function createPower()

	local whereFrom = math.random( 3 )
	local newPower = display.newImageRect( mainGroup, objectSheet2, 4, 40, 40 )
	table.insert( powerTable, newPower )	
	physics.addBody( newPower, "dynamic", { radius=10, bounce=0.8 } )	
	newPower.myName = "power"


	if ( whereFrom == 1 ) then
		-- From the left
		newPower.x = -60
		newPower.y = math.random( 500 )
		newPower:setLinearVelocity( math.random( 40,120 ), math.random( 20,60 ) )
	elseif ( whereFrom == 2 ) then
		-- From the top
		newPower.x = math.random( display.contentWidth )
		newPower.y = -60
		newPower:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
	elseif ( whereFrom == 3 ) then
		-- From the right
		newPower.x = display.contentWidth + 60
		newPower.y = math.random( 500 )
		newPower:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
	end

	--newPower:applyTorque( math.random( -6,6 ) )
end


local function fireLaser()

 	-- Play fire sound!
    audio.play( fireSound )
    local newMegaLaser
    local newLaser 

    if(powerlevel >= 10) then

 		if shipName == "ship5" then
	    	newMegaLaser = display.newImageRect( mainGroup, objectSheet2, 3, 100, 40 )
	    elseif shipName == "ship1" then
	    	newMegaLaser = display.newImageRect( mainGroup, modSheet, 9, 100, 40 )
	    elseif shipName == "ship2" then
	    	newMegaLaser = display.newImageRect( mainGroup, modSheet, 10, 100, 40 )
	    elseif shipName == "ship3" then
	    	newMegaLaser = display.newImageRect( mainGroup, modSheet, 11, 100, 40 )
	    elseif shipName == "ship4" then
	    	newMegaLaser = display.newImageRect( mainGroup, modSheet, 12, 100, 40 )
	    end
		physics.addBody( newMegaLaser, "dynamic", { isSensor=true } )
		newMegaLaser.isBullet = true
		newMegaLaser.myName = "megalaser"

		newMegaLaser.x = ship.x
		newMegaLaser.y = ship.y
		newMegaLaser:toBack()

		transition.to( newMegaLaser, { y=-40, time=700,
			onComplete = function() display.remove( newMegaLaser ) end
		} )
		powerlevel = powerlevel - 10
    else

 		if shipName == "ship5" then
	    	newLaser = display.newImageRect( mainGroup, objectSheet, 5, 14, 40 )
	    elseif shipName == "ship1" then
	    	newLaser = display.newImageRect( mainGroup, modSheet, 5, 14, 40 )	
	    elseif shipName == "ship2" then
	    	newLaser = display.newImageRect( mainGroup, modSheet, 6, 14, 50 )	
	    elseif shipName == "ship3" then
	    	newLaser = display.newImageRect( mainGroup, modSheet, 7, 14, 60 )	
	    elseif shipName == "ship4" then
	    	newLaser = display.newImageRect( mainGroup, modSheet, 8, 14, 40 )	
	    end
		physics.addBody( newLaser, "dynamic", { isSensor=true } )
		newLaser.isBullet = true
		newLaser.myName = "laser"

		newLaser.x = ship.x
		newLaser.y = ship.y
		newLaser:toBack()

		transition.to( newLaser, { y=-40, time=500,
			onComplete = function() display.remove( newLaser ) end
		} )
	end
end


local function dragShip( event )

	local ship = event.target
	local phase = event.phase

	if ( "began" == phase ) then
		-- Set touch focus on the ship
		display.currentStage:setFocus( ship )
		-- Store initial offset position
		ship.touchOffsetX = event.x - ship.x
		ship.touchOffsetY = event.y - ship.y
		--print(ship.touchOffsetX .. ship.touchOffsetY  )

	elseif ( "moved" == phase ) then
		-- Move the ship to the new touch position
		ship.x = event.x - ship.touchOffsetX
		playNameText.x = event.x - ship.touchOffsetX 
		ship.y = event.y - ship.touchOffsetY
		playNameText.y = event.y - ship.touchOffsetY + 50

		--print(ship.x .. ship.y  )

	elseif ( "ended" == phase or "cancelled" == phase ) then
		-- Release touch focus on the ship
		display.currentStage:setFocus( nil )
	end

	return true  -- Prevents touch propagation to underlying objects
end

local function gameLoop2()

    createPower()

	for i = #powerTable, 1, -1 do
		local thisPower = powerTable[i]

		if ( thisPower.x < -100 or
			 thisPower.x > display.contentWidth + 100 or
			 thisPower.y < -100 or
			 thisPower.y > display.contentHeight + 100 )
		then
			display.remove( thisPower )
			table.remove( powerTable, i )
		end
	end
end

local function gameLoop()

	if(bigAstroid == false) then
		-- Create new asteroid
		createAsteroid()
		-- Remove asteroids which have drifted off screen
		for i = #asteroidsTable, 1, -1 do
			local thisAsteroid = asteroidsTable[i]

			if ( thisAsteroid.x < -100 or
				 thisAsteroid.x > display.contentWidth + 100 or
				 thisAsteroid.y < -100 or
				 thisAsteroid.y > display.contentHeight + 100 )
			then
				display.remove( thisAsteroid )
				table.remove( asteroidsTable, i )
			end
		end
	else
		if #bigAstroidTable == 0 then
			createBigAsteroid()
		else
			for i = #bigAstroidTable, 1, -1 do
				local thisAsteroid = bigAstroidTable[i]
				if (thisAsteroid.y > display.contentHeight - (thisAsteroid.height/2) )
				then
					display.remove( ship )
					display.remove( playNameText )
					endGame()
				end
			end
		end
	end
end


local function restoreShip()

	ship.isBodyActive = false
	ship:setLinearVelocity( 0, 0 )
	ship.x = display.contentCenterX
	ship.y = display.contentHeight - 100
    playNameText.x = ship.x
    playNameText.y = ship.y + 50
	-- Fade in the ship
	transition.to( ship, { alpha=1, time=4000,
		onComplete = function()
			ship.isBodyActive = true
			died = false
            playNameText.alpha = ship.alpha
            fireRate()
		end
	} )

end


function endGame()
	if fireLoopTimer then
		timer.cancel(fireLoopTimer)
		fireLoopTimer = nil
	end
	if gameClockTimer then
		timer.cancel(gameClockTimer)
		gameClockTimer = nil
	end
	composer.setVariable( "finalScore", score )
	composer.removeScene( "highscores" )
	local options = { effect = "crossFade", time = 800, params = { fromScene = "game"} }
	composer.gotoScene( "highscores", options )
end



local function onCollision( event )

	if ( event.phase == "began" ) then

		local obj1 = event.object1
		local obj2 = event.object2

		if ( ( obj1.myName == "laser" and obj2.myName == "asteroid" ) or
			 ( obj1.myName == "asteroid" and obj2.myName == "laser" ) or 
			 ( obj1.myName == "megaroid" and obj2.myName == "laser" ) or
			 ( obj1.myName == "laser" and obj2.myName == "megaroid" ) or 

			 ( obj1.myName == "megalaser" and obj2.myName == "asteroid" ) or
			 ( obj1.myName == "asteroid" and obj2.myName == "megalaser" ) or 
			 ( obj1.myName == "megaroid" and obj2.myName == "megalaser" ) or
			 ( obj1.myName == "megalaser" and obj2.myName == "megaroid" ) or
			 
			 ( obj1.myName == "laser" and obj2.myName == "big" ) or
			 ( obj1.myName == "big" and obj2.myName == "laser" ) or
			 ( obj1.myName == "big" and obj2.myName == "megalaser" ) or 
			 ( obj1.myName == "megalaser" and obj2.myName == "big" ))
		then
			-- Check if asteriod is a megaroid
			local isMegaRoid
			if( (obj1.myName == "laser" and obj2.myName == "megaroid") or 
				(obj1.myName == "megaroid" and obj2.myName == "laser") or
				(obj1.myName == "megalaser" and obj2.myName == "megaroid") or 
				(obj1.myName == "megaroid" and obj2.myName == "megalaser"))
			then
				isMegaRoid = true
			else
				isMegaRoid = false
			end
			-- Remove both the laser and asteroid
			if(obj1.myName ~= "big" and obj2.myName ~= "big") then
				if(obj1.myName == "megalaser") then
					display.remove( obj2 )
				elseif(obj2.myName == "megalaser") then
	            	display.remove( obj1 )
	            else
					display.remove( obj1 )
	            	display.remove( obj2 )
	            end
	        else
	        	if hitCount < 190 then 
		        	if(obj1.myName == "big" and (obj2.myName == "laser" or obj2.myName == "megalaser")) then
						display.remove( obj2 )
						if(obj2.myName == "laser") then
							hitCount = hitCount + 1
						else
							hitCount = hitCount + 3
						end
					elseif(obj2.myName == "big" and (obj1.myName == "laser" or obj1.myName == "megalaser")) then
		            	display.remove( obj1 )
		            	if(obj1.myName == "laser") then
							hitCount = hitCount + 1
						else
							hitCount = hitCount + 3
						end
		            end
		        else
		        	display.remove( obj1 )
	            	display.remove( obj2 )
	            	bigAstroid = false
	            	minuteCount = minuteCount + 1
	            	hitCount = 0
	            	for i = #bigAstroidTable, 1, -1 do
						if ( bigAstroidTable[i] == obj1 or bigAstroidTable[i] == obj2 ) then
						table.remove( bigAstroidTable, i )
						break
						end
					end
	            end
            end
			-- Play explosion sound!
            audio.play( explosionSound )

			for i = #asteroidsTable, 1, -1 do
				if ( asteroidsTable[i] == obj1 or asteroidsTable[i] == obj2 ) then
					table.remove( asteroidsTable, i )
					break
				end
			end

			-- Increase score
			if (isMegaRoid == true) then
				score = score + 150
				powerlevel = powerlevel + 2
			else
				score = score + 100
				powerlevel = powerlevel + 1
			end
			scoreText.text = "Score: " .. score
			--powerText.text = "Power: " .. powerlevel
			--hitText.text = "Hits: " .. hitCount

		elseif ( ( obj1.myName == "ship" and obj2.myName == "asteroid" ) or
				 ( obj1.myName == "asteroid" and obj2.myName == "ship" ) or 
			 	( obj1.myName == "megaroid" and obj2.myName == "ship" ) or
			 	( obj1.myName == "ship" and obj2.myName == "megaroid" ) or
				 ( obj1.myName == "big" and obj2.myName == "ship" ) or 
			 	( obj1.myName == "ship" and obj2.myName == "big" ))
		then
			if ( died == false ) then
				died = true

				 -- Play explosion sound!
                audio.play( explosionSound )
                
				-- Update lives
				lives = lives - 1
				powerlevel = 0
				livesText.text = "Lives: " .. lives
				--powerText.text = "Power: " .. powerlevel
				if powerCount > 100 then
					powerCount = powerCount - 100
				end

				if fireLoopTimer then
					timer.cancel(fireLoopTimer)
					fireLoopTimer = nil
				end


				if ( lives == 0 ) then
					display.remove( ship )
					display.remove( playNameText )

					timer.performWithDelay( 2000, endGame )
				else
					ship.alpha = 0
					playNameText.alpha = 0
					powerCount = 0
					timer.performWithDelay( 1000, restoreShip )
				end
			end
		elseif ( ( obj1.myName == "ship" and obj2.myName == "power" ) or
				 ( obj1.myName == "power" and obj2.myName == "ship" ))
		then
			if(obj1.myName == "power") then
				display.remove( obj1 )
			elseif(obj2.myName == "power") then
            	display.remove( obj2 )
            end
			 -- Play explosion sound!
            audio.play( levelupSound )

            for i = #powerTable, 1, -1 do
				if ( powerTable[i] == obj1 or powerTable[i] == obj2 ) then
					table.remove( powerTable, i )
					break
				end
			end

			powerCount = powerCount + 100
			fireRate()

			print(powerCount)
		end
	end
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	physics.pause()  -- Temporarily pause the physics engine

	-- Set up display groups
	backGroup = display.newGroup()  -- Display group for the background image
	sceneGroup:insert( backGroup )  -- Insert into the scene's view group

	mainGroup = display.newGroup()  -- Display group for the ship, asteroids, lasers, etc.
	sceneGroup:insert( mainGroup )  -- Insert into the scene's view group

	uiGroup = display.newGroup()    -- Display group for UI objects like the score
	sceneGroup:insert( uiGroup )    -- Insert into the scene's view group
	
	-- Load the background
	--local background = display.newImageRect( backGroup, "background.png", 800, 1400 )
	--background.x = display.contentCenterX
	--background.y = display.contentCenterY


	bg1 = display.newImageRect( backGroup, "background.png", 800, 1400 )
	bg1.anchorX = 0.0;
	bg1.anchorY = 0.5;
	bg1.x = 0; bg1.y = _H/2;
	 
	-- Add Second Background
	bg2 = display.newImageRect( backGroup, "background.png", 800, 1400 )
	bg2.anchorX = 0.0;
	bg2.anchorY = 0.5;
	bg2.x = 0; bg2.y = bg1.y-1400;
	 
	-- Add Third Background
	bg3 = display.newImageRect( backGroup, "background.png", 800, 1400 )
	bg3.anchorX = 0.0;
	bg3.anchorY = 0.5;
	bg3.x = 0; bg3.y = bg2.y-1400;
	
    shipName = event.params.shipnum
    --playNameText.myName = "name"

	-- Display lives and score
	--startTimeText = display.newText( uiGroup, "", 400, 80, native.systemFont, 36 )

	livesText = display.newText( uiGroup, "Lives: " .. lives, 200, 40, native.systemFont, 36 )
	scoreText = display.newText( uiGroup, "Score: " .. score, 400, 40, native.systemFont, 36 )
	--powerText = display.newText( uiGroup, "Power: " .. powerlevel, 200, 80, native.systemFont, 26 )
	--hitText = display.newText( uiGroup, "Hits: " .. hitCount, 400, 80, native.systemFont, 26 )

	--background:addEventListener( "tap", fireLaser )

 	musicTrack = audio.loadSound( "audio/80s-Space-Game_Looping.wav")
	explosionSound = audio.loadSound( "audio/explosion.wav" )
	fireSound = audio.loadSound( "audio/fire.wav" )
	levelupSound = audio.loadSound( "audio/levelup.wav" )

	--create volume
	volume = display.newImageRect(backGroup, "volume-max.png", 50,50)
	volume.x = display.contentCenterX + 230
	volume.y = display.contentCenterY - 450

	volumeLow = display.newImageRect(backGroup, "volume-low.png", 52,52)
	volumeLow.x = display.contentCenterX + 219
	volumeLow.y = display.contentCenterY - 450
	volumeLow.isVisible = false
 	
 	volume:addEventListener("tap", changeMute)
 	volumeLow:addEventListener("tap", changeMute)
end
 
function updateTime()
	gameTime = os.date( '*t' )
	--print(startTime.sec - gameTime.sec)
	--print(gameTime.min .. ":" .. gameTime.sec)
	if(gameTime.min == startTime.min + minuteCount and gameTime.sec == startTime.sec) then
		print("boss has arrived")
		bigAstroid = true
	end
	-- body
end
function createShip()
	if shipName == "ship5" then
		ship = display.newImageRect( mainGroup, objectSheet, 4, 98, 79 )
	elseif shipName == "ship1" then
		ship = display.newImageRect( mainGroup, modSheet, 1, 98, 79 )
	elseif shipName == "ship2" then
		ship = display.newImageRect( mainGroup, modSheet, 2, 98, 79 )
	elseif shipName == "ship3" then
		ship = display.newImageRect( mainGroup, modSheet, 3, 98, 79 )
	elseif shipName == "ship4" then
		ship = display.newImageRect( mainGroup, modSheet, 4, 98, 79 )
	end
	ship.x = display.contentCenterX
	ship.y = display.contentHeight - 100
	physics.addBody( ship, { radius=30, isSensor=true } )
	ship.myName = "ship"

	ship:addEventListener( "touch", dragShip )
	playNameText = display.newText( mainGroup, "", ship.x, ship.y + 50, native.systemFont, 26 )
	playNameText.text = composer.getVariable( "playerName" )
end
local function move(event)
	-- move backgrounds to the left by scrollSpeed, default is 8
	
 	if bigAstroid == false then
	 	bg1.y = bg1.y + scrollSpeed
		bg2.y = bg2.y + scrollSpeed
		bg3.y = bg3.y + scrollSpeed
		 
		-- Set up listeners so when backgrounds hits a certain point off the screen,
		-- move the background to the right off screen
		 if (bg1.y + bg1.contentWidth) > 2800 then
		  bg1:translate( 0, -2800 )
		 end
		 if (bg2.y + bg2.contentWidth) > 2800 then
		  bg2:translate( 0, -2800 )
		 end
		 if (bg3.y + bg3.contentWidth) > 2800 then
		  bg3:translate( 0, -2800 )
	 	end
 	end
end
 
-- Fire rate
function fireRate()
	if fireLoopTimer then
		timer.cancel(fireLoopTimer)
		fireLoopTimer = nil
	end

	if(powerCount == 0) then
		fireLoopTimer = timer.performWithDelay( 1000, fireLaser, 0)
	elseif(powerCount > 0 and powerCount < 1000) then
		fireLoopTimer = timer.performWithDelay( 1000 - powerCount, fireLaser, 0)
	else
		fireLoopTimer = timer.performWithDelay( 100, fireLaser, 0)
	end
end
--volumer function
function changeMute()
	mute = not mute
	print(mute)
	mutePlay()
end

function mutePlay()
	if (mute) then
		volumeLow.isVisible = true
		volume.isVisible = false
		audio.setVolume( 0 )

	else
		volumeLow.isVisible = false
		volume.isVisible = true
		audio.setVolume( 1 )
	end

end

-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		physics.start()
		Runtime:addEventListener( "collision", onCollision )
		Runtime:addEventListener( "enterFrame", move )
		gameLoopTimer = timer.performWithDelay( 500, gameLoop, 0 )
		gameLoop2Timer = timer.performWithDelay( 10000, gameLoop2, 0 )
		gameClockTimer = timer.performWithDelay( 1000, updateTime, 0)
		startTime = os.date( '*t' )
		fireRate()
		--Add mode for developers
		if(composer.getVariable( "playerName" ) == "jordan" or 
			composer.getVariable( "playerName" ) == "ted" or 
			composer.getVariable( "playerName" ) == "zia" or 
			composer.getVariable( "playerName" ) == "jtz") then
			powerlevel = 10000
			powerCount = 1000
			modProfile = composer.getVariable( "playerName" )
		end
		        -- Start the music!
        audio.play( musicTrack, { channel=1, loops=-1 } )
        createShip()
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		timer.cancel( gameLoopTimer )
		timer.cancel( gameLoop2Timer )
		--timer.cancel( gameClockTimer )

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		Runtime:removeEventListener( "collision", onCollision )
		Runtime:removeEventListener( "enterFrame", move )
		physics.pause()
		 -- Stop the music!
        audio.stop( 1 )
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
    -- Dispose audio!
    audio.dispose( explosionSound )
    audio.dispose( fireSound )
    audio.dispose( musicTrack )
    audio.dispose( levelupSound )
end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------

return scene
