// Module to draw the building reference layer
// into a low-res PixelDisplay.

tmjFileName = "City.tmj"
groundColor = "#FFFF00FF"

import "json"
import "mapUtil"

f = file.open(tmjFileName, "r")
tmjData = f.read
f.close

print "Parsing " + tmjFileName + "..."
tmj = json.parse(tmjData)
print "Done parsing TMJ data"

refLayer = tmj.layers[-1]
print "Rendering " + refLayer.name

scaleFactor = 8
fullWidth = 600 * 32
scaledWidth = fullWidth / scaleFactor
fullHeight = 200 * 32
scaledHeight = fullHeight / scaleFactor

clear
gfx.clear color.clear
display(6).mode = displayMode.pixel
refg = display(6)
refg.clear color.black, scaledWidth, scaledHeight
refg.scale = scaleFactor

drawObject = function(data)
	x = data.x / scaleFactor
	y = refg.height - data.y / scaleFactor
	if data.hasIndex("polygon") then
		pts = []
		for p in data.polygon
			pts.push [x + p.x / scaleFactor,
			  y - p.y / scaleFactor]
		end for
		refg.fillPoly pts, color.gray
		refg.drawPoly pts, color.silver
	else
		w = data.width / scaleFactor
		h = data.height / scaleFactor
		refg.fillRect x, y - h, w, h, color.gray
		refg.drawRect x, y - h, w, h, color.silver
		refg.line x, y-h, x+w, y, color.silver
		refg.line x+w, y-h, x, y, color.silver
		refg.line x, y, x+w, y, groundColor
	end if
end function

for obj in refLayer.objects
	drawObject obj
end for
