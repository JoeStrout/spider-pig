// This module manages items that can be picked up by the player:
// includes both powerups (which affect game mechanics) and
// collectibles (which are just for fun).

import "importUtil"
ensureImport "displays"
ensureImport "listUtil"

BOUNCE = 12		// amplitude (half-height) of bounce, in pixels
SPEED = 5		// bounce speed factor

tmjFileName = "City.tmj"

Pickup = new Sprite
Pickup.all = []
Pickup.place = function(tileCol, tileRow)
	self.x = (tileCol + 0.5) * 64
	self.baseY = (200 - tileRow - 0.5) * 64
	self.y = self.baseY
	displays.sprite.sprites.push self
	Pickup.all.push self
end function

Pickup.pickUp = function
	print "Got: " + self.name
	self.all.removeVal self
	Pickup.all.removeVal self
	displays.sprite.sprites.removeVal self
end function

nextCheckIdx = 0
updateAll = function
	// update all animations
	for p in Pickup.all
		p.y = p.baseY + BOUNCE * sin(time * SPEED)
	end for

	// check for collision with just one
	if not Pickup.all then return
	if nextCheckIdx >= Pickup.all.len then outer.nextCheckIdx = 0
	p = Pickup.all[nextCheckIdx]
	if abs(p.y - player.y) < 20 and abs(p.x - (player.x + 30 * player.scale[0])) < 40 then
		p.pickUp
	end if
	outer.nextCheckIdx += 1
end function

Powerup = new Pickup
Powerup.all = []
Powerup.place = function(tileCol, tileRow)
	super.place tileCol, tileRow
	Powerup.all.push self
end function

Collectible = new Pickup
Collectible.name = "Collectible"
Collectible.all = []
Collectible.place = function(tileCol, tileRow)
	super.place tileCol, tileRow
	Collectible.all.push self
end function


tileIndexPicMap = {}

addFromTileIndex = function(overlayTileIndex, col, row)
	if 112 <= overlayTileIndex <= 117 then
		// powerups!
		names = ["web", "webBoost", "glide", "wallCling", "speedBoost", "jumpBoost"]
		p = new Powerup
		p.name = names[overlayTileIndex - 112]
		p.image = tileIndexPicMap.get(overlayTileIndex)
		if p.image == null then
			p.image = file.loadImage("pics/powerups/" + p.name + ".png")
			tileIndexPicMap[overlayTileIndex] = p.image
		end if
		p.place col, row
	end if
end function

setup = function

	f = file.open(tmjFileName, "r")
	tmjData = f.read
	f.close

	firstgid = 129   // OFI: get this from the JSON, "firstgid" of the overlay layer
	
	p1 = -1
	p0 = tmjData.indexOf("""data"":[", p1)
	p1 = tmjData.indexOf("]", p0)
	data = tmjData[p0 + 8: p1]
	globals.lines = data.split(char(10))
	for y in lines.indexes
		elements = lines[y].split(",")
		for x in elements.indexes
			e = elements[x].replace(" ", "")
			if e != "0" and e != "" then addFromTileIndex val(e) - firstgid, x, y
		end for
	end for
end function

if locals == globals then
	setup
end if
