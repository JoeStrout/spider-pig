import "importUtil"
ensureImport "displays"
ensureImport "pickups"

displays.setupIfNeeded

gfx = displays.ui

printCentered = function(s, y, color="#88FF88", font="large")
	if font == "large" then cw = 20 else cw = 14
	w = cw * s.len
	gfx.print s, 480 - w/2, y, color, font
end function

show = function
	w = 600
	h = 400
	gfx.fillRect 480-w/2, 320-h/2, w, h, "#008800AA"
	gfx.drawRect 480-w/2, 320-h/2, w, h, "#88FF88", 5
	
	printCentered "YOU WIN!", 320 + h/2 - 50
	
	y = 320 + h * 0.1
	printCentered "Run time: " + formatTime(elapsedTime), y
	y -= 70
	printCentered "Food collected: " + pickups.formatFound, y
	y -= 70

	while key.pressed("return") or key.pressed("enter")
		yield
	end while
	
	printCentered "Press Return to exit.", 320 - h/2 + 30, "#88FF8888", "normal"
end function


if not globals.hasIndex("elapsedTime") then
	elapsedTime = 123
	formatTime = function(t)
		return floor(t / 60) + ":" + ("00" + str(t % 60))[-2:]
	end function
end if

show

while not key.pressed("return") and not key.pressed("enter")
	yield
end while
key.clear

reset; run "startup"