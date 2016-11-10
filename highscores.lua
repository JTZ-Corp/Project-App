
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- initialize variables
local json = require( "json" )

local WIDTH = display.contentWidth
local HEIGHT = display.contentHeight
local CENTERX = display.contentCenterX
local CENTERY = display.contentCenterY

local scoresTable = {} 	
local base = system.DocumentsDirectory
local path = system.pathForFile( "scores.json", base )

local function loadScores() 
	local file = io.open( path, "r" )
	
	if file then
		local contents = file:read( "*a" )
		io.close( file )
		scoresTable = json.decode( contents )
	end
	if scoresTable == nil then
		scoresTable = {0}
	end
end

local function saveScores()
	for i = #scoresTable, 11, -1 do
	    table.remove(scoresTable, i)
	end
	local file = io.open( path, "w")

	local temp = json.encode(scoresTable)

	file:write( temp )
	io.close(file)
end

local function gotoMenu()
	composer.gotoScene( "menu", { time = 800, effect = "crossFade" } )
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	-- Get the saved score from the last run
	local latestScore = composer.getVariable( "finalScore" )
	local name = composer.getVariable( "playerName" )
    local fromsce = event.params.fromScene
    --print(fromsce)
    
		loadScores()
    -- Check from what scene is called
    if fromsce == "game" then
		-- Load the previous scores

		-- Add our score to the end of the list
		scoresTable[ #scoresTable + 1] = latestScore
		
		-- Now sort the table
		local function compare( a, b )
			return a > b
		end
		if #scoresTable > 1 then 
			table.sort(scoresTable, compare)
		end

		-- go ahead and save the scores
		saveScores()

		composer.setVariable( "playerName", nil)
    end

	local background = display.newImageRect( sceneGroup, "background.png", 800, 1400 )
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	local highScoresText = display.newText(sceneGroup, "High Scores", CENTERX, 100, nil, 34)
	highScoresText:setFillColor(1,1,1)
	for i = 1, 10 do
		local tempY = 150 + (i * 50)
		print("trying to print ", i, scoresTable[i])
		if scoresTable[i] then
			local tempScore = tostring( i ) .. "     ".. tostring( scoresTable[i] )
			local score = display.newText(sceneGroup, tempScore, CENTERX-50, tempY, nil, 34 )
			score.anchorX = 0
			if i == 10 then
				score.x = CENTERX-70
			end
			score:setFillColor( 1, 1, 1 )
		end
	end

	local menuButton = display.newText( sceneGroup, "Menu", display.contentCenterX, 810, native.systemFont, 44 )
	menuButton:setFillColor( 0.75, 0.78, 1 )
	menuButton:addEventListener( "tap", gotoMenu )

end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

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
