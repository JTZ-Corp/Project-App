
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
    }
}
local objectSheet = graphics.newImageSheet( "gameObjects.png", sheetOptions )
local objectSheet2 = graphics.newImageSheet( "gameObjects2.png", sheetOptions2 )

-- Initialize variables
local lives = 3
local score = 0
local powerlevel = 0
local died = false

local asteroidsTable = {}

local ship
local gameLoopTimer
local livesText
local scoreText
local playNameText
local powerText

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

local _W = display.contentWidth; -- Get the width of the screen
local _H = display.contentHeight; -- Get the height of the screen
local scrollSpeed = 2; -- Set Scroll Speed of background
local bg1
local bg2
local bg3

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


local function fireLaser()

 	-- Play fire sound!
    audio.play( fireSound )

    if(powerlevel >= 10) then

	    local newMegaLaser = display.newImageRect( mainGroup, objectSheet2, 3, 100, 40 )
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

		local newLaser = display.newImageRect( mainGroup, objectSheet, 5, 14, 40 )
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

	elseif ( "moved" == phase ) then
		-- Move the ship to the new touch position
		ship.x = event.x - ship.touchOffsetX
		playNameText.x = event.x - ship.touchOffsetX
		ship.y = event.y - ship.touchOffsetY
		playNameText.y = event.y - ship.touchOffsetY

	elseif ( "ended" == phase or "cancelled" == phase ) then
		-- Release touch focus on the ship
		display.currentStage:setFocus( nil )
	end

	return true  -- Prevents touch propagation to underlying objects
end


local function gameLoop()

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
		end
	} )
end


local function endGame()
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
			 ( obj1.myName == "megalaser" and obj2.myName == "megaroid" ))
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
			if(obj1.myName == "megalaser") then
				display.remove( obj2 )
			elseif(obj2.myName == "megalaser") then
            	display.remove( obj1 )
            else
				display.remove( obj1 )
            	display.remove( obj2 )
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
			powerText.text = "Power: " .. powerlevel

		elseif ( ( obj1.myName == "ship" and obj2.myName == "asteroid" ) or
				 ( obj1.myName == "asteroid" and obj2.myName == "ship" ) or 
			 	( obj1.myName == "megaroid" and obj2.myName == "ship" ) or
			 	( obj1.myName == "ship" and obj2.myName == "megaroid" ))
		then
			if ( died == false ) then
				died = true

				 -- Play explosion sound!
                audio.play( explosionSound )

				-- Update lives
				lives = lives - 1
				livesText.text = "Lives: " .. lives

				if ( lives == 0 ) then
					display.remove( ship )
					display.remove( playNameText )
					timer.performWithDelay( 2000, endGame )
				else
					ship.alpha = 0
					playNameText.alpha = 0
					timer.performWithDelay( 1000, restoreShip )
				end
			end
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
	
	ship = display.newImageRect( mainGroup, objectSheet, 4, 98, 79 )
	ship.x = display.contentCenterX
	ship.y = display.contentHeight - 100
	physics.addBody( ship, { radius=30, isSensor=true } )
	ship.myName = "ship"

    playNameText = display.newText( mainGroup, composer.getVariable( "playerName" ), ship.x, ship.y + 50, native.systemFont, 26 )
    --playNameText.myName = "name"

	-- Display lives and score
	livesText = display.newText( uiGroup, "Lives: " .. lives, 200, 40, native.systemFont, 36 )
	scoreText = display.newText( uiGroup, "Score: " .. score, 400, 40, native.systemFont, 36 )
	powerText = display.newText( uiGroup, "Power: " .. powerlevel, 200, 80, native.systemFont, 26 )

	--background:addEventListener( "tap", fireLaser )
	ship:addEventListener( "touch", dragShip )

 	musicTrack = audio.loadSound( "audio/80s-Space-Game_Looping.wav")
	explosionSound = audio.loadSound( "audio/explosion.wav" )
	fireSound = audio.loadSound( "audio/fire.wav" )

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
 
local function move(event)
	-- move backgrounds to the left by scrollSpeed, default is 8
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
 
-- Create a runtime event to move backgrounds
Runtime:addEventListener( "enterFrame", move )


-- Fire rate
local function fireRate()
	fireLaser()
	-- body
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
		audio.pause( musicTrack )

	else
		volumeLow.isVisible = false
		volume.isVisible = true
		audio.play( musicTrack )
	end

end

local fireLoopTimer
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
		gameLoopTimer = timer.performWithDelay( 500, gameLoop, 0 )
		fireLoopTimer = timer.performWithDelay( 1000, fireLaser, 0)
		        -- Start the music!
        audio.play( musicTrack, { channel=1, loops=-1 } )

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		timer.cancel( gameLoopTimer )

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		Runtime:removeEventListener( "collision", onCollision )
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
end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
