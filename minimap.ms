// This module creates and manages the mini-map, which shows where
// Spider-Pig and the important pickups are in the city.

// createMapGraphic: call this (at development time) to recreate the
// tiny image of the city.  Assumes our city is already loaded.
createMapGraphic = function
	gfx.clear color.clear
	text.clear
	displays.sprite.clear
	display(7).color = "#660066"
	bg.scale = 0.1
	bg.scrollX = 0
	bg.scrollY = 0
	img = Image.fromScreen
	globals.mapimg = img.getImage(0, 0, bg.width*0.1, bg.height*0.1)
	file.saveImage "pics/minimap.png", mapimg
	print "Updated pics/minimap.png"
end function

LEFT = 716
BOTTOM = 4
WIDTH = 240
HEIGHT = 80

SCALE = WIDTH / (600 * 64)

setup = function
	outer.mapImg = file.loadImage("pics/minimap.png")
end function

update = function
	g = displays.ui
	g.drawImage mapImg, LEFT, BOTTOM
	g.drawRect LEFT-1, BOTTOM-1, WIDTH+2, HEIGHT+2, "#FFFF00", 2
	x = player.x * SCALE
	y = player.y * SCALE
	if 0 < x < WIDTH then
		g.line LEFT + x, BOTTOM, LEFT + x, BOTTOM + HEIGHT, "#FFFFFF88"
	end if
	if 0 < y < HEIGHT then
		g.line LEFT, BOTTOM + y, LEFT + WIDTH, BOTTOM + y, "#FFFFFF88"
	end if
end function

if locals == globals then
	createMapGraphic
	view mapimg
end if
