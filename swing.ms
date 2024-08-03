import "mathUtil"
clear

// load background
gfx.line 0,0, 64,0
gfx.line 0,0, 0,64
gfx.fillRect 64,0,64,64, color.gray
display(7).mode = displayMode.tile
bg = display(7)
bg.tileSet = gfx.getImage(0, 0, 128, 64)
bg.cellSize = 64
bg.tileSetTileSize = 64
bg.extent = [100,50]
for y in range(0, bg.extent[1]-1)
	for x in range(0, bg.extent[0]-1)
		bg.setCell x, y, rnd > 0.5
	end for
end for
bg.scrollX = 0
bg.scrollY = 0

// prepare player sprite
spriteDisp = display(4)
spriteDisp.clear
gfx.fillRect 0,0,80,50, color.yellow
player = new Sprite
player.image = gfx.getImage(0,0, 80,50)
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

handleInput = function
	isDown = mouse.button
	if isDown and not wasDown and not web.attached then
		web.x = mouse.x +  bg.scrollX
		web.y = mouse.y +  bg.scrollY
		web.len = mathUtil.distance(player, web)
		web.attached = true
		web.startTime = time
	else if wasDown and not isDown then
		web.attached = false
		age = time - web.startTime
		boost = 1 +  mathUtil.clamp((age - 0.1) * 4, -0.2, 0.2)
		player.vx *= boost
		player.vy *= boost
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
