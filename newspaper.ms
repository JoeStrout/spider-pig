// This module manages the newspaper machine (with little bouncing "!"
// icon over it), and the pop-up newspaper.

iconSprite = null

newspaper = null

setup = function
	outer.iconSprite = new Sprite
	iconSprite.image = file.loadImage("pics/newsIcon.png")
	displays.sprite.sprites.push iconSprite
end function


placeDispenser = function(col, row)
	setup
	iconSprite.x = col * 64 + 32
	iconSprite.baseY = row * 64 + 100
	iconSprite.y = iconSprite.baseY
end function

showNewspaper = function
	outer.newspaper = new Sprite
	newspaper.image = file.loadImage("pics/newspaper.png")
	newspaper.x = iconSprite.x
	newspaper.y = iconSprite.y + 20
	newspaper.finalY = iconSprite.y + 120
	newspaper.scale = 0.1
	displays.sprite.sprites.push newspaper
	displays.sprite.sprites.removeVal iconSprite
end function

hideNewspaper = function
	displays.sprite.sprites.removeVal newspaper
	outer.newspaper = null
end function

update = function
	if iconSprite == null then return
	iconSprite.y = iconSprite.baseY + 20 * abs(cos(time*4))
	range = abs(player.x + 50 * player.scale[0] - iconSprite.x)
	if player.y < 20 and newspaper == null and range < 20 then
		showNewspaper
	else if newspaper != null and range > 100 then
		hideNewspaper
	else if newspaper then
		newspaper.scale = mathUtil.moveTowards(newspaper.scale, 1, 0.95/15)
		newspaper.y = mathUtil.moveTowards(newspaper.y, newspaper.finalY, 100/15)
	end if
end function

