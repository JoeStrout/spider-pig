// Module to load and display the city buildings layer.

import "importUtil"
ensureImport "displays"
ensureImport "stringUtil"

tmjFileName = "City.tmj"
firstgid = 129  // OFI: get this from the JSON data

setup = function
	outer.disp = displays.building
	disp.extent = [600, 200]
	disp.tileSet = file.loadImage("pics/CityTilesMain.png")
	disp.cellSize = 64
	disp.tileSetTileSize = 32
	disp.clear

	f = file.open(tmjFileName, "r")
	tmjData = f.read
	f.close

	p1 = -1
	p0 = tmjData.indexOf("""data"":[", p1)
	// (we assume the CityMain layer is first in the file)
	p1 = tmjData.indexOf("]", p0)
	data = tmjData[p0 + 8: p1]
	globals.lines = data.split(char(10))
	for y in lines.indexes
		line = lines[y].replace(" ", "")
		elements = lines[y].split(",")
		for x in elements.indexes
			e = elements[x].val
			if e >= firstgid then disp.setCell x, 199 - y, e - firstgid
		end for
	end for


end function


if locals == globals then
	displays.setup
	setup
end if
