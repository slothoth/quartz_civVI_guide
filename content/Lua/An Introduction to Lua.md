Lua is the programming language used to manipulate the User Interface of the game. There are a lot functions exposed in Lua that a programmer can use to achieve their goals, if they want to change a given UI element, or add a new one. As well as this, a Gameplay specific environment of Lua is available to write scripts that affect actual gameplay, not just a player's UI. It can also be used to make procedurally generated maps.

If you already have experience with programming languages, a good guide to Lua specific quirks and syntax is here:
> https://learnxinyminutes.com/lua/

A few "gotchas" of Lua:
- Lua often uses nil return values rather than erroring out. So for example if you try access a value that doesn't exist in a table, it will just return nil.
- A common pattern in Lua is then to do "if my_table\[my_value\] then ...". You can think of this as just checking the value exists. When you start getting into more complicated projects, my_value itself might be gotten from a table access, and if that table didn't contain it, would return nil. And if you try use nil as the index of a table, you would error on the second table, rather than the source, on the first.

# Gameplay Lua

Lua gameplay scripting is far more freeform than the functionality one can get from Modifiers or other Database mods, but comes with some caveats. The AI cannot understand Lua scripts, where it has some understanding of Modifiers, so it will play significantly worse around such mechanics. In addition, if you added a UI element like an active ability on a unit, the AI would never be able to use it, unless you wrote a script for deciding when it should use it.

Lets go through a simple example of a gameplay Lua mod. The modinfo action for adding a Lua gameplay script looks like this:

```xml
<AddGameplayScripts id="my_test_lua">  
   <File>Maintenance.lua</File>  
 </AddGameplayScripts>
```

A Lua gameplay file runs when you load into a map once. In that time, it should define functions and callbacks
```lua
-- A lua comment is with two hyphens

-- The first section defines some variables. First it gets information from
-- the gameplay database about some data, in this case a policy, and
-- buildings. It gets accessed by GameInfo, and the dot notation gets 
-- the table, Policies or Buildings, and the index of it in the table
m_eScholarshipPolicy = GameInfo.Policies["POLICY_URBAN_PLANNING"].Index;
m_tScholarshipBuildings = {}
m_tScholarshipBuildings[1] = GameInfo.Buildings["BUILDING_MONUMENT"].Index  
m_tScholarshipBuildings[2] = GameInfo.Buildings["BUILDING_GRANARY"].Index

function OnPolicyChanged(iPlayerID, ePolicyIndex, bEnacted)  
    if (ePolicyIndex == m_eScholarshipPolicy) then  
       local pPlayer = Players[iPlayerID];  
       local pPlayerCulture = pPlayer:GetCulture() 
       local bPolicyActive = pPlayerCulture:IsPolicyActive(ePolicyIndex);  
       if not bPolicyActive then
	      local pCities = pPlayer:GetCities()
          for idx, pCity in pCities:Members() do  
             for table_indx, iBuildingIndex in pairs(m_tScholarshipBuildings) do
	            local pCityBuildings = pCity:GetBuildings()
                pCityBuildings:RemoveBuilding(iBuildingIndex)  
             end  
          end
        end
    end
end

GameEvents.PolicyChanged.Add(OnPolicyChanged);
```
It defines a function OnPolicyChanged. When that function fires, it checks if the value ePolicyIndex passed in is the same as the one for urban planning. If so, it then checks its active for that given player, and if it is no longer active, goes through each of the player's cities, removing any Monuments or Granaries. 

When does this function fire? The last line is whats called a *callback*. You can read it as, anytime the GameEvent PolicyChanged happens, fire this function. As you might guess, that GameEvent happens when a player changes their policies.

Knowing things like how GameInfo can be queried, or knowing how to get a Player object:
```lua
local pPlayer =  Players[iPlayerID];
```
 is primarily done via recognising them by name, or by seeing them used by Firaxis or other modders.  One of the most useful tools for Lua is the Modding Companion 2.0, on the Objects sheet:
> https://docs.google.com/spreadsheets/d/1EiCTOlPx3IkeAmU0xujGEp9k0v9VuCxe95OcrsyWOVs/

This details all the possible Objects specific to Civ, and the functions those objects have. I have used that here to find the function *IsPolicyActive()* which I can see is a part of the Culture object, which itself is contained in a Player object. Working back from that, I could then know I needed to get a Player object first. Similarly, I found the *RemoveBuilding()* function, and worked back to see it was a method of the City object. I then looked for references to City in the Player object, and found the *GetCities()* method.

I then used the Events sheet on the Modding Companion, which details the GameEvents and the arguments they use. I looked for ones related to Policies, and found this one.

## Context
Regardless if you are just modding UI or Gameplay an important concept to understand is the Context of where you are working. Gameplay and UI contexts are different in terms of what functions, objects and Events they can access. The Modding Companion provides a helpful tick explaining which is available. There may be occasions where you are working in one context, and need a function from a different context. This requires bridging the context, or ferrying information from one context to another. This is a complicated use case, so is covered [[Lua Context Bridging|here]].

You might ask, why does these two contexts exist? Well it allows separation of concerns. If a group of players are playing civ, they might like to use different UI mods to customise their experience better. The game lets players play together with different UI mods, but not with different gameplay mods. Because those mods exist only in the UI side, there is no way for those mods to affect the gameplay. One player can't add a "cheat" mod that would grant them extra units or resources. Even outside of cheating, this separation is important. Online multiplayer relies on several instances of the game running on different computers. Its very important that the information of the game state on each computer is identical to all the others, which is called Synchronisation. This is likely done by each copy of the running game passing information to each other game on what action was taken, and each executes it to ensure the internal state is the same. If a player had a gameplay Lua mod that wasn't present on the other game, then certain actions would differ, and the other copies could not execute commands to have the same internal state. The game freaks out and cant handle it, as which copy should be seen as the source of truth. This is called a *desync*, and desync's are a major gripe when playing online multiplayer, so UI being its own context prevents modders accidentally causing desync bugs. 

Ideally, a gameplay mod doesn't desynchronise either, but there are subtle behaviours you need to be aware of to ensure different games have the same behaviour. A classic example would be the first release of Sukritact's Urban Identities mod, which creates random regions of the map that have unique bonuses. To do so, at one point it creates a table, a data structure that holds items, and iterates over it. In Lua, a table is an amalgam of a ordered list, and an unordered dictionary of key-value pairs, depending on how entries were inserted into it. The mod iterates over that table using a base Lua function called *pairs()*, and what the modder did not realise was that the order of the items retrieved through iteration is not reliably fixed across different hardware and computers, so items were being processed in different ways across different computers.
# Workflow
Programming for the most part should be an iterative process, particularly when you are just starting out. It's a huge pain writing a ton of code, and having to go line-by-line seeing what the problem is. For writing a new piece of code, I would encourage using the [[Firetuner]] console to write each line, confirm you are getting what you expect back, and then proceeding to the next line.

This can become impractical when designing large pieces of code, or ones that rely on information from Events. There is no easy way to step through Lua code running in the game with a debugger, and there is no easy way to emulate the return values in external debuggers. So your best bet is to use print statements to confirm your assumptions about your code:
```lua
print(Players[0])
```
A line like this will show up in your Lua.log:

![[print_lua_log.png]]A sad note is that Lua.log does not exist on MacOS versions of the game, nor can Firetuner be used. It is still possible to run Lua mods, but it becomes very difficult to test them.

An additional way to speed up your code writing is to use a code editor with code completion and linting. For this tutorial we will use Sublime, but tools like PyCharm or Visual Studio Code would work well. We will use WildW's excellent [[Tool Links#VS Code Library| VS Code Extension]]:

![[lua_library_completion.png]]
You can see here the power of code completion. The editor has read the contents of the library file, which defines the return value of objects in the Players table, and so knows what methods are available for that object. Saves a ton of time referring to the Modding Companion, though I don't believe it separates the Lua Contexts out, so you should still be wary of that.


# UserInterface Lua
[[User Interface Mod]]


# Useful Notes:
Lua and this game tends to follow the hungarian variable naming convention, where you put a letter before the variable name in lower case to state what type it is. So sVal for string, iVal for integer, pPlayer for pointer, tParameters for table.

You may also notice when examining scripts written by firaxis a weird script that will not be parsed correctly in any normal lua, like:
```lua
local :table parameters = {}
```
This is their underlying Typing system, so that humans, their linter or other code tools can interpret and understand variables better, as Lua is not a typed language. If you dont understand what that means, its probably best not to think too much about it, just know that you can safely omit it in your own code.