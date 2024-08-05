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
	self.all.removeVal self
	Pickup.all.removeVal self
	displays.sprite.sprites.removeVal self
	player.power[self.name] += 1
	drawSlots
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

drawSlots = function
	left = 4
	bottom = 4
	g = displays.ui
	g.drawImage slotPic, left, bottom
	pp = player.power
	x = left + 4
	y = bottom + 14
	dx = 40
	if pp.web then g.drawImage tileIndexPicMap[112], x, y
	if pp.webBoost then g.drawImage tileIndexPicMap[113], x+dx, y
	if pp.wallCling then g.drawImage tileIndexPicMap[115], x+dx*2, y
	if pp.speedBoost then g.drawImage tileIndexPicMap[116], x+dx*3, y
	if pp.speedBoost>1 then g.drawImage tileIndexPicMap[116], x+dx*4, y
	if pp.jumpBoost then g.drawImage tileIndexPicMap[117], x+dx*5, y
	if pp.jumpBoost>1 then g.drawImage tileIndexPicMap[117], x+dx*6, y
	if pp.glide then g.drawImage tileIndexPicMap[114], x+dx*7, y
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
	// CityOverlay is now the *second* layer, so:
	p0 = tmjData.indexOf("""data"":[", p0+5)
	
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
	
	outer.slotPic = file.loadImage("pics/powerup-slots.png")
	player.ability = {}
	for power in ["web", "webBoost", "glide", "wallCling", "speedBoost", "jumpBoost"]
		player.power[power] = 0
	end for
	drawSlots
end function

if locals == globals then
	setup
end if
