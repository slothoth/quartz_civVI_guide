Sometimes, you want to implement an Effect that makes sense in being a Modifier, but the requirement isn't possible to do in the Requirements system. So in this case, we want to implement our Requirement via Lua, and the effect via the Modifiers system. This is where bridging the gap between the Modifier system and Lua is useful. There are technically multiple ways of doing this, but practically, there is a "correct" way, using Plot Properties.

Here is an example of a modifier that allows any player to build a certain project based on an on-off switch from Lua. On the Database side, we set this up:
```sql
INSERT INTO BuildingModifiers(BuildingType, ModifierId) VALUES  
('BUILDING_PALACE', 'ALLOW_BANE_DIVINE');  
  
INSERT INTO Modifiers(ModifierId, ModifierType, OwnerRequirementSetId) VALUES  
('ALLOW_BANE_DIVINE', 'MODIFIER_PLAYER_ALLOW_PROJECT_CHINA', 'ARMA_ABOVE_EIGHTY_REQS');  
  
INSERT INTO ModifierArguments(ModifierId, Name, Value) VALUES  
('ALLOW_BANE_DIVINE', 'ProjectType', 'PROJECT_BANE_DIVINE');

INSERT INTO Requirements(RequirementId, RequirementType) VALUES  
('ARMA_ABOVE_EIGHTY', 'REQUIREMENT_PLOT_PROPERTY_MATCHES');  
  
INSERT INTO RequirementArguments(RequirementId, Name, Value) VALUES  
('ARMA_ABOVE_EIGHTY', 'PropertyName',     'ArmageddonAboveSeventy'),  
('ARMA_ABOVE_EIGHTY', 'PropertyMinimum',  '1');  
  
INSERT INTO RequirementSetRequirements(RequirementSetId, RequirementId) VALUES  
('ARMA_ABOVE_EIGHTY_REQS', 'ARMA_ABOVE_EIGHTY');  
  
INSERT INTO RequirementSets(RequirementSetId, RequirementSetType) VALUES  
('ARMA_ABOVE_EIGHTY_REQS', 'REQUIREMENTSET_TEST_ANY');
```

We attach on **BUILDING_PALACE**,  because we want information about the plot of the player's capital city. And we set up the requirement that a Plot Property called ArmageddonAboveSeventy has a certain minimum value of 1, using the RequirementType **REQUIREMENT_PLOT_PROPERTY_MATCHES**.

Now what is a Property? In short terms, you can think of a Property as a key:value pair that belongs to an object. Various different object types can have Properties, such as Players, the Game itself, but importantly none of those Property types have a RequirementType to check their values in the Effects system. Lets see how the Lua side is set up to monitor the game state and adjust the Property, though this has been simplified for clarity to a turn timer, that allows building the project if the turn is even:

```lua
function CheckArmageddon()
	local iGameTurn = Game.GetCurrentGameTurn()
	local iOnSwitch = 0 
	if (iGameTurn % 2 == 0) then
		iOnSwitch = 1
	end
	for _, pPlayer in ipairs(PlayerManager.GetAliveMajors()) do
		local pCapitalCity = pPlayer:GetCities():GetCapitalCity()
		if pCapitalCity then
			local pCapitalCityPlot = pCapitalCity:GetPlot()
			pCapitalCityPlot:SetProperty('ArmageddonAboveSeventy', iOnSwitch)
		end
	end  
	-- you could access a property with this
	-- local iEvenOn = Players[0]:GetProperty('ArmageddonAboveSeventy') 
end

GameEvents.OnGameTurnStarted.Add(CheckArmageddon)
```

So this is a function that runs every turn, and sets a Plot Property on every capital cities location. 

The power of this method is its reversible, you can turn it on or off easily. There are also AttachModifierbyId functions on certain objects that allow you to create a modifier and apply it using Lua, but an important caveat is that those modifiers are not reversible, you cannot then remove them using Lua.

