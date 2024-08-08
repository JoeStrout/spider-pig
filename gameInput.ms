// Module to handle game controller (keyboard) input.
// Just import this module, then check gameInput.horizontal
// and gameInput.vertical as needed.

horizontal = function
	ax = key.axis("Horizontal", false)
	if ax != 0 then return ax
	return key.pressed("e") - key.pressed("a") +  // dvorak
	  key.pressed("l")  - key.pressed("j") + // IJKL
	  key.pressed("n") - key.pressed("h")    // dvorak IJKL
end function

vertical = function
	ax = key.axis("Vertical", false)
	if ax != 0 then return ax
	return key.pressed(",") - key.pressed("o") +  // dvorak
	  key.pressed("i")  - key.pressed("k") + // IJKL
	  key.pressed("c") - key.pressed("t")    // dvorak IJKL
end function

jump = function
	return key.pressed("space")
end function

grabWall = function
	return key.pressed("left shift") or key.pressed("right shift")
end function

grabFloor = function
	return grabWall or vertical > 0
end function


if locals == globals then
	clear
	gfx.color = color.gray
	while true
		gfx.clear
		gfx.line 480-100, 320, 480+100, 320
		gfx.line 480, 320-100, 480, 320+100
		gfx.drawRect 480-64, 320-64, 128, 128
		x = 480 + 64 * horizontal
		y = 320 + 64 * vertical
		gfx.fillEllipse x-12, y-12, 24, 24, color.red
		yield
	end while
end if
