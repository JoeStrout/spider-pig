import "importUtil"
ensureImport "mathUtil"
ensureImport "gameInput"
ensureImport "displays"
ensureImport "minimap"
ensureImport "pickups"
ensureImport "buildings"
ensureImport "playerMgr"
ensureImport "newspaper"

displays.setup
minimap.setup

CHEATS_ENABLED = true

// load background
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
	// Otherwise, look for groundable tiles.  That's any
	// nonempty tile with an empty tile above it
	// (ToDo: plus some other special "ledge" tiles.)
	// We have two support points, one under the front
	// feet and one under the back feet.
	if gameInput.vertical < 0 then return null
	signX = player.scale[0]
	bldg = displays.building
	sf = bldg.cellSize
	x0 = (player.x + 10 * signX) / sf
	x1 = (player.x - 20 * signX) / sf
	y = (player.y - 32) / sf
	d = 0
	while d < distance
		if (bldg.cell(x0, y) == null and bldg.cell(x0, y-1) != null) or
		   (bldg.cell(x1, y) == null and bldg.cell(x1, y-1) != null) then
			return floor(y) * sf
		end if
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
	// Otherwise, look for non-clear tiles next to clear ones.
	bldg = displays.building
	sf = bldg.cellSize
	y0 = round((player.y + 10) / sf)
	y1 = round((player.y - 60) / sf)
	signX = sign(distX)
	x = floor((player.x) / sf)
	d = abs(distX)
	while d > 0
		if DEBUG then
			print "dist:" + distX + "; x:" + x + "; y0:" + y0 + " -> " + bldg.cell(x,y0) + ", " + bldg.cell(x+signX,y0)
		end if
		if (bldg.cell(x,y0) == null and bldg.cell(x+signX,y0) != null) or
		   (bldg.cell(x,y1) == null and bldg.cell(x+signX,y1) != null) then
			return floor(x + (signX > 0)) * sf
		end if
		x += signX
		d -= sf
	end while
	return null
end function

attachable = function(x,y)
	bldg = displays.building
	col = x / bldg.cellSize
	row = y / bldg.cellSize
	return 0 < bldg.cell(col, row)
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
	displays.decoration.scrollX = sx
	displays.decoration.scrollY = sy
	//bg.scrollX = sx
//	bg.scrollY = sy
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
	newspaper.update
	yield
end while
key.clear
