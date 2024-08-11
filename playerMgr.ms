// This file manages the actual player sprite, including 
// animations, rotation/flip, and sound effects.  It also
// deals with player input and physics.


setup = function
	// load all images
	outer.images = {}
	images.idle = [
		file.loadImage("pics/SpiderPig-0.png"),
		file.loadImage("pics/SpiderPig-1.png")]		
	images.run = []
	for i in range(0,3)
		images.run.push file.loadImage("pics/SpiderPig-Run" + i + ".png")
	end for
	images.inAir = images.run[2]

	// prepare player sprite
	globals.player = new Sprite
	player.image = images.idle
	sprites = displays.sprite.sprites
	sprites.push player
	
	// and web sprite
	globals.webSprite = new Sprite
	webSprite.image = Image.create(10, 2, "#FFFFFFAA")
	sprites.insert 0, webSprite
	
	// initialize player
	player.x = 1150
	player.y = 0
	player.vx = 0
	player.vy = 0
	player.grounded = true
	player.onWall = false
	player.ability = {}
	player.frameNum = 0
	player.heartRate = 50		// varies between 50 and 200 based on activity
	player.tillNextFrame = 0
	
	globals.web = {}
	web.x = null; web.y = null
	web.len = mathUtil.distance(player, web)
	web.attached = false
	web.startTime = 0
end function
	
updatePlayer = function(dt=0.016)
	// gravity
	if not player.onWall then player.vy -= gravity * dt
	terminalV = -5000
	if player.ability.glide and gameInput.jump then terminalV = -250
	if player.vy < terminalV then player.vy = terminalV
	
//	// active boost while swinging
//	if web.attached then player.vx *= 1.04

	// check for hitting the ground
	if player.vy < 0 then
		groundY = checkGround(ceil(-player.vy * dt))
		if groundY == null then
			player.grounded = false
		else
			if not player.grounded then
				// land on ground!
				player.vx /= 2
			end if
			player.y = groundY + 48
			player.vy = 0
			player.grounded = true
			player.rotation = 0
		end if
	end if
	
	// check for hitting a wall
	if player.vx or player.onWall then
		signX = sign(player.vx)
		if signX == 0 then signX = sign(player.rotation)
		if signX == 0 then signX = player.scale[0]
		wallX = checkWall(player.vx * dt + 40 * signX)
		if wallX == null then
			player.onWall = false
			player.rotation = mathUtil.moveTowards(player.rotation, 0, 500*dt)
		else
			canCling = player.ability.wallCling and
			  (gameInput.grabWall or player.onWall)
			if not canCling then
				// No cling ability; just stop when we hit a wall,
				// IF we are grounded on a roof or ledge
				if player.grounded and player.y > 20 then player.vx = 0
			else
				// Otherwise, cling to the wall and start climbing
				if not player.onWall then
					// land on wall!
					player.vy = 0
				end if
				player.onWall = true
				if wallX > player.x then
					player.x = wallX - 40
					player.rotation = 90
				else
					player.x = wallX + 40
					player.rotation = -90
				end if
				player.vx = 0
			end if
		end if
	end if
	
	// apply velocity
	player.x += player.vx * dt
	player.y += player.vy * dt
	
	if web.attached then
		// web: apply a velocity adjustment so as to bring
		// the player back to the proper distance
		dist = mathUtil.distance(player, web)
		if dist > web.len then
			ddist = dist - web.len
			dx = ddist * (web.x - player.x) / web.len
			dy = ddist * (web.y - player.y) / web.len
			player.vx += dx / dt
			player.vy += dy / dt
			player.x += dx
			player.y += dy
		end if		
	end if
	
	player.heartRate = mathUtil.moveTowards(player.heartRate, 50, 0.2)
	player.tillNextFrame -= dt
	if player.grounded or player.onWall then
		speed = abs(player.vx) * player.grounded + abs(player.vy) * player.onWall
		if speed > 1 and images.idle.contains(player.image) then
			player.tillNextFrame = -1
			player.frameNum = -1
		end if
		if player.tillNextFrame < 0 then
			if speed > 1 then
				if player.onWall and player.vy < 0 then
					player.frameNum = (player.frameNum + images.run.len - 1) % images.run.len
				else
					player.frameNum = (player.frameNum + 1) % images.run.len
				end if
				player.image = images.run[player.frameNum]
				player.tillNextFrame = (1500 - speed) / 8000
			else
				player.frameNum = not player.frameNum
				player.image = images.idle[player.frameNum]
				player.tillNextFrame = (250 - player.heartRate) / 200
			end if
		end if
	else
		player.image = images.inAir
	end if
end function

shootWeb = function
	// find a valid attachment point
	targetX = mouse.x + displays.building.scrollX
	targetY = mouse.y + displays.building.scrollY
	dist = mathUtil.distance([targetX, targetY], player)
	if not player.ability.webBoost and dist > 300 then
		factor = 300 / dist
		dist = 300
		targetX = player.x + (targetX - player.x) * factor
		targetY = player.y + (targetY - player.y) * factor
	end if
	stepx = 16 * ((targetX - player.x) / dist)
	stepy = 16 * ((targetY - player.y) / dist)
	steps = 0
	while true
		if player.ability.webBoost then
			x = targetX + stepx * steps * 2
			y = targetY + stepy * steps * 2
			if attachable(x, y) then break
		end if
//		if player.ability.webBoost then
			x = targetX - stepx * steps
			y = targetY - stepy * steps
			if attachable(x, y) then break
//		end if
		steps += 1
		if steps > 8 then // no attachment point found
			return
		end if
	end while
	
	web.x = x
	web.y = y
	web.len = mathUtil.distance(player, web)
	web.attached = true
	web.startTime = time
	if web.y > player.y then player.y += 4
	if web.x > player.x then
		player.scale = [1,1]
	else
		player.scale = [-1,1]	
	end if
	
	player.heartRate = mathUtil.moveTowards(player.heartRate, 200, 10)
end function

releaseWeb = function
	web.attached = false
	age = time - web.startTime
	boost = 1 +  mathUtil.clamp((age - 0.1) * 4, -0.2, 0.2)
	player.vx *= boost
	player.vy *= boost
end function

jump = function
	player.vy += 2000 + 500 * player.ability.jumpBoost
	player.y += 4
	player.grounded = false
	player.onWall = false
	player.heartRate = mathUtil.moveTowards(player.heartRate, 200, 30)
end function

handleInput = function
	isDown = mouse.button
	if isDown and not wasDown and not web.attached then
		if player.ability.web then shootWeb
	else if wasDown and not isDown then
		releaseWeb
	end if
	if player.grounded or player.onWall then
		// While grounded: run and jump
		if gameInput.jump then
			jump
		else if player.onWall then
			vert = gameInput.vertical
			maxSpeed = 300 + 150 * player.ability.speedBoost
			player.vy = mathUtil.moveTowards(
			  player.vy, maxSpeed * vert, 300)
			if vert then
				player.heartRate = mathUtil.moveTowards(player.heartRate, 200, 2)
			end if
		else
			horz = gameInput.horizontal
			maxSpeed = 500 + 250 * player.ability.speedBoost
			player.vx = mathUtil.moveTowards(
			  player.vx, maxSpeed * horz, 300)
			if horz > 0 then player.scale = [1,1]
			if horz < 0 then player.scale = [-1,1]
			if horz then
				player.heartRate = mathUtil.moveTowards(player.heartRate, 200, 1)
			end if
		end if
	else if web.attached then
		// While swinging: get a slight directional force
		f = 50
		player.vx += f * gameInput.horizontal
		player.vy += f * gameInput.vertical
	else
		// While in freefall: have some horizontal control authority.
		// But importantly, don't let this slow us down if already
		// moving in the right direction!
		maxSpeed = 300 + 150 * player.ability.speedBoost
		horz = gameInput.horizontal
		if (horz > 0 and player.vx > maxSpeed) or 
		   (horz < 0 and player.vx < -maxSpeed) then
			// already flying fast in the indicated direction!
		else
			player.vx = mathUtil.moveTowards(player.vx, maxSpeed * horz, 300)
		end if
		if player.vx > 0.1 then player.scale = [1,1]
		if player.vx < -0.1 then player.scale = [-1,1]
	end if
	if key.available then
		k = key.get
		handleKey k
	end if
	globals.wasDown = isDown
end function