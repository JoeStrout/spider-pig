import "mathUtil"
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
player.x = 50
player.y = 400
player.vx = 0
player.vy = 0
web = {}
web.x = 300
web.y = 400
web.len = mathUtil.distance(player, web)
web.attached = true
web.startTime = time

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
	gfx.line web.x + dx, web.y + dy, player.x + dx, player.y + dy
end function

updatePlayer = function(dt=0.016)
	// gravity
	player.vy -= gravity * dt
	
	// active boost while swinging
	if web.attached then player.vx *= 1.04
	
	// apply velocity
	player.x += player.vx * dt
	player.y += player.vy * dt
	
	// hit the ground
	if player.y < 0 then
		player.y = 0
		player.vy = 0
		player.vx /= 2
		if abs(player.vx) < 0.1 then player.vx = 0
		player.grounded = true
	else
		player.grounded = false
	end if
	
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
	if key.pressed("space") and player.grounded then
		player.vy += 3000
		player.y += 4
	end if
	globals.wasDown = isDown
end function

updateCamera = function
	camera.x = player.x
	camera.y = player.y
	spriteDisp.scrollX = camera.x - 480
	spriteDisp.scrollY = camera.y - 320
	bg.scrollX = spriteDisp.scrollX
	bg.scrollY = spriteDisp.scrollY
end function

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
