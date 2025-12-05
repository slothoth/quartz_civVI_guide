If you want to skip the tutorial, you can follow this flowchart:
![[flow_chart_errors.png]]

When modding, you will often make mistakes when writing your code. Part of the development process is being able to interpret the logs the game spits out to understand why it is has failed. There are two relevant files that the game creates when you load into a game, Database.log and Modding.log. 

These are located in your logging folder, which should be replacing USERNAME with your username:
> C:/Users/$USERNAME$/Documents/my games/Sid Meier's Civilization VI/Mods
 and on MacOS at:
  >/Users/$USERNAME$/Library/Application Support/Sid Meier's Civilization VI/Firaxis Games/Sid Meier's Civilization VI/Logs/Modding.log

A note: There was an old location where these files used to be logged. If you are finding that the logs are not updating, when you close and reopen the game, you are likely looking at the old logging files.


Modding.log details all of the mods that are set to be loaded, and then logs all of the files in order of execution. If one fails, it will error, allowing you to know which file is the problem. Modding.log is a huge file, as it needs to specify all the DLC and all the files, so its something you should be text searching. Heres an excerpt from our modded example [[Hello World. The Simplest Mod]], specifying what Actions, like this_is_just_cosmetic are being applied.

```python
[3731152.640] dead420b-eef2-48da-b71f-2f13b34e6e42 (The Name of your Mod at the Additional Content screen)  
[3731152.640]  * this_is_just_cosmetic (UpdateDatabase)
```
The square bracketed number is a timestamp, specifying the time that this was logged. This can be useful when referencing in a different file, like Database.log, so you can see what is happening at the time of an error in that other file.

As before, each line is specifying an Action, and the round brackets are specifying which kind of action is being taken. The name of the action, like this_is_just_cosmetic, is the id of the action in the .modinfo file. This is why its nice to have a unique name, as theres nothing stopping several modders having the same action id, and then it being very difficult to interpret the Modding.log. Okay, now lets move to the next section, when this action is being applied at runtime.

```python
[3731163.640] Applying Component - this_is_just_cosmetic (UpdateDatabase)  
[3731163.640] UpdateDatabase - Loading main.sql
```
We can see the individual files within each action, and them being applied. The value of this is when something goes wrong, and a given file is wrong, you can find the source file of the error.

The corresponding Database.log file handles the specifics of how a given file errors. For database modding, the sections we are interested will read '\[Gameplay\]'. There are other databases, for different language translations, for defining how Icons work, or Colours, or the Frontend database (referred to as Configuration), but for this purpose we will ignore them. Importantly, there can be failures or errors in those databases, and the game will still be able to load. So don't be surprised if there are DLC or mod errors in those sections.

```python
[3731164.640] [Gameplay]: Validating Foreign Key Constraints...  
[3731164.640] [Gameplay]: Passed Validation.
```

Lets amend that main.sql file so that it errors, and we can see how the log changes.

## Constraint Failure

Lets add a statement in the middle of the file (note that -- allows you to write comments, basically notes that a human can read, but the computer ignores):
```sql
UPDATE Buildings SET Name = 'Congratulations' WHERE BuildingType='BUILDING_MONUMENT';  

-- ADDED
INSERT INTO Building_YieldChanges(BuildingType, YieldType, YieldChange) VALUES  
('BUILDING_MONUMENT', 'YIELD_CULTURE', 5);  
-- ADDED END

UPDATE Building_YieldChanges SET YieldChange = 10 WHERE BuildingType='BUILDING_MONUMENT' AND YieldType = 'YIELD_CULTURE';  
INSERT INTO Building_YieldChanges(BuildingType, YieldType, YieldChange) VALUES  
('BUILDING_MONUMENT', 'YIELD_FAITH', 5);
```

This should error, as it tries to make a row in Building_YieldChanges that has the same primary key as an existing row. If we check the database.log, we will see this text:
```python
[3732050.640] [Gameplay] ERROR: UNIQUE constraint failed: Building_YieldChanges.BuildingType, Building_YieldChanges.YieldType  
[3732050.640] [Gameplay] ERROR: UNIQUE constraint failed: Building_YieldChanges.BuildingType, Building_YieldChanges.YieldType  
[3732050.640] [Gameplay]: Validating Foreign Key Constraints...  
[3732050.640] [Gameplay]: Passed Validation.
```

And if we check the modding.log we can see which exact file caused this.
```python
[3732050.640] Applying Component - this_is_just_cosmetic (UpdateDatabase)  
[3732050.640] UpdateDatabase - Loading main.sql  
[3732050.640] Warning: UpdateDatabase - Error Loading SQL.
```
In this toy example, it might seem not needed, but imagine if you had 50 files and just had the database.log. It would be very difficult to know which file had failed.

This error should be explanatory in Database.log. What its saying is you are trying to write a command that leads to a faulty table Building_YieldChanges, where there are now two rows which have the same unique combination of BuildingType and YieldType. It says it twice, because presumably it checks every row, so sees the original row has a duplicate, and so does the new one, each other.

 Interestingly, this will still let us load into the game, what is called a "silent error". The way the game executes the file is top down, line by line. So the previous lines about changing the name of the monument will still go through, but the faith addition will not.
 ![[error_monument_database.png]]
Compared to the original:
![[correct_monument_database.png]]
If we didn't know the source of the error, we could track it down by using that information, finding out where the last change in the file successfully went through.

## Syntax Error
While that example showed what happened when you caused a logic failure, there are other possible ways to error as well. If you wrote your SQL wrong, the computer cannot parse(read) it correctly, and so it just shuts down.

```sql
UPDATE Buildings SET Name = 'Congratulations' WHERE BuildingType='BUILDING_MONUMENT';  
  
INSERT INTO Building_YieldChanges(BuildingType, YieldType, YieldChange) VALUES  
('BUILDING_MONUMENT', 'YIELD_FAITH', 5),  
('BUILDING_MONUMENT', 'YIELD_GOLD', 5),;
```
Can you see the problem here? This is a common case of copying and pasting lines like "('BUILDING_MONUMENT', 'YIELD_FAITH', 5), ", but the user kept the spare comma at the end, even though its the last entry.

This leads to the game still loading, with the same Modding.log error, but this Database.log error:
```python
[3741103.640] [Gameplay] ERROR: near ";": syntax error  
[3741103.640] [Gameplay]: Validating Foreign Key Constraints...  
[3741103.640] [Gameplay]: Passed Validation.
```
I think we'd all agree if we didn't know the source of the error, that the description is very unclear. It doesn't tell us what line the error occurred on, and the text it appears near ";" is a very common character. Sometimes the error logging on Firaxis' side could be better, but this is sadly the world we live in. However we can infer where the problem is the same way we did prior. The changing of the name worked, but the yield changes will not have worked, same as last time, so we can know the problem is immediately after that name change.

## Modinfo errors
Lets reset that main.sql file back to the functioning version. And now lets mess with the .modinfo file. There are 4 likely causes of errors in a modinfo. File omissions, syntax errors, incorrect actions or duplicate mod ids.
### File Omissions
```xml
<?xml version="1.0" encoding="utf-8"?>  
<Mod id="dead420b-eef2-48da-b71f-2f13b34e6e42" version="1">  
  <Properties>  
    <Name>The Name of your Mod at the Additional Content screen</Name>  
    <Description>The long description of your mod when a user clicks on that mod in the Additional Content screen. The Mod id= section is a hexcode UUID (Unique Identifier) that the game uses to determine which mod is which.</Description>  
    <Created>1588793234</Created>  
    <Teaser>This is the short line on the list view of Mods.</Teaser>  
    <Authors>Slothoth</Authors>  
    <CompatibleVersions>1.2,2.0</CompatibleVersions>  
  </Properties>  
  <Dependencies>  
    <Mod id="4873eb62-8ccc-4574-b784-dda455e74e68" title="LOC_EXPANSION2_MOD_TITLE"/>  
  </Dependencies>  
  <InGameActions>  
    <UpdateDatabase id="this_is_just_cosmetic">  
      <Properties>  
        <LoadOrder>50</LoadOrder>  
      </Properties>  
      <File>main.sql</File>  
    </UpdateDatabase>  
  </InGameActions>  
  <Files>  
    <!--File>main.sql</File-->
    <!--This is a comment in XML, so the computer ignores reading it. --> 
    <!--By commenting out the file in the list of Files, our mod will not run--> 
  </Files>  
</Mod>
```
What does this cause?
![[no_effect_monument.png]]
No effect at all. And our Database.log is clean:
```python
[3743637.640] [Gameplay]: Validating Foreign Key Constraints...  
[3743637.640] [Gameplay]: Passed Validation.
```
But if we CTRL-F for the word error in our modding.log:
```python
[3743508.640] Loading Mod - /Users/$USERNAME$/Library/Application Support/Sid Meier's Civilization VI/Sid Meier's Civilization VI/Mods/messing-around/TEST.modinfo  
[3743508.640] ERROR: Invalid file reference in action, did you forgot to add it in <Files>? - main.sql
```
The same error would apply if you misspelled the name of the file in the action, or in the Files section.
### Syntax Errors
Syntax errors can cause different behaviour depending on where the error is in the nested Tags:
```xml
<InGameActions>  
  <UpdateDatabase id="this_is_just_cosmetic>  
    <Properties>  
      <LoadOrder>50</LoadOrder>  
    </Properties>  
    <File>main.sql</File>  
  </UpdateDatabase>  
</InGameActions>
```
Notice how the quotation mark is never resolved on the id. As a result, the action is completely omitted. Interestingly the Mod is still viewable in the Additional content screen and will behave as though loaded, with no errors in Modding.log or Database.log. Having a good XML parser is the main way to combat this, you can see how its highlighted incorrectly in the excerpt. Lets see a incorrectly closed Tag.
```xml
<InGameActions>  
  <UpdateDatabase id="this_is_just_cosmetic">  
    <Properties>  
      <LoadOrder>50</LoadOrder>  
    </Properties>  
    <File>main.sql
    <!-- look above, we never closed the tag-->
  </UpdateDatabase>  
</InGameActions>
```
Similarly, we get no actions happening, but the mod appears.
### Incorrect Actions
This would be a case where you have used the wrong type of action for your file. So for example, you are targeting the frontend database with your gameplay commands file. This would lead to Database.log errors, as the given tables would not exist in that other database.

### Duplicate Mod IDs
The Mod ID (in this case "dead420b-eef2-48da-b71f-2f13b34e6e42") is the unique identifier the game uses to turn the mod on or off, and to know what to add to the game at runtime, when you launch into a save. If you for some reason duplicated your mod, or copied someone elses modinfo and thus mod id, there is undefined behaviour for which version of the .modinfo it will use. This can be a common cause of "i tried X to fix the problem, but it didnt work". Because the game was loading the other unedited version. To stop collisions with having the same modId, you can just generate a new one, or just edit it manually.
# Common Gotchas
- There are errors in Firaxis' own work that will forever show up in your database.log and modding.log. Dont worry about them. These are:
	- Data/RulersOfTheSahara_RemoveData.xml (twice)
	- Data/JuliusCaesar_Districts.xml
	- Data/JuliusCaesar_Units.xml
	- CatherineDeMedici_Modifiers.xml, 
- There are also ongoing changing errors with that carousel thing they added to advertise Civ VII. They are in the Database.log and will have \[Localization\] tag and will have text like LOC_CLICKOUT_26_CAROUSEL_TOOLTIP. They won't cause any problems however.