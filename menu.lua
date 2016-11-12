
local composer = require( "composer" )

local scene = composer.newScene()
local nametext
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local sheetOptions =
{
    frames =
    {
        {   -- 4) ship
            x = 0,
            y = 265,
            width = 98,
            height = 79
        }
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
        {   -- 5) arrow
            x = 0,
            y = 970,
            width = 48,
            height = 36
        },
    }
}
local modSheet = graphics.newImageSheet( "modObjects.png", spaceshipOptions )
local objectSheet = graphics.newImageSheet( "gameObjects.png", sheetOptions )

local ship1
local ship2
local ship3
local ship4
local ship5
local ship1Tapped = false
local ship2Tapped = false
local ship3Tapped = false
local ship4Tapped = false
local ship5Tapped = false
local selectedShip = "ship5"


local function gotoGame()
	composer.removeScene( "game" )
	--print(composer.getVariable( "playerName"))
	if (tostring(composer.getVariable( "playerName")) == "nil") then
		composer.setVariable( "playerName", "" )
	end
    local options = { effect = "crossFade", time = 800, params = { shipnum = selectedShip} }
    composer.gotoScene( "game", options )
end

local function gotoHighScores()
	composer.removeScene( "highscores" )
	local options = { effect = "crossFade", time = 800, params = { fromScene = "menu"} }
    composer.gotoScene( "highscores", options )
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	arrowGroup = display.newGroup()  -- Display group for the background image
	sceneGroup:insert( arrowGroup )

	local background = display.newImageRect( sceneGroup, "background.png", 800, 1400 )
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	local title = display.newImageRect( sceneGroup, "title2.png", 550, 100 )
	title.x = display.contentCenterX
	title.y = 300

	local playButton = display.newText( sceneGroup, "Play", display.contentCenterX, 700, native.systemFont, 44 )
	playButton:setFillColor( 0.82, 0.86, 1 )

	local highScoresButton = display.newText( sceneGroup, "High Scores", display.contentCenterX, 810, native.systemFont, 44 )
	highScoresButton:setFillColor( 0.75, 0.78, 1 )

	ship1 = display.newImageRect( sceneGroup, modSheet, 1, 98, 79 )
	ship1.x = display.contentCenterX + 220
	ship1.y = display.contentCenterY 
    ship1.name = "ship1"

    ship2 = display.newImageRect( sceneGroup, modSheet, 2, 98, 79 )
	ship2.x = display.contentCenterX - 110
	ship2.y = display.contentCenterY 
    ship2.name = "ship2"

    ship3 = display.newImageRect( sceneGroup, modSheet, 3, 98, 79 )
	ship3.x = display.contentCenterX
	ship3.y = display.contentCenterY 
    ship3.name = "ship3"

    ship4 = display.newImageRect( sceneGroup, modSheet, 4, 98, 79 )
	ship4.x = display.contentCenterX + 110
	ship4.y = display.contentCenterY 
    ship4.name = "ship4"

    ship5 = display.newImageRect( sceneGroup, objectSheet, 4, 98, 79 )
	ship5.x = display.contentCenterX - 220
	ship5.y = display.contentCenterY - 20
    ship5.name = "ship5"

	playButton:addEventListener( "tap", gotoGame )
	highScoresButton:addEventListener( "tap", gotoHighScores )
	background:addEventListener("tap", backgroundListener)
	
	ship1:addEventListener( "tap", onObjectTap )
	ship2:addEventListener( "tap", onObjectTap )
	ship3:addEventListener( "tap", onObjectTap )
	ship4:addEventListener( "tap", onObjectTap )
	ship5:addEventListener( "tap", onObjectTap )
end
function onObjectTap( event )
	if event.target.name ~= selectedShip then
    	event.target.y = event.target.y - 20
	end
	if ship1.y ~= display.contentCenterY and ship1.name ~= event.target.name then
		ship1.y = ship1.y + 20
	elseif ship2.y ~= display.contentCenterY and ship2.name ~= event.target.name then
		ship2.y = ship2.y + 20
	elseif ship3.y ~= display.contentCenterY and ship3.name ~= event.target.name then
		ship3.y = ship3.y + 20
	elseif ship4.y ~= display.contentCenterY and ship4.name ~= event.target.name then
		ship4.y = ship4.y + 20
	elseif ship5.y ~= display.contentCenterY and ship5.name ~= event.target.name then
		ship5.y = ship5.y + 20
	end
	selectedShip = event.target.name
	print(selectedShip .. " - selected " ) 
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)


	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		nametext = native.newTextField(display.contentCenterX, display.contentCenterY + 100, 300, 50)
		--nametext:setColor( 0.82, 0.86, 1 )
		nametext.placeholder = "Enter Name"
		sceneGroup:insert(nametext)
		nametext:addEventListener("userInput", textListener)
		if (tostring(composer.getVariable( "playerName")) ~= "nil") then
			nametext.text = composer.getVariable( "playerName")
		end
		--print(composer.getVariable( "playerName"))
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		nametext:removeSelf()
		nametext = nil

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end

--Text field event listener
function textListener ( event )
	local phase = event.phase

	if (phase == "began") then
		-- clear text field
		event.target.text = ''
		--print ("waiting")
	elseif (phase == "ended") then
	    -- do something when textfield loses focus
	    --print ( "thank you " .. " " .. event.target.text)
	    composer.setVariable( "playerName", event.target.text )

	elseif (phase == "submitted") then
	    -- do something with the text
	    --print ( "Hello " .. event.target.text)
	    composer.setVariable( "playerName", event.target.text )
	    native.setKeyboardFocus(nil)

	elseif (phase == "editing") then
    	-- do something while editing
    	--print ( event.startPosition )

    end
end

function backgroundListener ( event )
	native.setKeyboardFocus( nil )
end



-- -----------------------------------------------------------------------------------
-- Event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
