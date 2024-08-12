// This module manages items that can be picked up by the player:
// includes both powerups (which affect game mechanics) and
// collectibles (which are just for fun).

// Its setup routine also loads the city overlay layer, and prepares
// things like the newspaper dispenser, all based on the city overlay
// Tiled layer.

import "importUtil"
ensureImport "displays"
ensureImport "listUtil"
ensureImport "mapUtil"
ensureImport "newspaper"

BOUNCE = 12		// amplitude (half-height) of bounce, in pixels
SPEED = 5		// bounce speed factor

tmjFileName = "City.tmj"
firstgid = 1   // OFI: get this from the JSON, "firstgid" of the overlay layer
	

Pickup = new Sprite
Pickup.all = []
Pickup.place = function(tileCol, tileRow)
	self.x = (tileCol + 0.5) * 64
	self.baseY = (200 - tileRow - 0.5) * 64
	if tileRow == 199 then self.baseY -= 32
	self.y = self.baseY
	displays.sprite.sprites.push self
	Pickup.all.push self
end function

Pickup.pickUp = function
	self.all.removeVal self
	Pickup.all.removeVal self
	displays.sprite.sprites.removeVal self
	if player.ability.hasIndex(self.name) then player.ability[self.name] += 1
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

Powerup.pickUp = function
	sounds.pig.squeal.play 1, 0, mathUtil.randRange(0.9, 1.1)
	super.pickUp
	infoPic = file.loadImage("pics/powerup-info/" + self.name + "-info.png")
	if infoPic == null then return
	displays.ui.drawImage infoPic, 480-infoPic.width/2, 320-infoPic.height/2
	displays.ui.drawImage self.image, 480+190, 320+100, 64, 64
	wait 0.2
	while gameInput.anyKey; yield; end while
	while not gameInput.anyKey; yield; end while
	displays.ui.fillRect 480-infoPic.width/2, 320-infoPic.height/2,
	  infoPic.width, infoPic.height, color.clear
end function

Collectible = new Pickup
Collectible.name = "Collectible"
Collectible.all = []
Collectible.origCount = 0
Collectible.place = function(tileCol, tileRow)
	super.place tileCol, tileRow
	Collectible.all.push self
	Collectible.origCount = len(Collectible.all)
end function
Collectible.pickUp = function
	super.pickUp
	sounds.pig.munch.play 1, 0, mathUtil.randRange(0.9, 1.1)
end function

formatFound = function
	foodGot = Collectible.origCount - len(Collectible.all)
	return foodGot + "/" + Collectible.origCount
end function

drawSlots = function
	left = 4
	bottom = 4
	g = displays.ui
	g.fillRect left, bottom, slotPic.width, slotPic.height, color.clear
	g.drawImage slotPic, left, bottom
	pp = player.ability
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
	
	text.row = 0; text.column = 25
	text.color = "#FFFF0044"
	print "Food: " + formatFound, "    "
end function


tileIndexPicMap = {}

addFromTileIndex = function(overlayTileIndex, col, row)
//	print "Adding " + overlayTileIndex + " at " + col + "," + row
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
	else if 96 <= overlayTileIndex <= 111 then
		// food collectibles
		c = new Collectible
		idx = overlayTileIndex - 96
		c.name = "Food_" + idx
		c.image = file.loadImage("pics/food/" + c.name + ".png")
		c.place col, row
	else if overlayTileIndex == 126 then
		newspaper.placeDispenser col, 199-row
		displays.decoration.setCell col, 199-row, overlayTileIndex
	else if overlayTileIndex == 127 then
		// place Plopper!
		player.x = col * 64 + 32
		player.y = (199-row) * 64 + 48
	else
		displays.decoration.setCell col, 199-row, overlayTileIndex
	end if
end function	

setup = function
	displays.decoration.tileSet = file.loadImage("pics/CityTilesOverlay.png")
	displays.decoration.tileSetTileSize = 32
	displays.decoration.cellSize = 64
	displays.decoration.extent = [600,200]
	displays.decoration.clear null

	f = file.open(tmjFileName, "r")
	tmjData = f.read
	f.close

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
		player.ability[power] = 0
	end for
	drawSlots
end function

handleCheatKey = function(k)
	if k < "1" or k > "8" then return false
	kval = k.val
	if kval == 1 then player.ability.web = true
	if kval == 2 then player.ability.webBoost = 1
	if kval == 3 then player.ability.wallCling = true
	if kval == 4 then player.ability.speedBoost = 1
	if kval == 5 then player.ability.speedBoost = 2
	if kval == 6 then player.ability.jumpBoost = 1
	if kval == 7 then player.ability.jumpBoost = 2
	if kval == 8 then player.ability.glide = true
	drawSlots
	return true
end function

if locals == globals then
	setup
end if
