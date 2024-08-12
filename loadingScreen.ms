import "importUtil"
ensureImport "displays"

BARLEFT = 440
BARWIDTH = 315
BARBOTTOM = 275
BARHEIGHT = 20

drawBar = function(fractionDone = 0.5)
	g = display(0)
	g.fillRect BARLEFT, BARBOTTOM, BARWIDTH, BARHEIGHT, "#000088"
	g.fillRect BARLEFT, BARBOTTOM, BARWIDTH*fractionDone, BARHEIGHT, "#44FF44"
	g.drawRect BARLEFT, BARBOTTOM, BARWIDTH, BARHEIGHT, "#CCCCFF", 3
end function

begin = function
	display(0).mode = displayMode.pixel
	g = display(0)
	for alpha in range(0, 255, 10)
		g.clear color.rgba(0, 0, 0, alpha)
		yield
	end for
	g.clear color.black
	img = file.loadImage("pics/Loading.png")
	g.drawImage img, 480-img.width/2, 320-img.height/2
	drawBar 0
end function

fadeOut = function
	g = display(0)
	for alpha in range(255, 0, -10)
		g.clear color.rgba(0, 0, 0, alpha)
		yield
	end for
	display(0).mode = displayMode.off
end function


