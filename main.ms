import "importUtil"
ensureImport "mathUtil"
ensureImport "gameInput"
ensureImport "displays"
ensureImport "minimap"

displays.setup
minimap.setup

// load background
import "buildingRef"
bg = displays.building

// load pickups
import "pickups"
pickups.setup

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
web = {}
web.x = null; web.y = null
web.len = mathUtil.distance(player, web)
web.attached = false
web.startTime = 0

gravity = 10000  // pixels/sec^2
camera = {"x": 480, "y": 320}

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

updatePlayer = function(dt=0.016)
	// gravity
	player.vy -= gravity * dt
	
//	// active boost while swinging
//	if web.attached then player.vx *= 1.04

	// check for hitting the ground
	if player.vy < 0 then
		groundY = checkGround(ceil(-player.vy * dt))
		if groundY == null then
			player.grounded = false
		else
			player.y = groundY + 48
			player.vy = 0
			player.grounded = true
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
	stepx = 16 * ((targetX - player.x) / dist)
	stepy = 16 * ((targetY - player.y) / dist)
	steps = 0
	while true
		x = targetX + stepx * steps * 2
		y = targetY + stepy * steps * 2
		if attachable(x, y) then break
		x = targetX - stepx * steps
		y = targetY - stepy * steps
		if attachable(x, y) then break
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
		shootWeb
	else if wasDown and not isDown then
		releaseWeb
	end if
	if player.grounded then
		// While grounded: run and jump
		if key.pressed("space") then
			player.vy += 3000
			player.y += 4
			player.grounded = false
		else
			horz = gameInput.horizontal
			player.vx = mathUtil.moveTowards(
			  player.vx, 1000 * horz, 300)
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
	globals.wasDown = isDown
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
