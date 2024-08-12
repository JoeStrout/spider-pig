// Title screen.

clear
Sound.stopAll

gfx.drawImage file.loadImage("pics/TitleScreen.png")


while mouse.button; yield; end while

while not mouse.button; yield; end while

while mouse.button; yield; end while

run "main"
