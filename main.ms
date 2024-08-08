import "importUtil"
ensureImport "mathUtil"
ensureImport "gameInput"
ensureImport "displays"
ensureImport "minimap"
ensureImport "pickups"

displays.setup
minimap.setup

CHEATS_ENABLED = true

// load background
import "buildingRef"
bg = displays.building

// prepare player sprite
player = new Sprite
player.image = file.loadImage("pics/SpiderPig.png")
sprites = displays.sprite.sprites
sprites.push player

// and web sprite
webSprite = new Sprite
webSprite.image = Image.create(10, 2, "#FFFFFFAA")
sprites.insert 0, webSprite

// initialize player
player.x = 1150
player.y = 0
player.vx = 0
player.vy = 0
player.grounded = true
player.onWall = false
player.power = {}

web = {}
web.x = null; web.y = null
web.len = mathUtil.distance(player, web)
web.attached = false
web.startTime = 0

gravity = 10000  // pixels/sec^2
camera = {"x": 480, "y": 320}

pickups.setup

dot = function(ax,ay, bx,by)
	return ax*bx +  ay*by
end function

eraseWeb = function
	if not web.attached then return
	webSprite.scale = 0
end function

drawWeb = function
	if not web.attached then return
	dx = web.x - player.x
	dy = web.y - player.y
	webSprite.scale = [sqrt(dx^2 + dy^2)*0.1, 1]
	webSprite.x = player.x + dx/2
	webSprite.y = player.y + dy/2
	webSprite.rotation = atan(dy, dx) * 180/pi
end function

// checkGround: check whether there is walkable ground
// under the player, within `distance` pixels.  If so,
// return the ground (Y) level.  If not, return null.
checkGround = function(distance=3)
	// Absolute ground plane at Y = -32
	if player.y - 48 - distance < -32 then return -32
	// Up off the absolute ground, if user is not grounded
	// and grabbing floor, then ignore everything else.
	if not player.grounded and not gameInput.grabFloor then
		return null
	end if
	// Otherwise, look for (for now) ground-color pixels.
	// We have two support points, one under the front
	// feet and one under the back feet.
	if gameInput.vertical < 0 then return null
	signX = player.scale[0]
	sf = buildingRef.scaleFactor
	x0 = (player.x + 10 * signX) / sf
	x1 = (player.x - 20 * signX) / sf
	y = (player.y - 48) / sf
	d = 0
	ground = buildingRef.groundColor
	while d < distance
		if bg.pixel(x0, y) == ground or
		   bg.pixel(x1, y) == ground then return y * sf
		y -= 1
		d += sf
	end while
	return null
end function

DEBUG = false
checkWall = function(distX=10)
	// If player doesn't have wall cling ability or is not using it,
	// then ignore all walls!
	if not player.ability.wallCling then return null
	if not gameInput.grabWall and not player.onWall then return null
	// Otherwise, look for (for now) non-clear pixels next to clear ones.
	sf = buildingRef.scaleFactor
	y0 = round((player.y + 10) / sf)
	y1 = round((player.y - 20) / sf)
	signX = sign(distX)
	x = round((player.x + 10 * signX) / sf)
	d = abs(distX)
	clearColor = "#00000000"
	while d > 0
		if DEBUG then
			print "x:" + x + "; y0:" + y0 + " -> " + bg.pixel(x,y0) + ", " + bg.pixel(x+signX,y0)
		end if
		if (bg.pixel(x,y0) == clearColor and bg.pixel(x+signX,y0) != clearColor) then// or
//		   (bg.pixel(x,y1) == clearColor and bg.pixel(x+signX,y1) != clearColor) then
			return x * sf + sf/2 * signX
		end if
		x += signX
		d -= sf
	end while
	return null
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
	
	// check for hitting a wall, if attempting to wall cling
	if player.vx or player.onWall then
		signX = sign(player.vx)
		if signX == 0 then signX = sign(player.rotation)
		if signX == 0 then signX = player.scale[0]
		wallX = checkWall(player.vx * dt + 40 * signX)
		if wallX == null then
			player.onWall = false
			player.rotation = mathUtil.moveTowards(player.rotation, 0, 500*dt)
		else
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
end function

attachable = function(x,y)
	sf = buildingRef.scaleFactor
	return bg.pixel(x/sf, y/sf) != "#00000000"
end function

shootWeb = function
	// find a valid attachment point
	targetX = mouse.x + bg.scrollX
	targetY = mouse.y + bg.scrollY
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
		x = targetX + stepx * steps * 2
		y = targetY + stepy * steps * 2
		if attachable(x, y) then break
		if player.ability.webBoost then
			x = targetX - stepx * steps
			y = targetY - stepy * steps
			if attachable(x, y) then break
		end if
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
end function

releaseWeb = function
	web.attached = false
	age = time - web.startTime
	boost = 1 +  mathUtil.clamp((age - 0.1) * 4, -0.2, 0.2)
	player.vx *= boost
	player.vy *= boost
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
			// jump!
			player.vy += 2000 + 500 * player.ability.jumpBoost
			player.y += 4
			player.grounded = false
			player.onWall = false
		else if player.onWall then
			vert = gameInput.vertical
			maxSpeed = 300 + 150 * player.ability.speedBoost
			player.vy = mathUtil.moveTowards(
			  player.vy, maxSpeed * vert, 300)			
		else
			horz = gameInput.horizontal
			maxSpeed = 500 + 250 * player.ability.speedBoost
			player.vx = mathUtil.moveTowards(
			  player.vx, maxSpeed * horz, 300)
			if horz > 0 then player.scale = [1,1]
			if horz < 0 then player.scale = [-1,1]
		end if
	else
		// While in the air: get a slight directional force
		// (more if web is attached)
		f = 10 + 40 * web.attached
		player.vx += f * gameInput.horizontal
		player.vy += f * gameInput.vertical
	end if
	if key.available then
		k = key.get
		handleKey k
	end if
	globals.wasDown = isDown
end function

handleKey = function(k)
	if CHEATS_ENABLED then
		if pickups.handleCheatKey(k) then return
	end if		
end function

updateCamera = function
	camera.x = player.x
	camera.y = player.y
	if camera.y < 240 then camera.y = 240
	displays.sprite.scrollX = camera.x - 480
	displays.sprite.scrollY = camera.y - 320
	bg.scrollX = displays.sprite.scrollX
	bg.scrollY = displays.sprite.scrollY
end function

// HACK for testing: double-size city?
//bg.scale *= 2
//buildingRef.scaleFactor = bg.scale

wasDown = mouse.button
while not key.pressed("escape")
	eraseWeb
	updatePlayer
	handleInput	
	updateCamera	
	drawWeb
	minimap.update pickups.Powerup.all
	pickups.updateAll
	yield
end while
key.clear
