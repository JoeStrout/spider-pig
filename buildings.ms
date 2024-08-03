import "listUtil"
clear

display(5).mode = displayMode.tile
bldgMain = display(5)
bldgMain.tileSet = file.loadImage("pics/CityTilesMain-light.png")
bldgMain.tileSetTileSize = 32
bldgMain.cellSize = 32
bldgMain.extent = [60,40]
bldgMain.clear

randRange = function(min, max)
	return floor(rnd * (max-min+1) + min)
end function

addDoor = function(x)
	bldgMain.setCell x, 0, randRange(80,81)
	bldgMain.setCell x, 1, randRange(82,85)
end function	

// Basic building made of random wall tiles, door,
// and windows
makeBasic = function(x0, width, height, wallTiles, topTile, tint)
	if wallTiles == null then wallTiles = range(8, 14)
	if topTile == null then topTile = wallTiles[0]
	x1 = x0 + width
	for y in range(0, height)
		for x in range(x0, x1)
			idx = wallTiles.any
			if y == height then idx = topTile
			bldgMain.setCell x, y, idx
			bldgMain.setCellTint x, y, tint
		end for
	end for
	addDoor randRange(x0+2, x1-2)
	xspacing = randRange(3,4)
	cols = floor(width / xspacing) - 1
	ystart = randRange(4,5)
	yspacing = randRange(3,5)
	windowTiles = range(98, 101) + [115]
	for x in range(floor((x0+x1)/2 - cols/2*xspacing), x1-2, xspacing)
		for y in range(ystart, height-3, yspacing)
			idx = windowTiles.any
			bldgMain.setCell x, y, idx
		end for
	end for
end function

// Brick apartment building; return used width
makeBrickApt = function(x0)
	tint = color.rgb(255, 25*randRange(0,10), 50)
	width = randRange(8, 16)
	height = randRange(3,8) + randRange(3,8) + randRange(0,8)
	makeBasic x0, width, height, range(8, 14), 15, tint
	return width
end function

// Large-brick tower
makeBigBrickTower = function(x0)
	tints = ["#FFFFE2FF", "#FFE9E6FF", "#E4E9E6FF"]
	width = randRange(8, 16)
	height = randRange(4,12) + randRange(4, 12)
	makeBasic x0, width, height, range(32,35)*2 + [36], 113, tints.any
	return width
end function

x = 1
while x < bldgMain.extent[0]
	x += makeBrickApt(x) + 2
	x += makeBigBrickTower(x) + 2
end while
