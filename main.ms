import "importUtil"
ensureImport "mathUtil"
ensureImport "gameInput"
ensureImport "displays"
ensureImport "minimap"
ensureImport "pickups"
ensureImport "buildings"
ensureImport "playerMgr"

displays.setup
minimap.setup

CHEATS_ENABLED = true

// load background
import "buildingRef"
bg = display(6)
import "buildings"
buildings.setup
playerMgr.setup

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

attachable = function(x,y)
	sf = buildingRef.scaleFactor
	return bg.pixel(x/sf, y/sf) != "#00000000"
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
	sx = camera.x - 480
	sy = camera.y - 320
	displays.sprite.scrollX = sx
	displays.sprite.scrollY = sy
	displays.building.scrollX = sx
	displays.building.scrollY = sy
	bg.scrollX = sx
	bg.scrollY = sy
end function

// HACK for testing: double-size city?
//bg.scale *= 2
//buildingRef.scaleFactor = bg.scale

wasDown = mouse.button
while not key.pressed("escape")
	eraseWeb
	playerMgr.updatePlayer
	playerMgr.handleInput	
	updateCamera	
	drawWeb
	minimap.update pickups.Powerup.all
	pickups.updateAll
	yield
end while
key.clear
