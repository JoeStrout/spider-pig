## Sat, Aug 3 2024

Jam is starting.  Not much time!  Thing that concerns me most initially is making a decent-looking city.  Discord user @Territorial (@Armen on the MiniScript server) is helping out.  Possible city tilesets we could try to adapt:

- https://craftpix.net/product/business-center-tileset-pixel-art/
- https://craftpix.net/product/residential-area-tileset-pixel-art
- https://craftpix.net/freebies/free-scrolling-city-backgrounds-pixel-art
- https://malser-gamedev.itch.io/town-city-tiled-background
- https://opengameart.org/content/8-bit-city-tile-set

I could also maybe adapt DYZE-tiles.png, from the DYZE project.  None of these are really ideal though.  Territorial may end up making custom tiles.

Other assets we might be able to use...
City decorations:
- https://craftpix.net/product/city-signs-and-barriers-pixel-art/

Collectible food:
- https://craftpix.net/?s=food+icons
- https://craftpix.net/product/street-food-for-cyberpunk-pixel-art-32x32-icons/
- https://craftpix.net/product/street-snacks-pixel-art-32x32-icon-pack/
 
Alien tech powerups:
- https://craftpix.net/product/cyberpunk-artefact-icons-pixel-art

Fonts (convert to BMF?):
- https://craftpix.net/product/cyberpunk-pixel-art-font-effects/

## Sun, Aug 4 2024

OK we have basic mechanics working.  I've created an itch.io page at https://joestrout.itch.io/spider-pig, though it's still secret (draft).  Game seems to play OK in the browser so far.

So let's consider the powerups that you can collect to change the mechanics:

- Run Speed Boost (1 and 2)
- Jump Boost (1 and 2)
- Glide (hold jump while falling to trade Y velocity for X velocity)
- Wall Cling (hold away(?) while passing wall to cling to it
- Web Length (shoot web farther than the click, still auto-targeting)

I wonder about the wall cling — pushing away from a wall is kind of standard, but I always find it super difficult, because of course pushing away from a wall makes it harder to actually run into it.  And impossible to _run_ to a wall and then up it; you have to have sufficient momentum to overcome the fact that you're pushing the other way.  Works OK with Up because gravity ensures you continue to go down anyway, but with Left/Right it's quite difficult.

So, what if we had another control for that?  Shift maybe?  That could be just the "cling" button, and it could work for both horizontal and vertical surfaces.  That's probably worth prototyping today.

The other main mechanic we don't yet have is auto-targeting of webs (and restricting the attachment to buildings).  That's another important goal for today.

OK, so I've added both these features (shift-grab and auto-targeting), and it's feeling better.  Shift does seem easier to me for landing on a floor (though pressing Up also works).  And it'll certainly be easier for wall clinging.

I think maybe it's time to start scattering pickups around the city.  There are two kinds: powerups, which modify the mechanics as above; and simple collectibles (food), which are for the completionists.

Oh, and I guess we also need some overall goal besides just "complete everything" — something the speed-runners have to do to complete the level.  Ideally this would be something you can see but not reach until you've gotten all the powerups.  Well, maybe not all.  Maybe it's something like: you can only reach the exit (a floating UFO?) by gliding, and Glide is the hardest powerup to get, so you'll probably want the others to help you get that.


## Wed, Aug 7 2024

Weekdays are tough!  Didn't manage to touch this for a couple of days.  Let's take stock of where we are.

- Powerups are placed and collectible, but have no actual effect.
- Food is not yet placed or collectible.
- Armen has made some truly beautiful tile-based buildings, but they're not yet incorporated into the actual game.
- There is no end condition.
- Our hero sprite has only a single frame (though a number of others have been designed in Graphic), so no animation.

So that identifies the major features we need to get working ASAP.  I think tonight I'll focus on the first two.

## Fri, Aug 9 2024

OK, the weekend is here and we now have basically 2 days to finish the game!  The deadline is technically Monday morning, but that means I need to finish it Sunday night.

The most urgent features, it seems to me, are:

- Game end detection, and game-over results (including time)
- Spider-Pig animation
- Pop-ups with each powerup that tell you what they do and how to use them

I also think we need something to tell the story... maybe a newspaper dispenser, and when you pause in front of it, it pops up a headline?  Or, a news ticker on a building?  But that's less urgent than the above.

Going to start with the pop-ups.

WEB:
• Click and hold to shoot web
• Release mouse to release web
WEB BOOST:
• Web now shoots much farther!
JUMP BOOST:
• 50% higher jump per level!
SPEED BOOST:
• 50% faster run speed per level!
WALL CLING:
• Hold Shift while approaching a wall to cling to it
• Shift my be released while on wall
GLIDE:
• Hold Jump in the air to glide

OK, got those working.  Getting glide without Wall Cling is *really* hard, so I think we're off to a good start here.  Did a trial glide from the next-to-last building before the bridge; glided over ta a likely place for the UFO, at X=35254, Y=3189.

## Sun, Aug 11 2024

LAST DAY!  I failed to update the log yesterday but I did add player animations and some other refinements.  This morning so far, I've added the newspaper pop-up that gives some of the backstory, and created a simple animated sprite for the UFO.

But before I get to that, I had an idea about roofs/ledges.  I'm thinking you should automatically stop on those whenever you are in freefall, i.e., not attached to a web, and also not pressing Down.  I find this is almost always what I want to do, and playing while holding the Shift key is a pain.


