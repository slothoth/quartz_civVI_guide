# Anatomy of a modinfo
The most basic mod possible is a folder with 2 items; a .modinfo file, and a single file that the .modinfo tells the game to run. The modinfo file is a basic XML, with information the game uses to display it when choosing to turn the mod on ingame, and details what files needed loaded, and in what order, as well as some dependencies:

**test.modinfo:**
```xml
<?xml version="1.0" encoding="utf-8"?>  
<Mod id="dead420b-eef2-48da-b71f-2f13b34e6e42" version="1">  
  <Properties>  
    <Name>The Name of your Mod at the Additional Content screen</Name>  
    <Description>The long description of your mod when a user clicks on that mod in the Additional Content screen. The Mod id= section is a hexcode (0-9 and a-f) UUID (Unique Identifier) that the game uses to determine which mod is which.</Description>  
    <Created>1588793234</Created>  
    <Teaser>This is the short line on the list view on the Additional Content screen.</Teaser>  
    <Authors>Slothoth</Authors>  
    <CompatibleVersions>1.2,2.0</CompatibleVersions>  
  </Properties>  
  </Dependencies>  
  <InGameActions>  
    <UpdateDatabase id="this_iscosmetic_and_used_by_the_modding.log_to_print_the_order_of_actions">  
      <File>main.sql</File>  
    </UpdateDatabase>  
  </InGameActions>  
  <Files>  
    <File>main.sql</File>  
  </Files>  
</Mod>
```

and here is an example file, **main.sql**:
```sql
UPDATE Buildings SET Name = 'Congratulations' WHERE BuildingType='BUILDING_MONUMENT';
```

You can find these files in the attached Documents folder, under Hello World.

What does this mod do? It makes it so the Monument has a different name, called "Congratulations". Astute modders will know that this is a simplification of how to rename something, but we can go into that later, in the [[Names and Descriptions. Localization]].

## XML
XML is a type of document that uses Tags:
```xml
<my_name>This is an XML tag, it uses pointed brackets to define a tag name, and has content inside of it, namely this text, and closes the tag using the same tag name, with a backslash at the front</my_name>
</this_is_also_an_xml_tag_but_its_empty_and_has_nothing_in_it_as_denoted_by_the_backslash>
```
Tags can be nested inside one another as you can see all other tags are nested inside the \<Mod> tag. Tags can also have properties, which you can think of as a labelled dictionary pair. the \<Mod> tag has an id property.
Reading XML, like any programming document, can be a pain without highlighting of different elements of the syntax, like those tags, and can also be easily wrongly formatted by forgetting a bracket or backslash. A wrongly formatted file may not be recognised in part or in whole, and makes debugging a pain. I highly recommend using a code editor when writing your .modinfo file, good choices are available in the [[Tools]] section.

### Actions
Beyond the Properties section, which mostly contains metadata of what your mod is about, or how it displays, or which other mods it depends upon, the main meat of the modinfo file is in the sections referencing Actions. You can see here I have a \<InGameActions\> tag which specifies one of the two contexts its possible to load files, in this case meaning when you've loaded into a game of civ proper, not just at the menu where you can set up a game. That menu is referred to as the FrontEnd, and would instead use \<FrontEndActions\>.

Within that section, is a tag \<UpdateDatabase\> and within that, the one file we are loading inside a \<File\> Tag. UpdateDatabase is a kind of Action, and you can think of Actions as telling the game how to use that file. In this case, we are asking it to use that file to modify the underlying SQL database that the game builds when you start to load into a game, that holds information about things like, the cost of buildings, or their names. Other mods would use a different Tag for things like adding new Lua scripting files, adding new UI files, or adding references to new icons.

Finally, the \<Files\> section is a just a list of all the files that you mentioned in your \<InGameActions\> and \<FrontEndActions\> section. Its annoying, but you do have to relist all those files.

For more advanced options, refer to the appendix section of [[Modinfo Tags]] information once you have properly oriented yourself.

# Loading your mod
The game looks for mods in two locations. One is your steam workshop folder, where mods you download from the Steam Workshop live. The other is your local Mods folder, located on Windows, replacing USERNAME with your username:
> C:/Users/$USERNAME$/Documents/my games/Sid Meier's Civilization VI/Mods
 and on MacOS at:
  >/Users/$USERNAME$/Library/Application Support/Sid Meier's Civilization VI/Sid Meier's Civilization VI/Mods

To test this mod out, just drop the folder Hello World into that location, and launch Civ VI. the mod should then show up in Additional Content. A note is that the game will not register changes to the .modinfo file once you have launched Civ VI, it reads them once on launching, and not again.
![[Mod_Manager_Teaser.png]]

![[Mod_Manager_Description.png]]

All things considered, you should be able to see the Mod in Additional content, enable it, start a game, settle a city, and see the name of the Monument is now "Congratulations". You could also check the Civpedia as soon as you load into the game.
![[correct_monument_database.png]]
![[correct_monument_civpedia.png]]
# Modbuddy and its flaws
To those who have modded before, you may notice I am not talking about the tool Firaxis provides that does a lot of modding stuff, including packaging a .modinfo file for you, called Modbuddy. The reason is I consider it a very poor way to mod. It uses an awkward GUI, the file editing has no syntax highlighting, and its full of features that a novice modder does not need, that will clutter up their experience and confuse them. Modbuddy, and the program inside of it, Asset Editor, are essential when doing any modding that adds art like 3d models or icons to the game, but if you are just doing mods without that, its a welcome step to skip over, for the time being. I myself keep a separate project that I use to package my art files, that is separate from my modding project itself because its such a pain. Modbuddy is also finicky, with different base OS languages like French, and is not available on other operating systems like MacOS.