
Firetuner is a useful tool built by Firaxis that allows a player to cheat for fast testing, manipulate the game to test things, like placing units, inspect player level modifiers, and unit abilities, and lastly and most importantly, provides a Firetuner console, where you can access different file contexts and test the state of your scripts for debugging.

# Setup
Firetuner is available for Windows. You can find it by going to the Tools section of your Steam library, and installing "Sid Meier's Civilization VI Development Tools". It is not available for MacOS sadly.

You also will need to do some minor changes to your [[AppOptions.txt#Firetuner|AppOptions.txt]] to allow Firetuner to work.

Firetuner will open but will be essentially worthless until you load into a game of civ. On doing so, you should see that the dropdown box at the top left now lets you choose different contexts, and you can now pick one and start writing Lua lines. Importantly, change from the "Main State" as it contains almost no game data. I normally use GameCore for Gameplay and most anything saying Panel will do for UI context. See how I can't get the Players object in Main State:
![[print_lua_tuner.png]]

I imagine to save Firaxis time, they also allowed Firetuner to load .ltp files, their own file format that specifies UI elements and functions to populate them. There are many useful .ltp files available in your Civ VI install directory, something like:
`Steam\steamapps\common\Sid Meier's Civilization VI\Debug`

You can also make and edit the .ltp files yourself. They are written as XML files, but with Lua contained within sections to extract information from the game state.

I encourage you to explore the different Tuner panels to see which are useful to you, but I'll also highlight some useful ones:

## Modifiers
Through some black magic I don't quite understand, this .ltp gathers all the modifiers on Player objects and displays them in a very long list. You can click on an individual modifier and see how many instances are currently active, and if they satisfied or not.

# Players
This is a great way to cheat in getting certain Techs or Civics or making Wonders, a great way to test fast.

# WorldBuilder
This is probably the best for testing mod behaviour fast. Using this, you can choose a Unit, or a Feature, or most anything and with the checkmark ticked, place it in the game space with a left click, or remove it with a right click. A huge pitfall is that you cannot place units that do not follow the convention of 'UNIT_NAME', as I learnt to my own chagrin, at least not without editing the LTP.

# Units
This panel is very very useful as you can see all of each players Units, and their UnitIds, which I often use while scripting to find my starting scout and test whatever I want on them. It also lists Abilities and Promotions.