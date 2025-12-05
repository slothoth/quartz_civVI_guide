
# UI to Gameplay
As mentioned prior, the split of Gameplay and Context means that certain functions are unavailable to a player on the UI side. As some functions are absolutely required for certain functionality, we need to have a way to bridge the gap between the two. There are two methods of doing so, the *RequestPlayerOperation* approach and the *ExposedMembers* approach, which have their own upsides and downsides:
## RequestPlayerOperation
 This is a method you can access from the User Interface side. Its used in many ways in the UI, but for our purposes, we have the second parameter set to the Enum PlayerOperations.EXECUTE_SCRIPT. It requires a playerId, and a table with a string value for the key onStart:
```lua
-- UI context
local tParameters = {}  
tParameters.OnStart = 'SlthOnRally'
tParameters.MyInfo = 42
UI.RequestPlayerOperation(iPlayer, PlayerOperations.EXECUTE_SCRIPT, tParameters);
```

We then use that OnStart value to find the right function to execute. We set up a Gameplay Context Lua file with a function, and use that OnStart string as a GameEvent hook for *RequestPlayerOperation* to find. We can then proceed with what we want to do in the gameplay context, unpacking the tParameters table for any information we needed ferried across.
```lua
-- Gameplay Context
local function Rally(iPlayer, tParameters)
	
end
GameEvents.SlthOnRally.Add(Rally);
```

Some important notes about *RequestPlayerOperation*:
RequestPlayerOperation will silently fail if its not triggered on the given turn of the specific player its requested for, if the game is being played sequentially. This can trip you up if you have a UI hook that triggers at the start of the global game Turn, for every player.

Objects in the Gameplay and UI contexts have different pointer locations. What this means is this would fail:
```lua
-- UI Context
local pUnit = UnitManager.GetUnit(iPlayer, iUnitID)
local tParameters = {}  
tParameters.OnStart = 'SlthUnitExample'
tParameters.MyUnit = pUnit
UI.RequestPlayerOperation(iPlayer, PlayerOperations.EXECUTE_SCRIPT, tParameters);
```

```lua
-- Gameplay Context
local function UnitFail(iPlayer, tParameters)
	local pMyFerriedUnitObject = tParameters.MyUnit
	print(pMyFerriedUnitObject)
end
GameEvents.SlthUnitExample.Add(UnitFail);
```
Running this, *pMyFerriedUnitObject* would be nil, as it would be accessing a pointer location that makes no sense in this context. The correct way to do it would be to instead ferry across the UnitId, and use that with the playerId to get the unit on the Gameplay side:

```lua
-- UI Context
local tParameters = {}  
tParameters.OnStart = 'SlthUnitSuccess'
tParameters.MyUnitId = iUnitID
UI.RequestPlayerOperation(iPlayer, PlayerOperations.EXECUTE_SCRIPT, tParameters);
```

```lua
-- Gameplay Context
local function UnitSuccess(iPlayer, tParameters)
	local iUnitID = tParameters.MyUnitId
	local pUnit = UnitManager.GetUnit(iPlayer, iUnitID)
	print(pUnit)
end
GameEvents.SlthUnitSuccess.Add(UnitSuccess);
```


What are some downsides to using RequestPlayerOperation?
## ExposedMembers
An alternate method is to used whats called the ExposedMembers interface. Lua can have Global variables, where any other script can access them, and we can use a shared Object across both contexts to define a table with information that we want to share:
```lua
-- Gameplay Context
function HelloWorld(iValue, sValue)
	print('Hello World')
	print(iValue)
	print(sValue)
end
if ExposedMembers.MyFunctionHolder == nil then  
    ExposedMembers.MyFunctionHolder = {}  
end  
ExposedMembers.MyDataStructure.MyHelloWorld = HelloWorld;
```

```lua
-- UI Context
if ExposedMembers.MyFunctionHolder == nil then  
    ExposedMembers.MyFunctionHolder = {}
end
-- you can then use it in any function as you would normally
ExposedMembers.MyFunctionHolder.HelloWorld(4, 'Hi Ferried data!');
```

# Gameplay to User Interface
There are very few use cases for this I find, as the Gameplay context is a lot more varied in its functions than UI, beyond convenience functions. For example, you can check all the promotions of a unit using pUnit:GetExperience():GetPromotions() in the UI. In Gameplay, you don't have that method, so you would need to iterate over all available promotions and check if it has each one.

If you have some sort of gameplay scripting mod that has important values that don't reflect in the normal UI, you could ferry those across using SetProperty and GetProperty, on Player objects, City objects, whatever. 

You also would be able to use ExposedMembers, but you would not be able to use UI.RequestPlayerOperation pattern, as this is a UI only method.