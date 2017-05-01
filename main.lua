--[[

This app runs a game very similar to the game Amazing Brick, developed by KetchApp. However, this game is called
Amazing Ball, and instead of using a brick to avoid obstacles, it uses a ball. (Please don't sue me, KetchApp).

@author Jonathan Lane-Smith

]]

-- This function runs the entire program
function Program()

	-- Hides status bar
	display.setStatusBar( display.HiddenStatusBar )
	
	-- Enables widgets
	widget = require("widget")

	-- Enables physics
	physics = require("physics")

	-- Creates white background
	background = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth + 100, display.contentHeight + 100)
	background:setFillColor(1,1,1)

	-- Imports music and sound effects
	music = audio.loadSound("Audio/music.wav")
	click = audio.loadSound("Audio/click.wav")
	crash = audio.loadSound("Audio/error.wav")
	point = audio.loadSound("Audio/point.wav")

	-- Declares audio variables
	musicon = true
	soundon = true
	playing = true

	-- Plays music
	audio.play(music, {channel=1, loops=-1})
	audio.setVolume(0.2, {channel=1})
	
	-- This function displays the game over menu
	function GOMenu()

		-- Removes score in top right corner
		myscore.text = ""

		-- Displays "GAME OVER" and final score
		gameover = display.newImage("Images/gameover.png", display.contentCenterX, 100)
		finalscore = display.newText("Score: "..score, display.contentCenterX, 170, native.systemFont, 18)
		finalscore:setFillColor(0,0,0)

		-- This function removes the game over menu
		function RemoveGOMenu()

			-- Removes the on-screen elements
	    	gameover:removeSelf()
			playbutton:removeSelf()
			homebutton:removeSelf()
			finalscore:removeSelf()

			-- Determines whether to play game or go back to menu
			if choice == "play" then
				Game()
			elseif choice == "home" then
				TitleMenu()
			end		

		end	-- end of RemoveGOMenu

		-- This function fades the on-screen elements of the game over menu
		function FadeGOMenu()

			transition.to(gameover, {time=100, alpha=0.0})
			transition.to(playbutton, {time=100, alpha=0.0})
			transition.to(homebutton, {time=100, alpha=0.0})
			transition.to(finalscore, {time=100, alpha=0.0, onComplete=RemoveGOMenu})

		end	-- end of FadeGOMenu

		-- This function occurs when the play button is clicked
		local function PlayClick( event )

			-- If the play button is pressed and sound is on
			if ("began" == event.phase and soundon == true) then

				-- Plays sound effect
				audio.play(click, {channel=2, duration=100})
				audio.setVolume(0.2, {channel=2})
			end

			-- If the play button is released
		    if ("ended" == event.phase) then

		    	-- Fades and removes the game over menu
				choice = "play"
				FadeGOMenu()
		    end

		end -- end of PlayClick

		-- Creates the play button
		playbutton = widget.newButton
		{
		    width = 240,
		    height = 70,
		    defaultFile = "Images/play.png",
		    overFile = "Images/play-over.png",
		    onEvent = PlayClick
		}
		-- Positions the play button
		playbutton.x = display.contentCenterX
		playbutton.y = 265

		-- This function occurs when the home button is clicked
		local function HomeClick( event )

			-- If the home button is pressed and sound is on
			if ("began" == event.phase and soundon == true) then

				-- Plays sound effect
				audio.play(click, {channel=2, duration = 100})
				audio.setVolume(0.2, {channel=2})
			end

			-- If the home button is released
		    if ("ended" == event.phase ) then

		    	-- Fades and removes the game over menu
		    	choice = "home"
		    	FadeGOMenu()
		    end

		end -- end of HomeClick

		-- Creates the home button
		homebutton = widget.newButton
		{
		    width = 240,
		    height = 70,
		    defaultFile = "Images/home.png",
		    overFile = "Images/home-over.png",
		    onEvent = HomeClick
		}
		-- Positions the home button
		homebutton.x = display.contentCenterX
		homebutton.y = 400

	end	-- end of GOMenu

	-- This function prepares and plays the game
	function Game()	
	
		-- Defines variables
		obstaclecount = 3 -- Number of obstacles passed 
		gaplength = 70 -- Length of gap between obstacles
		obsheight = 30 -- Height of obstacles
		finished = false -- Whether the game has finished or not
		start = false -- Whether the game has started or not
		upsidedown = false -- Whether gravity has inverted or not

		-- Defines tables
		obs = {} -- Obstacles
		velocity = {} -- velocity of obstacles
		velocity[1] = {} -- Horizontal velocity
		velocity[2] = {} -- Vertical velocity

		points = {} -- A point for each obstacle 
		for i=1,8 do
			points[i] = false -- Whether the obstacle has given its point
		end
		
		-- Starts physics and sets gravity
		physics.start()
		physics.setGravity(0, 25)

		-- Displays instructions
		instructions = display.newImage("Images/Instructions.png", display.contentCenterX, 340)

		-- Creates ball and applies physics to it
		ball = display.newCircle(display.contentCenterX, 370, 10)
		ball:setFillColor(0,0,0)
		physics.addBody( ball, "static", { radius=10 } )

		-- Creates the first two bars, randomly positioned and randomly coloured (but the same colour)
		bar1width = math.random(0, display.contentWidth-gaplength)
		r1,g1,b1 = math.random(10, 90)/100, math.random(10, 90)/100, math.random(10, 90)/100
		obs[1] = display.newRect(bar1width - display.contentWidth/2, 200, display.contentWidth, obsheight)
		obs[1]:setFillColor(r1,g1,b1)
		obs[2] = display.newRect(bar1width + display.contentWidth/2 + gaplength, 200, display.contentWidth, obsheight)
		obs[2]:setFillColor(r1,g1,b1)

		-- Creates first obstacle, randomly positioned, but the same colour as the first bars
		dot1position = math.random(obsheight/2, display.contentWidth - obsheight/2)
		r3,g3,b3 = r1,g1,b1
		obs[3] = display.newRect(dot1position, 105, obsheight, obsheight)
		obs[3]:setFillColor(r3,g3,b3)
		
		-- Creates second obstacle, randomly positioned, but the same colour as the first bars
		dot2position = math.random(obsheight/2, display.contentWidth - obsheight/2)
		r4,g4,b4 = r1,g1,b1	
		obs[4] = display.newRect(dot2position, 10, obsheight, obsheight)		
		obs[4]:setFillColor(r4,g4,b4)

		-- Creates the next two bars, randomly positioned and randomly coloured (but the same colour)
		bar2width = math.random(0, 220)
		r5,g5,b5 = math.random(10, 90)/100, math.random(10, 90)/100, math.random(10, 90)/100
		obs[5] = display.newRect(bar2width - display.contentWidth/2, -85, display.contentWidth, obsheight)
		obs[5]:setFillColor(r5,g5,b5)
		obs[6] = display.newRect(bar2width + display.contentWidth/2 + gaplength, -85, display.contentWidth, obsheight)
		obs[6]:setFillColor(r5,g5,b5)

		-- Creates third obstacle, randomly positioned, but the same colour as the next bars
		dot3position = math.random(obsheight/2, display.contentWidth - obsheight/2)
		r7,g7,b7 = r5,g5,b5
		obs[7] = display.newRect(dot3position, -175, obsheight, obsheight)
		obs[7]:setFillColor(r7,g7,b7)

		-- Creates fourth obstacle, randomly positioned, but the same colour as the next bars	
		dot4position = math.random(obsheight/2, display.contentWidth - obsheight/2)
		r8,g8,b8 = r5,g5,b5
		obs[8] = display.newRect(dot4position, -270, obsheight, obsheight)
		obs[8]:setFillColor(r8,g8,b8)

		-- Applies physics to the obstacles
		for i=1,8 do
			physics.addBody(obs[i], "static")
		end

		-- Creates and displays score in top right corner
		score = 0
		myscore = display.newText(score, 300, 0, native.systemFont, 22, "right")
		myscore:setFillColor(0,0,0)	

		-- This function plays the game
		function PlayGame()

			-- This function creates and administers a play/pause button
			function PlayPause() 

				-- If the game hasn't finished yet
				if finished == false then

					-- Imports play and pause button images
					playpause = graphics.newImageSheet("Images/playpause.png", {width=52, height=52, numFrames=2})

					-- This function occurs if the play/pause button is clicked
					function PlayPauseClick(event)

						-- If the button is clicked and the game hasn't finished yet
					    if ("began" == event.phase and finished == false) then

					    	-- Plays sound effect
					    	if soundon == true then
								audio.play(click, {channel=2, duration = 100})
								audio.setVolume(0.2, {channel=2})
							end	

							-- If the game is playing
						    if playing == true then

						    	-- Records velocities of obstacles and stops obstacles
								for i=1,8 do
									velocity[1][i], velocity[2][i] = obs[i]:getLinearVelocity()
									obs[i]:setLinearVelocity(0,0)
								end	

								-- Records velocity of ball and stops ball
								velocity[1][9], velocity[2][9] = ball:getLinearVelocity()
								ball:setLinearVelocity(0,0)

								-- Records current gravity and stops gravity
								gx, gy = physics.getGravity()
								physics.setGravity(0,0)

								-- Removes left and right buttons
								leftbutton:removeSelf()
								rightbutton:removeSelf()

								-- Records that the game has paused
								playing = false

							else

								-- Resumes gravity
								physics.setGravity(gx, gy)

								-- Resumes movement of obstacles
								for i=1,8 do
									obs[i]:setLinearVelocity(velocity[1][i], velocity[2][i])
								end	

								-- Resumes movement of ball
								ball:setLinearVelocity(velocity[1][9], velocity[2][9])

								-- Creates left and right buttons
								LeftButton()
								RightButton()

								-- Records that the game is playing
								playing = true
							end
						end

					end -- end of PlayPauseClick

					-- Determines which image should be shown when the play/pause button is created
					if playing == true then
						playpause1 = 2
						playpause2 = 1
					else
						playpause1 = 1
						playpause2 = 2
					end		 

					-- Creates play/pause button
					playpausebutton = widget.newSwitch
					{
					    style = "checkbox",
			    		id = "Checkbox",
					    sheet = playpause,
					    frameOff = playpause1,
					    frameOn = playpause2,
					    onPress = PlayPauseClick
					}
					-- Positions play/pause button
					playpausebutton.x = 20
					playpausebutton.y = 0

				end -- end of if loop

			end	-- end of PlayPause

			-- This function creates and administers a button on the left side of the screen
			function LeftButton()

				-- This function occurs when the left button is clicked
				function LeftClick(event)

					-- If the left button is pressed
					if ("began" == event.phase) then

						-- If the game hasn't started yet
						if start == false then
							ball.bodyType = "dynamic" -- Makes ball dynamic (affected by gravity)
							instructions:removeSelf() -- Removes instructions
							start = true -- Records that the game has started
						end	

						-- If the game hasn't ended yet
					    if finished == false then

					    	-- If the ball is touching the left wall
					    	if ball.x > 15 then

					    		-- If gravity is not inverted
						        if (upsidedown == false) then

						        	-- Launches the ball up and to the left
						        	ball:setLinearVelocity(-90, -400) 

						        -- If gravity is inverted	
						        elseif (upsidedown == true) then

						        	-- Launches the obstacles down
						        	for i=1,8 do
										obs[i]:setLinearVelocity(0, 400)
									end

									-- Makes the ball move left
									ball:setLinearVelocity(-90, 0)
								end	

								-- Plays sound effect
								if soundon == true then
									audio.play(click, {channel=2, duration = 100})
									audio.setVolume(0.2, {channel=2})
								end	
							end

							-- If the game has started
							if start == true then

								-- Creates and administers play/pause button
								PlayPause()
							end
					    end
					end		    

				end -- end of LeftClick

				-- Creates left button
				leftbutton = widget.newButton
				{
				    width = display.contentWidth/2,
				    height = display.contentHeight,
				    defaultFile = "Images/white.png",
				    overFile = "Images/white.png",
				    onEvent = LeftClick
				}
				-- Positions and colours left button
				leftbutton.x = display.contentCenterX/2
				leftbutton.y = display.contentCenterY
				leftbutton:setFillColor(1,1,1)
				leftbutton.alpha = 0.01

			end -- end of LeftButton

			-- Creates and administers left button
			LeftButton()

			-- This function creates and administers a button on the right side of the screen
			function RightButton()

				-- This function occurs when the right button is clicked
				function RightClick(event)

					-- If the right button is pressed
					if ("began" == event.phase) then

						-- If the game hasn't started yet
						if start == false then
							ball.bodyType = "dynamic" -- Makes ball dynamic (affected by gravity)
							instructions:removeSelf() -- Removes instructions
							start = true -- Records that the game has started			
						end		

						-- If the game hasn't ended yet
					    if finished == false then

					    	-- If the ball is touching the right wall
					    	if ball.x < display.contentWidth-15 then

					    		-- If gravity is not inverted
						    	if (upsidedown == false ) then

						    		-- Launches the ball up and to the right
						        	ball:setLinearVelocity(90, -400)

						        -- If gravity is inverted	
						        elseif (upsidedown == true) then 

						        	-- Launches the obstacles down
						        	for i=1,8 do
										obs[i]:setLinearVelocity(0, 400)
									end

									-- Makes the ball move right
									ball:setLinearVelocity(90, 0)
								end	

								-- Plays sound effect
								if soundon == true then
									audio.play(click, {channel=2, duration = 100})
									audio.setVolume(0.2, {channel=2})
								end
							end

							-- If the game has started
							if start == true then

								-- Creates and administers play/pause button
								PlayPause()
							end
					    end
					end   

				end -- end of RightClick

				-- Creates right button
				rightbutton = widget.newButton
				{
				    width = display.contentWidth/2,
				    height = display.contentHeight,
				    defaultFile = "Images/white.png",
				    overFile = "Images/white.png",
				    onEvent = RightClick
				}
				-- Positions and colours right button
				rightbutton.x = display.contentCenterX*1.5
				rightbutton.y = display.contentCenterY
				rightbutton:setFillColor(1,1,1)
				rightbutton.alpha = 0.01	

			end -- end of RightButton

			-- Creates and administers right button
			RightButton()

			-- This function removes on-screen elements and goes to the game over menu
			function EndGame()

				-- Removes obstacles
				for i=1,8 do
					physics.removeBody(obs[i])
					obs[i]:removeSelf()
				end

				-- Removes ball
				physics.removeBody(ball)
				ball:removeSelf()

				-- Goes to the game over menu
				GOMenu()

			end	-- end of EndGame

			-- This function fades the on-screen elements of the game
			function FadeGame()

				-- Fades obstacles
				for i=1,8 do
					transition.to(obs[i], {time=100, alpha=0.0})
				end

				-- Fades ball
				transition.to(ball, {time=100, alpha=0.0, onComplete=EndGame})	

			end -- end of FadeGame

			-- This function occurs if the ball collides with an obstacle
			function ball:preCollision(event)

				-- Records that the game has finished
				finished = true

				-- Removes buttons
				leftbutton:removeSelf()
				rightbutton:removeSelf()
				playpausebutton:removeSelf()

				-- White background
				background = display.newRect(display.contentCenterX, 0, display.contentWidth, 50)
				background:setFillColor(1,1,1)		

				-- Sets gravity and gravity scale back to noraml
				physics.setGravity(0, 25)
				ball.gravityScale = 1

				-- For each obstacle
				for i=1,8 do	

					-- Determines position of obstacle and destroys it
					local x,y = obs[i].x, obs[i].y				
					physics.removeBody(obs[i])
					obs[i]:removeSelf()					

					-- Remakes and recolours obstacle, depending on which obstacle it is
					if i == 1 or i == 2 then							
						obs[i] = display.newRect(x,y, display.contentWidth, obsheight)
						obs[i]:setFillColor(r1,g1,b1)
					elseif i == 3 then
						obs[3] = display.newRect(x,y, obsheight, obsheight)			
						obs[3]:setFillColor(r3,g3,b3)
					elseif i == 4 then
						obs[4] = display.newRect(x,y, obsheight, obsheight)			
						obs[4]:setFillColor(r4,g4,b4)
					elseif i == 5 or i == 6 then							
						obs[i] = display.newRect(x,y, display.contentWidth, obsheight)
						obs[i]:setFillColor(r5,g5,b5)
					elseif i == 7 then
						obs[7] = display.newRect(x,y, obsheight, obsheight)			
						obs[7]:setFillColor(r7,g7,b7)	
					else
						obs[8] = display.newRect(x,y, obsheight, obsheight)			
						obs[8]:setFillColor(r8,g8,b8)
					end		

					-- Adds physics to the obstacle
					physics.addBody(obs[i], "static")

				end -- end of for loop
				
				-- Removes score
				myscore.isVisible = false

				-- Displays score
				myscore = display.newText(score, display.contentWidth-20, 0, native.systemFont, 22, "right")
				myscore:setFillColor(0,0,0)

				-- Plays sound effect
				if soundon == true then
					audio.play(crash, {channel=4})
					audio.setVolume(0.5, {channel=4})
				end	

				-- Waits 1 second, and then ends game
				timer.performWithDelay(1000, FadeGame)

			end -- end of ball:preCollision

			-- Event listener for if the ball collides with an obstacle
			ball:addEventListener("preCollision")

			-- This function determines if the ball is touching the edges, and if so, changes the ball's velocity or ends the game
			function Edges(event)

				-- If the game hasn't finished yet
				if finished == false then

					-- If the ball is touching the left wall
					if ball.x < 15 then

						-- Stops the ball from moving and moves the ball directly to the edge of the left wall
						ball:setLinearVelocity(0, 0)
						transition.moveTo(ball, {x=15, time=0})
						
					-- If the ball is touching the right wall					
					elseif ball.x > display.contentWidth-15 then

						-- Stops the ball from moving and moves the ball directly to the edge of the right wall						
						ball:setLinearVelocity(0, 0)
						transition.moveTo(ball, {x=display.contentWidth-15, time=0})
					end

					-- If the ball is touching the ground
					if ball.y > 540 then	

						-- Records that the game is finished
						finished = true

						-- Removes buttons
						leftbutton:removeSelf()
						rightbutton:removeSelf()
						playpausebutton:removeSelf()	

						-- White background
						background = display.newRect(display.contentCenterX, 0, display.contentWidth, 50)
						background:setFillColor(1,1,1)	
						
						-- Plays sound effect
						if soundon == true then
							audio.play(crash, {channel=4})
							audio.setVolume(0.5, {channel=4})
						end	

						-- Ends game
						FadeGame()
					end	
				end

			end -- end of Edges

			-- Event listener that occurs every frame, to check whether the ball is touching the ground or walls
			Runtime:addEventListener( "enterFrame", Edges )
		
			-- This function determines if the ball is too high, and if so, moves the obstacles downwards, instead
			function TooHigh(event)

				-- If the game hasn't finished yet
				if finished == false then

					-- If the ball is above a certain height and gravity isn't inverted
					if ball.y < 200 and upsidedown == false then

						-- Records that gravity is/will be inverted
						upsidedown = true
							
						-- Records the ball's velocity	
						local vx, vy = ball:getLinearVelocity()
				
						-- Inverts gravity
						physics.setGravity(0, -25)

						-- Changes the ball's velocity so that it only moves horizontally
						ball.gravityScale = 0
						ball:setLinearVelocity(vx, 0)

						-- Makes each obstacle dynamic and launches it downwards at the ball's velocity, but inverted
						for i=1,8 do
							obs[i].bodyType = "dynamic"
							obs[i]:setLinearVelocity(0, -vy)					
						end

						-- Moves the ball to the certain height (so that it isn't slightly over)
						transition.moveTo(ball, {y=200, time=0})	
						
					end -- end of if loop

					-- Determines random measurments for location of obstacles
					barwidth = math.random(0,display.contentWidth-gaplength)
					dotposition = math.random(obsheight/2, display.contentWidth - obsheight/2)

					-- For each obstacle
					for i=1,8 do

						-- If the obstacle is below the ground
						if (obs[i].y > display.contentHeight + 50) then

							-- Records the obstacle's velocity and removes obstacle
							local vx, vy = obs[i]:getLinearVelocity()
							physics.removeBody(obs[i])
							obs[i]:removeSelf()

							-- Recreates the obstacle at the top of the screen and recolours it, depending on which obstacle it is
							if i == 1 then							
								obs[1] = display.newRect(barwidth - display.contentWidth/2, -60, display.contentWidth, obsheight)
								r1,g1,b1 = math.random(10, 90)/100, math.random(10, 90)/100, math.random(10, 90)/100
								obs[1]:setFillColor(r1,g1,b1)
							elseif i == 2 then
								obs[2] = display.newRect(barwidth + display.contentWidth/2 + gaplength, -60, display.contentWidth, obsheight) 
								obs[2]:setFillColor(r1,g1,b1)
							elseif i == 3  then
								obs[i] = display.newRect(dotposition, -60, obsheight, obsheight)
								r3,g3,b3 = r1,g1,b1
								obs[i]:setFillColor(r3,g3,b3)
							elseif i == 4 then
								obs[i] = display.newRect(dotposition, -60, obsheight, obsheight)
								r4,g4,b4 = r1,g1,b1
								obs[i]:setFillColor(r4,g4,b4)
							elseif i == 5 then							
								obs[5] = display.newRect(barwidth - display.contentWidth/2, -60, display.contentWidth, obsheight)
								r5,g5,b5 = math.random(10, 90)/100, math.random(10, 90)/100, math.random(10, 90)/100
								obs[5]:setFillColor(r5,g5,b5)
							elseif i == 6 then
								obs[6] = display.newRect(barwidth + display.contentWidth/2 + gaplength, -60, display.contentWidth, obsheight)
								obs[6]:setFillColor(r5,g5,b5)
							elseif i == 7 then 
								obs[i] = display.newRect(dotposition, -60, obsheight, obsheight)
								r7,g7,b7 = r5,g5,b5
								obs[i]:setFillColor(r7,g7,b7)
							else
								obs[i] = display.newRect(dotposition, -60, obsheight, obsheight)
								r8,g8,b8 = r5,g5,b5
								obs[i]:setFillColor(r8,g8,b8)	
							end	

							-- Adds physics to the obstacle and sets its velocity
							physics.addBody(obs[i], "dynamic")	
							obs[i]:setLinearVelocity(vx, vy)

							-- Gives the obstacle back its point
							points[i] = false

							-- Creates and administers a play/pause button
							PlayPause()

							-- Removes score
							myscore.isVisible = false

							-- Displays score
							myscore = display.newText(score, 300, 0, native.systemFont, 22, "right")
							myscore:setFillColor(0,0,0)
						end

						-- If the obstacle is lower than the ball
						if (obs[i].y > 200) then

							-- If the obstacle hasn't given its point yet
							if points[i] == false then

								-- Obstacle count increases, and the obstacle loses its point
								obstaclecount = obstaclecount + 1
								points[i] = true							
							end	
						end		

						-- If the ball passes 4 obstacles
						if (obstaclecount == 4) then

							-- Score goes up by 1
							score = score + 1

							-- Plays sound effect if sound is on
							if soundon == true then
								audio.play(point, {channel=3, duration=700})
								audio.setVolume(0.3, {channel=3})
							end

							-- Updates score
							myscore.text = score

							-- Resets obstacle count
							obstaclecount = 0
						end	

					end -- end of for loop

					-- If the game hasn't ended yet
					if finished == false then

						-- Gets the velocity of one of the obstacles
						ovx, ovy = obs[4]:getLinearVelocity()
					end

					-- If the obstacle is moving "up" and gravity is inverted
					if ovy < 0 and upsidedown == true then
					
						-- Records velocity of ball
						vx, vy = ball:getLinearVelocity()

						-- Records that gravity is/will be set back to normal
						upsidedown = false

						-- Sets gravity back to normal
						physics.setGravity(0, 25)

						-- Makes it so that the ball moves in 2 dimensions again
						ball.gravityScale = 1
						ball:setLinearVelocity(vx, 0)

						-- For each obstacle
						for i=1,8 do

							-- Makes the obstacle static and sets its velocity to 0
							obs[i].bodyType = "static"
							obs[i]:setLinearVelocity(0, 0)
						end
					end

				end -- end of if loop

			end	 -- end of TooHigh

			-- Event listener that occurs every frame, to check whether the ball is too high or not
			Runtime:addEventListener("enterFrame", TooHigh)

		end -- end of PlayGame
		
		timer.performWithDelay(100, PlayGame)

	end -- end of Game

	-- This function removes the on-screen elements of the title menu and starst the game
	function RemoveTitleMenu()
		title:removeSelf()	
		playbutton:removeSelf()
		copyright:removeSelf()
		musicbutton:removeSelf()
		soundbutton:removeSelf()
		Game()
	end	-- end of RemoveTitleMenu

	function TitleMenu()

		-- Displays game title and copyright
		title = display.newImage( "Images/title.png", display.contentCenterX, 100 ) 
		copyright = display.newImage( "Images/copyright.png", display.contentCenterX, 450)

		-- This function occurs if the play button is clicked
		local function PlayClick(event)

			-- If the play button is pressed and sound is on
			if ("began" == event.phase and soundon == true) then

				-- Plays sound effect
				audio.play(click, {channel=2, duration = 100})
				audio.setVolume(0.2, {channel=2})
			end

			-- If the play button is released
		    if ("ended" == event.phase) then

		    	-- Fades the elements of the title menu
		    	transition.to(title, {time=100, alpha=0.0})
		    	transition.to(playbutton, {time=100, alpha=0.0})
		    	transition.to(copyright, {time=100, alpha=0.0})
		    	transition.to(musicbutton, {time=100, alpha=0.0})	
		    	transition.to(soundbutton, {time=100, alpha=0.0, onComplete = RemoveTitleMenu})   			
		    end

		end -- end of PlayClick

		-- Creates the play button
		playbutton = widget.newButton
		{
		    width = 240,
		    height = 70,
		    defaultFile = "Images/play.png",
		    overFile = "Images/play-over.png",
		    onEvent = PlayClick
		}
		-- Positions the play button
		playbutton.x = display.contentCenterX
		playbutton.y = 265

		-- Imports music button images
		musics = graphics.newImageSheet("Images/musics.png", {width=52, height=52, numFrames=2})

		-- This function occurs if the music button is clicked
		local function MusicClick( event )

			-- If the music button is pressed
		    if ("began" == event.phase) then

		    	-- If sound is on
		    	if soundon == true then

		    		-- Plays sound effect
					audio.play(click, {channel=2, duration = 100})
					audio.setVolume(0.2, {channel=2})
				end	

				-- If music is not on
			    if musicon == false then

			    	-- Turns music on
				    audio.play(music, {channel=1, loops = -1 } )
				    audio.setVolume(0.2, {channel=1})

				    -- Records that music has been turned on
				    musicon = true

    			-- If music is on
				else

					-- Turns music off
					audio.stop({channel=1})

					-- Records that music has been turned off
					musicon = false
				end
			end

		end -- end of MusicClick

		-- Determines which image should be shown when the music button is created
		if musicon == true then
			music1 = 1
			music2 = 2
		else
			music1 = 2
			music2 = 1
		end		 

		-- Creates music button
		musicbutton = widget.newSwitch
		{
		    style = "checkbox",
    		id = "Checkbox",
		    sheet = musics,
		    frameOff = music1,
		    frameOn = music2,
		    onPress = MusicClick
		}
		-- Positions music button
		musicbutton.x = display.contentCenterX - 40
		musicbutton.y = 370

		-- Imports sound button images
		sounds = graphics.newImageSheet("Images/sounds.png", {width=52, height=52, numFrames=2})

		-- If the sound button is clicked
		local function SoundClick(event)

			-- If the sound button is pressed
		    if ("began" == event.phase) then

		    	-- If sound is off
			    if soundon == false then

			    	-- Turns sound on
				    soundon = true

				-- If sound is on    
				else

					-- Plays sound effect
					audio.play(click, {channel=2, duration = 100})
					audio.setVolume(0.2, {channel=2})

					-- Turns sound off
					soundon = false
				end
			end

		end -- end of SoundClick

		-- Determines which image should be shown when the sound button is created
		if soundon == true then
			sound1 = 1
			sound2 = 2
		else
			sound1 = 2
			sound2 = 1
		end		 

		-- Creates sound button
		soundbutton = widget.newSwitch
		{
		    style = "checkbox",
    		id = "Checkbox",
		    sheet = sounds,
		    frameOff = sound1,
		    frameOn = sound2,
		    onPress = SoundClick
		}
		-- Positions sound button
		soundbutton.x = display.contentCenterX + 40
		soundbutton.y = 370

	end -- end of TitleMenu

	-- Displays title menu
	TitleMenu()

end -- end of Program

-- Begins the program
Program()
