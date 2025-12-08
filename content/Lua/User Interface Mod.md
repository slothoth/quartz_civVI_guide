A User Interface consists of two things: an Interface XML file that defines UI elements and Lua UI file to orchestrate their usage.

Gameplay Lua modding is a lot "purer" than UI modding, meaning theres a lot more time worrying about things other than Lua while doing it. The User Interface has lots of existing file and interfaces that one might need to attach to, and understanding the basic UI hierarchy can help in understanding how to then add new UI elements. For example, say you wanted a new button at the top left, like how the Global Warming button is, as is done for Sukritact's Global Relations Panel. The panel itself can be whole cloth, and completely controlled by you, the modder, but that Stack of buttons needs to be controlled by other modders and by Firaxis as well. Say i overrode the file that controlled it, using mostly Firaxis code but adding a small extra bit for my button. That would work fine in vacuum. But some other modder had the same idea, and we both did that, and now a user can only ever use one of our two mods.

There are solutions to this problem, depending on exactly how its laid out. Lets go through some design patterns:

## Injection
This is often the cleanest way to modify existing UI elements, since you are not overriding or inheriting and so don't have to consider mods, DLC, local variables. You set up a Lua file that injects content into other existing UI elements.

ModInfo:
```xml
<?xml version="1.0" encoding="utf-8"?>  
<Mod id="d42d420b-eef2-48da-b71f-2f13b34e6e42" version="1">  
  <Properties>  
    <Name>UI Test Button</Name>  
    <Description>Adds a Button to the Unit Panel that does nothin</Description>  
    <Created>1588793234</Created>  
    <Teaser>No point to this</Teaser>  
    <Authors>Slothoth</Authors>  
    <CompatibleVersions>1.2,2.0</CompatibleVersions>  
  </Properties>  
  </Dependencies>  
  <InGameActions>  
    <AddUserInterfaces id="MyTestUI">  
		<Properties>  
		     <Context>InGame</Context>  
		</Properties>  
		<File>Operations.xml</File>  
	 </AddUserInterfaces>
  </InGameActions>  
  <Files>  
    <File>Operations.lua</File>  
	<File>Operations.xml</File>
  </Files>  
</Mod>
```
You need two files, an xml and a .lua file, with the same name. Then you have a AddUserInterfaces Action, that only mentions the xml file.

Operations.xml:
```xml
<?xml version="1.0" encoding="utf-8"?>  
<Context>  
    <Grid ID="SettleButtonGridUnitUpgradeAlt" Anchor="R,B" Size="auto,41" AutoSizePadding="6,0" Texture="SelectionPanel_ActionGroupSlot" SliceCorner="5,19" ToolTip="UPGRADE_ALT_2" SliceSize="1,1" SliceTextureSize="12,41" ConsumeMouse="1" Alpha="0.75">  
       <Button ID="SettleButtonGridUnitUpgradeAlt" Anchor="C,B" Size="44,53" Texture="UnitPanel_ActionButton">  
          <Image ID="SettleButtonGridUnitUpgradeAlt"     Anchor="C,C" Offset="0,-2" Size="38,38" Texture="Notifications40"/>  
       </Button>  
    </Grid>  
</Context>
```
Operations.Lua
```lua
local path = '/InGame/UnitPanel/StandardActionsStack'  
local ctrl = ContextPtr:LookUpControl(path)
if ctrl ~= nil then  
    local gridButton = Controls.SettleButtonGridUnitUpgradeAlt
    gridButton:ChangeParent(ctrl)  
end  
-- could then
gridButton:SetHide(true)  -- hide it,
gridButton:SetHide(false)  -- display it, do various things

function HelloWorld()
	print('Hello World')
end
gridButton:RegisterCallback(Mouse.eLClick, HelloWorld).  -- make it do a function on click

```
We get a UI element from its path, called ctrl. Our button that we defined in our xml file is then transferred to belong to that UI element we are interested in, using ChangeParent. So it now should show up in that UI element. As we still have the reference to it, we can then programatically adjust things about it, i.e. we still have control over it.

Note: You can see the paths of all the UI elements in the [[Firetuner]] Panel called Forge

One thing that's really great about UserInterface modding, is despite its complexity, iterative development can be incredibly fast. The UI should automatically reload anytime you save a file being used in the UI. So you can modify your file mid-game, alt-tab back in, and see your changes live, and repeat.

## Inheritance
What if you want to edit a function used by an existing UI element? We want to preserve all of the other parts, but amend this other function. This is where the `ReplaceUIScript/include` pattern is useful:

```xml
<?xml version="1.0" encoding="utf-8"?>  
<Mod id="d42d420b-eef2-48da-b71f-2f13b34e6e42" version="1">  
  <Properties>  
    <Name>UI replace Top Panel Func</Name>  
    <Description>Changes top Panel numbers</Description>  
    <Created>1588793234</Created>  
    <Teaser>No point to this</Teaser>  
    <Authors>Slothoth</Authors>  
    <CompatibleVersions>1.2,2.0</CompatibleVersions>  
  </Properties>  
  </Dependencies>  
  <InGameActions>  
    <ReplaceUIScript id="ReplaceUI_TopPanel_XP2FFH" criteria="Expansion2">  
	    <Properties>  
	        <LoadOrder>1105</LoadOrder>  
	        <LuaContext>TopPanel</LuaContext>  
	        <LuaReplace>My_TopPanel_XP2.lua</LuaReplace>  
	    </Properties>  
	</ReplaceUIScript>
  </InGameActions>  
  <Files>  
	<File>My_TopPanel_XP2.lua</File>
  </Files>  
</Mod>


```

And this is My_TopPanel_XP2.lua:
```lua
include("TopPanel")  
function RefreshYields()  
    local ePlayer      = Game.GetLocalPlayer();  
    local localPlayer  = nil;  
    if ePlayer ~= -1 then  
       localPlayer = Players[ePlayer];  
       if localPlayer == nil then  
          return;  
       end  
    else
        return;  
    end  
  
    -- unrelated content im cutting for clarity....  
  
    ---- GOLD ----  
    if GameCapabilities.HasCapability("CAPABILITY_GOLD") and GameCapabilities.HasCapability("CAPABILITY_DISPLAY_TOP_PANEL_YIELDS") then  
       m_GoldYieldButton = m_GoldYieldButton or m_YieldButtonDoubleManager:GetInstance();  
       local playerTreasury:table = localPlayer:GetTreasury();  
       local dist_maintenance = localPlayer:GetProperty('city_distance_maintenance') or 0;  
       local num_maintenance = localPlayer:GetProperty('city_num_maintenance') or 0;  
       local unit_maintenance = localPlayer:GetProperty('UnitMaintenance') or 0;  
       local away_unit_maintenance = localPlayer:GetProperty('AwayUnitSupport') or 0;  
       local goldYield       :number = playerTreasury:GetGoldYield() - playerTreasury:GetTotalMaintenance() - num_maintenance - dist_maintenance - unit_maintenance - away_unit_maintenance;  
       local goldBalance  :number = math.floor(playerTreasury:GetGoldBalance());  
       m_GoldYieldButton.YieldBalance:SetText( Locale.ToNumber(goldBalance, "#,###.#") );  
       m_GoldYieldButton.YieldBalance:SetColorByName("ResGoldLabelCS");  
       m_GoldYieldButton.YieldPerTurn:SetText( FormatValuePerTurn(goldYield) );  
       m_GoldYieldButton.YieldIconString:SetText("[ICON_GoldLarge]");  
       m_GoldYieldButton.YieldPerTurn:SetColorByName("ResGoldLabelCS");  
  
       m_GoldYieldButton.YieldBacking:SetToolTipString( GetGoldTooltip() );  
       m_GoldYieldButton.YieldBacking:SetColorByName("ResGoldLabelCS");  
       m_GoldYieldButton.YieldButtonStack:CalculateSize();  
    end  
  
    Controls.YieldStack:CalculateSize();  
    Controls.StaticInfoStack:CalculateSize();  
    Controls.InfoStack:CalculateSize();  
  
    Controls.YieldStack:RegisterSizeChanged( RefreshResources );  
    Controls.StaticInfoStack:RegisterSizeChanged( RefreshResources );  
end
```

This takes an existing UI element, the TopPanel, and an existing function it has, RefreshYields, and changes it. What it does is:
- Replaces the existing TopPanel with this new script, from the .modinfo.
- Gets the older TopPanel file from `include("TopPanel")` which gets all the functions and variables contained within that older file.
- Redefines the function RefreshYields, which is used in that file in other places (and is likely hooked into an Event)

The advantage of this is that we preserve all the functions and variables of the old file, bar the ones we change. So say if Firaxis made changes to this file, we would see those changes. It also minimises our change of including a typo and bricking the whole thing. Less lines of code means less maintenance which means less stress. DRY, or Do Not Repeat Yourself is a common programming motto for this reason.

A pain of this method is that we cannot do multiple layers of inheritance. If someone inherits the original Firaxis file, make some changes, then my mod tries to inherit, it will get the original Firaxis file without that other modders changes. As a result, a downstream modder like myself would need to make a patch specifically checking that that mod was installed and have a custom version, which becomes a huge pain when many mods are changing a file.

## Overwriting

There are some times where you cannot successfully inherit a file and must redefine the entire file. You still use the ReplaceUIScript Action, but don't bother with the include. Why might you do that? Because *include()* doesn't allow access to local variables defined within the file that was included. So for example the file `UnitPanel` has this line:
```lua
local m_standardActionsIM = InstanceManager:new( "UnitActionInstance",         "UnitActionButton", Controls.StandardActionsStack );
```
If any file uses `Include("UnitPanel")`, *m_standardActionsIM* would be nil. Now imagine you are wanting to change a function that would use *m_standardActionsIM*. It would be undefined in your own file, but is currently being used in Firaxis' file. Redefining it in your file wouldn't work, as the other stack will contain information thats being used to drive the UI in other functions, so you would just end up with two independent copies both acting on the UI. And there is absolutely no way of getting an Instance Manager in the way you can look up *ContextPtr:LookUpControl()*. So the only real solution is replicate the entire file and just replace it without *Include()*.

It may be possible for an enterprising modder to build a framework to access items like InstanceManager by redefining InstanceManager to distribute pointers to each Instance in ExposedMembers, but no such thing exists yet.

[[TODO]]: Explain why you would use ImportFiles over ReplaceUIScript.