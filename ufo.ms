// Manages the UFO which is the ultimate exit/goal for the level.

import "importUtil"
ensureImport "mathUtil"
randRange = @mathUtil.randRange

// UFO position:
X = 35254
Y = 2120  // 3189

ufo = null
arrow = null

Spark = new Sprite
Spark.frames = []
for i in range(0,3)
	Spark.frames.push file.loadImage("pics/Sparks0" + i + ".png")
end for
Spark.image = Spark.frames[0]
Spark.vx = 0
Spark.vy = 10		// per frame, not per second
Spark.alpha = 255
Spark.make = function
	sp = new self
	sp.x = ufo.x + randRange(-64, 64)
	sp.y = ufo.y + randRange(0, 40)
	sp.rotation = randRange(0, 360)
	sp.vx = randRange(-5, 5) + randRange(-5, 5)
	sp.vy = randRange(2, 20) + randRange(2, 20)
	sp.image = Spark.frames.any
	sparks.push sp
	displays.sprite.sprites.insert 0, sp
	return sp
end function
framesTillNextSpark = 0

Spark.update = function
	self.alpha -= 1
	if self.alpha < 1 then return false
	self.x += self.vx
	self.y += self.vy
	self.tint = self.tint[:7] + hex2(self.alpha)
	if self.vy > -10 then self.vy -= 1
	self.vx *= 0.99
	return self.y > 0
end function
sparks = []

setup = function
	outer.ufo = new Sprite
	outer.frames = []
	for i in range(0,3)
		frames.push file.loadImage("pics/UFO-" + i + ".png")
	end for
	ufo.image = frames[0]
	ufo.x = X
	ufo.y = Y
	ufo.scale = 0.5
	displays.sprite.sprites.push ufo
	
	outer.arrow = new Sprite
	arrow.image = file.loadImage("/sys/pics/arrows/arrow2.png")
	arrow.scale = 0.5
	arrow.tint = "#88FF8888"
	displays.sprite.sprites.push arrow
end function


handleUfoCaught = function
	ufo.tint = color.yellow
	globals.gameOver = true
	file.loadSound("/sys/sounds/bling.wav").play
	for i in range(90)
		updateSparks
		yield
	end for
end function

updateSparks = function
	outer.framesTillNextSpark -= 1
	if framesTillNextSpark <= 0 then
		Spark.make
		outer.framesTillNextSpark = randRange(5,30)
	end if
	for i in range(sparks.len-1, 0, -1)
		sp = sparks[i]
		if not sp.update then
			displays.sprite.sprites.removeVal sp
			sparks.remove i
		end if
	end for
end function

pointInBounds = function(x, y)
	// Keep the given xy point on a zero-centered box defined by:
	halfWidth = 920/2
	halfHeight = 600/2

	// If the object is within the bounds, no need to move
	if -halfWidth < x <= halfWidth and -halfHeight < y <= halfHeight then
		return [x, y]
	end if
	
	// Determine the intersections with each side of the screen
	if x != 0 then
		// Intersection with the left and right bounds
		if x > 0 then ix = halfWidth else ix = -halfWidth
		iy = y * ix / x
	else
		ix = 0
		if y > 0 then iy = halfHeight else iy = -halfHeight
	end if
	
	if y != 0 then
		// Intersection with the top and bottom bounds
		if y > 0 then iy2 = halfHeight else iy2 = -halfHeight
		ix2 = x * iy2 / y
	else
		if x > 0 then ix2 = halfWidth else ix2 = -halfWidth
		iy2 = centerY
	end if

	// Select the closest valid intersection point
	if -halfWidth <= ix <= halfWidth and -halfHeight <= iy <= halfHeight then
		return [ix, iy]
	else
		return [ix2, iy2]
	end if
end function

updateArrow = function
	arrow.rotation = atan(ufo.y - player.y, ufo.x - player.x) * 180/pi
	dx = ufo.x - player.x
	dy = ufo.y - player.y
	if (abs(dx) < 480 and abs(dy) < 320) or (time*2) % 1 < 0.25 then
		arrow.tint = color.clear
	else
		arrow.tint = "#88FF8888"
	end if
	xy = pointInBounds(dx, dy)
	arrow.x = player.x + xy[0]
	arrow.y = player.y + xy[1]
end function

update = function
	t = time
	ufo.rotation = 20 * sin(t) * sin(3.7*t) * sin(5.3*t)
	
	if not gameOver and ((player.x - X)^2 + (player.y - Y)^2) < 10000 then
		handleUfoCaught
	end if
	
	updateSparks
	updateArrow
end function
