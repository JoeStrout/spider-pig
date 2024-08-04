import "mathUtil"
import "gameInput"

clear

// load background
import "buildingRef"
bg = buildingRef.refg

// prepare player sprite
spriteDisp = display(4)
spriteDisp.clear
player = new Sprite
player.image = file.loadImage("pics/SpiderPig.png")
spriteDisp.sprites.push player

// for now, let's start hanging from a web
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

gfx.clear color.clear
gfx.line web.x, web.y, player.x, player.y

dot = function(ax,ay, bx,by)
	return ax*bx +  ay*by
end function

eraseWeb = function
	if not web.attached then return
	gfx.clear color.clear
end function

drawWeb = function
	if not web.attached then return
	dx = -bg.scrollX
	dy = -bg.scrollY
	gfx.line web.x + dx, web.y + dy, player.x + dx, player.y + dy,
	   "#FFFFFFAA", 2
end function

// checkGround: check whether there is walkable ground
// under the player, within `distance` pixels.  If so,
// return the ground (Y) level.  If not, return null.
checkGround = function(distance=3)
	// Absolute ground plane at Y = -32
	if player.y - 48 - distance < -32 then return -32
	// Up off the absolute ground, if user is not grounded
	// and not pressing up, then ignore everything else.
	if not player.grounded and gameInput.vertical <= 0 then
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

shootWeb = function
	web.x = mouse.x + bg.scrollX
	web.y = mouse.y + bg.scrollY
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
	spriteDisp.scrollX = camera.x - 480
	spriteDisp.scrollY = camera.y - 320
	bg.scrollX = spriteDisp.scrollX
	bg.scrollY = spriteDisp.scrollY
end function

// HACK for testing:
bg.scale *= 2
buildingRef.scaleFactor = bg.scale

wasDown = mouse.button
while not key.pressed("escape")
	eraseWeb
	updatePlayer
	handleInput	
	updateCamera	
	drawWeb
	yield
end while
key.clear
