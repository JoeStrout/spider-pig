// Module to draw the building reference layer
// into a low-res PixelDisplay.

import "importUtil"
ensureImport "displays"

displays.setupIfNeeded

tmjFileName = "City.tmj"
groundColor = "#FFFF00FF"

import "json"
import "mapUtil"

f = file.open(tmjFileName, "r")
tmjData = f.read
f.close

print "Parsing " + tmjFileName + "..."
// The actual tile data is HUGE and takes forever to parse, and we don't
// need it here.  So, snip it out:
p1 = -1
while true
	p0 = tmjData.indexOf("""data"":[", p1)
	if p0 == null then break
	p1 = tmjData.indexOf("]", p0)
	tmjData = tmjData[:p0] + """data"":[0" + tmjData[p1:]
	p1 = p0+2
end while
tmj = json.parse(tmjData)
print "Done parsing TMJ data"

refLayer = tmj.layers[-1]
print "Rendering " + refLayer.name

scaleFactor = 16
fullWidth = 600 * 64
scaledWidth = fullWidth / scaleFactor
fullHeight = 200 * 64
scaledHeight = fullHeight / scaleFactor

// Our Tiled file is defined at half full scale, unfortunately.
// Maybe we can fix that?  But for now, here's the proper
// "tiled scale factor":
tsf = scaleFactor / 2

// The reference layer will replace the parallax layer (6).
display(6).mode = displayMode.pixel
refg = display(6)
refg.clear color.clear, scaledWidth, scaledHeight
refg.scale = scaleFactor

drawObject = function(data)
	x = data.x / tsf
	y = refg.height - data.y / tsf
	if data.hasIndex("polygon") then
		pts = []
		for p in data.polygon
			pts.push [x + p.x / tsf,
			  y - p.y / tsf]
		end for
		refg.fillPoly pts, color.gray
		refg.drawPoly pts, color.silver
	else
		w = data.width / tsf
		h = data.height / tsf
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

text.clear
