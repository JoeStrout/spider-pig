// Module to manage our display layers.

initialized = false

setup = function
	clear
	// Far background (sky)
	display(7).mode = displayMode.solidColor
	outer.sky = display(7)
	sky.color = "#000044"
	
	// City background (parallax buildings)
	display(6).mode = displayMode.sprite
	outer.parallax = display(6)
	
	// City tile layer
	display(5).mode = displayMode.tile
	outer.building = display(5)
	building.tileSet = Image.create(32,32,color.clear)
	building.clear
	
	// City decoration tiles (unused for now)
	display(4).mode = displayMode.tile
	outer.decoration = display(4)
	decoration.tileSet = Image.create(32,32,color.clear)
	decoration.clear
	
	// Sprite layer (Spider-Pig, web, pickups, etc.)
	display(3).mode = displayMode.sprite
	outer.sprite = display(3)
	sprite.clear

	// UI layer
	display(2).mode = displayMode.pixel
	outer.ui = display(2)
	ui.clear color.clear
	globals.gfx = ui
	
	// Text layer
	display(1).mode = displayMode.text
	globals.text = display(1)
	text.clear
	
	// Frontmost layer: curtain (also used for QA etc.)
	display(0).mode = displayMode.off // for now!
	
	initialized = true
end function

setupIfNeeded = function
	if not initialized then setup
end function

if locals == globals then setup
