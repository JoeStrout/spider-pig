import "importUtil"

ensureImport "displays"

layers = []

setup = function
	displays.setupIfNeeded
	sprites = displays.parallax.sprites
	outer.layers = []
	for i in range(1,5)
		pair = []
		sp = new Sprite
		sp.image = file.loadImage("pics/background/" + i + ".png")
		sp.scale = 3
		h = sp.image.height * sp.scale; w = sp.image.width * sp.scale
		sp.x = w/2
		sp.y = h/2
		sprites.push sp
		pair.push sp
		
		sp2 = new Sprite
		sp2.image = sp.image
		sp2.scale = sp.scale
		sp2.x = sp.x + w
		sp2.y = sp.y
		sprites.push sp2
		pair.push sp2
		layers.push pair
	end for
	
	outer.street = new Sprite
	street.image = Image.create(960, 230, "#242927")
	street.x = 480
	street.y = 115
	sprites.push street
end function

updateForCamera = function(x, y)
	if not layers then setup
	for idx in layers.indexes
		scrollScale = [0.1, 0.2, 0.4, 0.6, 0.8][idx]
		pair = layers[idx]
		sp = pair[0]
		h = sp.image.height * sp.scale; w = sp.image.width * sp.scale
		sp.x = w / 2 - (x * scrollScale) % w
		pair[1].x = sp.x + w
		
		scrollScale *= 0.15  // (less scrolling vertically)
		sp.y = h / 2 - (y * scrollScale)
		if idx == 0 and sp.y + h/2 < 640 then
			sp.y = 640 - h/2
		end if
		pair[1].y = sp.y
	end for
	
	street.y = 115 - 80 - y
end function

if locals == globals then
	setup
	for x in range(0, 35300, 10)
		updateForCamera x, 320
		yield
		if key.available then break
	end for
	for y in range(320, 4000, 10)
		updateForCamera x, y
		yield
	end for
end if