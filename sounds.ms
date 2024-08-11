// Loads and manages sound effects




setup = function
	Sound.stopAll
	outer.pig = {}
	for noise in "munch oink-huh oink-oh oink-ok oink-wtf oink-wuf squeal".split
		pig[noise] = file.loadSound("sounds/pig-" + noise + ".wav")
	end for
	for fx in "clop woosh".split
		outer[fx] = file.loadSound("sounds/" + fx + ".wav")
	end for
end function

