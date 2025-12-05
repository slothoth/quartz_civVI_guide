In earlier sections we covered how you can change the yields on a building, the Monument. But what if you wanted the Monument to only grant extra yields if you were a certain civ, or under other conditions, not just all the time, in other words, dynamically. In that case, you don't want to edit the yields directly, you want to use a Modifier. Modifiers are a system that are implemented in the Database using SQL, but are used more like coding blocks by the game engine.
# Modifiers
You can think of a modifier as a little program that the game uses to grant additional effects. Modifiers always consist of:
- an owner that the modifier attaches to, like a specific leader
- A group of all the things the modifier should affect, known as a Collection (this could be the player's cities, or their units, or each tile). This can also be referred to as the Subject of the Modifier.
- An Effect that the modifier causes, like granting Science yield to a city.
The modifier will then iterate over each item in the collection, granting the Effect to the item. There are other toggles and switches you can adjust for more complicated behaviour, which we will get to later.

## Simple Example

Lets do an example using that science yield. We are going to make it so the leader Trajan gets +2 science on each of his cities. 

To do this, we need entries in 5 tables. I'll just briefly list what we need, and then I'll explain how I learnt what to put and where.
*DynamicModifiers* is where you define the collection, and effect of a ModifierType. A ModifierType is just a combination of an Effect and Collection. We then need to use that ModifierType to make an instance of a Modifier in the *Modifiers* table. We also need to define the ModifierType in the Types table:

```sql
INSERT INTO DynamicModifiers(ModifierType, CollectionType, EffectType) VALUES  
('MOD_TRAJAN_YIELD_CITIES_TYPE', 'COLLECTION_PLAYER_CITIES', 'EFFECT_ADJUST_CITY_YIELD_CHANGE');  
  
INSERT INTO Types(Type, Kind) VALUES  
('MOD_TRAJAN_YIELD_CITIES_TYPE', 'KIND_MODIFIER');  
  
INSERT INTO Modifiers(ModifierId, ModifierType) VALUES  
('TEST_MODIFIER_TRAJAN_YIELD_CITIES', 'MOD_TRAJAN_YIELD_CITIES_TYPE');  
```

Now we need to specify some values we can customise for this effect. Since this effect can grant any yield, and any amount, we need to specify those values:

```sql
INSERT INTO ModifierArguments(ModifierId, Name, Value) VALUES ('TEST_MODIFIER_TRAJAN_YIELD_CITIES', 'YieldType', 'YIELD_SCIENCE'),  
('TEST_MODIFIER_TRAJAN_YIELD_CITIES', 'Amount', '1');
```

Lastly, we need to attach the modifier to somewhere, in this case, a Trait, which is something that is given to any player who is playing Trajan:
```sql
INSERT INTO TraitModifiers(TraitType, ModifierId) VALUES  
('TRAJANS_COLUMN_TRAIT', 'TEST_MODIFIER_TRAJAN_YIELD_CITIES');  
```

How did I know what values to use? First off, I searched the database copy I have for any entry that had the text EFFECT and YIELD. That then showed me several existing entries in the *DynamicModifiers* table that added yields and modifiers. Just by reading the names of the effects, I was able to see that '**EFFECT_ADJUST_CITY_YIELD_CHANGE**' would be the one I wanted. To double check, I then searched for the modifier that used that DynamicModifier, '**URBAN_PLANNING_ALLCITYPRODUCTION**'. I then saw it was attached to the Policy Urban Planning, which I then looked up on the wiki to see it grants +1 production in all the players cities. Exactly what i needed.

I know that the Policy attachment point is the same type of owner as the Trait attachment point from my handy index ([[Modifier Attachment Points]]), so this is suitable. Now you will notice the table ModifierArguments specifies certain name:value pairs for the modifier. These are often very different depending on which Effect is used, so its important I use the right ones. For reference, I could then search for the ModifierArguments entries with the ModifierId as '**URBAN_PLANNING_ALLCITYPRODUCTION**', but I happen to have a handy [[ModifierArgument Index|index]] I built of all the used terms for a given EffectType, so I can see that this Effect requires two entries, one specifying the type of yield, in this case, YIELD_SCIENCE, and the amount of yield to give, in this case, 2. Note that some EffectTypes have default values, so you can skip adding the Arguments.

Lastly, how did I know which Trait Trajan had? Well luckily it had his name on it, but that isnt guaranteed. Traits are attached to leaders in the *LeaderTraits* table, so we can find rows with **LEADER_TRAJAN**, such as **TRAJANS_COLUMN_TRAIT**.

One thing you can do is reuse existing ModifierTypes defined by Firaxis, if they have the collection and effectType you want. There are some pitfalls with that however, as it can mean your mod may require the DLC that defined that entry, which you otherwise wouldn't need, as all effects are available as long as you have the Gathering Storm and Rise and Fall expansions. Personally I just make my own DynamicModifiers entry.

## Requirement Example
Sometimes you want more complicated behaviour. Lets say we want it so Trajan only gets that +2 science if the city has a Granary and the city is on Plains terrain. This is where Requirements come in. We can specify a Requirement that checks if the city has a Granary, and another that checks if the city is on Plains.
First we make an entry on the Requirements table.

```sql
INSERT INTO Requirements(RequirementId, RequirementType) VALUES  
('REQUIREMENT_CITY_HAS_GRANARY', 'REQUIREMENT_CITY_HAS_BUILDING');  
  
INSERT INTO RequirementArguments(RequirementId, Name, Value) VALUES  
('REQUIREMENT_CITY_HAS_GRANARY', 'BuildingType', 'BUILDING_GRANARY');

INSERT INTO Requirements(RequirementId, RequirementType) VALUES  
('REQUIREMENT_CITY_ON_PLAINS', 'REQUIREMENT_PLOT_TERRAIN_TYPE_MATCHES');  
  
INSERT INTO RequirementArguments(RequirementId, Name, Value) VALUES  
('REQUIREMENT_CITY_ON_PLAINS', 'TerrainType', 'TERRAIN_PLAINS');
```

You can see this follows a similar style to the *Modifiers* and *ModifierArguments* table. There are some differences however. RequirementTypes don't need a definition in a table like DynamicModifiers, they are predefined, like EffectTypes. 

Ok, now we need to take these requirements, and package them onto the Modifier we made earlier.

```sql
INSERT INTO RequirementSets(RequirementSetId, RequirementSetType) VALUES  
('CITY_HAS_GRANARY_AND_PLAINS_REQS', 'REQUIREMENTSET_TEST_ALL');  
  
INSERT INTO RequirementSetRequirements(RequirementSetId, RequirementId) VALUES  
('CITY_HAS_GRANARY_AND_PLAINS_REQS', 'REQUIREMENT_CITY_HAS_GRANARY'),
('CITY_HAS_GRANARY_AND_PLAINS_REQS', 'REQUIREMENT_CITY_ON_PLAINS');

INSERT INTO Modifiers(ModifierId, ModifierType, SubjectRequirementSetId) VALUES  
('TEST_MODIFIER_TRAJAN_YIELD_CITIES', 'MOD_TRAJAN_YIELD_CITIES_TYPE', 'CITY_HAS_GRANARY_AND_PLAINS_REQS');
```

You can see we are adding these Requirements to a object called **CITY_HAS_GRANARY_AND_PLAINS_REQS**, and then putting that object on the column *SubjectRequirementSetId*. This is whats called a RequirementSet, a set just means a list of items where all of them are unique. The set also has a type, RequirementSetType. This can be either **REQUIREMENTSET_TEST_ALL** or **REQUIREMENTSET_TEST_ANY**. You can think of these as being an OR/AND terminology. A modifier with a RequirementSet with TEST_ALL needs every requirement in the set to be satisfied in order to work, whereas one with TEST_ANY would work if any of the requirements were satisfied. For example, if we changed our example to **REQUIREMENTSET_TEST_ANY**, then any city with either a granary or on plains would get +2 science.

You may also notice that we are referencing a Subject in *SubjectRequirementSetId*. As we were saying in the Modifier section, a subject is all the things that a given modifier is acting on, which we specify using our collection, which was **COLLECTION_PLAYER_CITIES**. We need to make sure that we are using requirements that make sense for the items in the subject collection. For example, lets say a naive modder wanted to make it so instead the city got +2 science if a melee unit was stationed on the city. They might think they could swap out the original requirement for another using **REQUIREMENT_UNIT_IS_MELEE**, but this would not work. The city collection would not have the context to know about information on a unit on the city. As a result, the requirement would never work. A caveat to this is that some types of objects do have context about certain other objects. A keen observer might note in our example that one RequirementType uses **REQUIREMENT_CITY_HAS_BUILDING**, which makes sense for that collection, but the other doesn't mention a City at all, **REQUIREMENT_PLOT_TERRAIN_TYPE_MATCHES**. The City object has information about the Plot of the City Centre, and so that requirement can still be used. This is mostly commonly used for checking things like the Plot of a Unit, or information about the Player that the Unit or City belongs to, like you could also make this modifier only work after the player had researched Bronze Working, with the RequirementType **REQUIREMENT_PLAYER_HAS_TECHNOLOGY**.

Another way you could check the Player object for this Modifier would be using a RequirementSet pointed at a different column, *OwnerRequirementSetId*:

```sql
INSERT INTO Requirements(RequirementId, RequirementType) VALUES  
('REQUIRES_PLAYER_HAS_BRONZE_WORKING', 'REQUIREMENT_PLAYER_HAS_TECHNOLOGY');  
  
INSERT INTO RequirementArguments(RequirementId, Name, Value) VALUES  
('REQUIRES_PLAYER_HAS_BRONZE_WORKING', 'TechnologyType', 'TECH_FLIGHT');

INSERT INTO RequirementSets(RequirementSetId, RequirementSetType) VALUES  
('PLAYER_HAS_BRONZE_WORKING_REQS', 'REQUIREMENTSET_TEST_ALL');  
  
INSERT INTO RequirementSetRequirements(RequirementSetId, RequirementId) VALUES  
('PLAYER_HAS_BRONZE_WORKING_REQS', 'REQUIRES_PLAYER_HAS_BRONZE_WORKING');

INSERT INTO Modifiers(ModifierId, ModifierType, OwnerRequirementSetId) VALUES  
('TEST_MODIFIER_TRAJAN_YIELD_CITIES', 'MOD_TRAJAN_YIELD_CITIES_TYPE', 'PLAYER_HAS_BRONZE_WORKING_REQS');
```

Rather than checking the Subject of the modifier, i.e. each of the player's cities, instead this would check the Owner, which in this case would be the Player object. You will notice for the most part people just use *SubjectRequirementSetId* as most of the time, you will have the context on the Subject objects. There are also rare requirementTypes where checking the Owner requirement can crash the game. Note that if you have both a *SubjectRequirementSetId* and *OwnerRequirementSetId*, both would need to be satisfied.


## Optional Toggles
A cursory look at the Modifiers table reveals a lot more columns than the ones I mentioned:

- *Permanent* means just that, that the modifier, once turned on, is always on, even if the requirement later on is not satisfied. If its not mentioned, its by default off, as 0.

- *RunOnce* is used for effects that you only want to apply once. Our example of granting science yields to cities with Granaries, thats an effect we want to be persistent, across all future turns. But something like Oxford University granting two Technologies, we would only want that to happen once, so it has *RunOnce* set to 1.

- *SubjectStackLimit*. These refer to how instances of this exact modifier can each affect the subject. An example of this would be the negative combat strength caused by Varu to adjacent enemy units. It would be too good if you could reduce that combat strength more than once, so *SubjectStackLimit* is set to 1.


There are also columns that act in a similar way for the *Requirements* table:
- *Inverse*: This inverts the requirement satisfaction. Rather than turn on if the requirement is satisfied, instead it turns on only when the requirement is not satisfied.

The [[Glossary]] will specify those not mentioned here as they are infrequently used.

## ModifierAttachment Nesting

In some instances, you might need to go beyond just an Owner and a Subject. Lets say we want Trajan to grant +2 Science to each city for each Knight the player has:
```sql
INSERT INTO DynamicModifiers(ModifierType, CollectionType, EffectType) VALUES ('SLTH_MODIFIER_PLAYER_UNITS_ATTACH_MODIFIER', 'COLLECTION_PLAYER_UNITS', 'EFFECT_ATTACH_MODIFIER');

INSERT INTO Modifiers(ModifierId, ModifierType, SubjectRequirementSetId) VALUES ('ATTACH_SCIENCE_CITIES_MODIFIER', 'SLTH_MODIFIER_PLAYER_UNITS_ATTACH_MODIFIER', 'SUBREQSET_UNIT_IS_KNIGHT');

INSERT INTO ModifierArguments(ModifierId, Name, Value) VALUES  
('ATTACH_SCIENCE_CITIES_MODIFIER', 'ModifierId', 'SCIENCE_CITIES_MODIFIER'),  
('SCIENCE_CITIES_MODIFIER', 'YieldType', 'YIELD_SCIENCE'),
('SCIENCE_CITIES_MODIFIER', 'Amount', 2);

INSERT INTO Requirements(RequirementId, RequirementType) VALUES ('SLTH_UNIT_IS_KNIGHT', 'REQUIREMENT_UNIT_TAG_MATCHES');  
INSERT INTO RequirementArguments(RequirementId, Name, Value) VALUES  
('SLTH_UNIT_IS_KNIGHT', 'UnitType', 'UNIT_KNIGHT');  
  
INSERT INTO RequirementSets(RequirementSetId, RequirementSetType) VALUES ('SUBREQSET_UNIT_IS_KNIGHT', 'REQUIREMENTSET_TEST_ALL');  
INSERT INTO RequirementSetRequirements(RequirementSetId, RequirementId) VALUES  
('SUBREQSET_UNIT_IS_KNIGHT', 'SLTH_UNIT_IS_KNIGHT');

INSERT INTO TraitModifiers(TraitType, ModifierId) VALUES  
('TRAJANS_COLUMN_TRAIT', 'ATTACH_SCIENCE_CITIES_MODIFIER');  
```

Interestingly, we can see the chain of Owner and Subject more clearly here. **ATTACH_SCIENCE_CITIES_MODIFIER**:
- Owner: Player object
- Subject: Unit object
**SCIENCE_CITIES_MODIFIER** (when attached via **ATTACH_SCIENCE_CITIES_MODIFIER**):
- Owner: the Unit object from **ATTACH_SCIENCE_CITIES_MODIFIER**
- Subject: City object

## ModifierStrings
Some Modifiers have effects that a player can see in tooltip strings. A classic one would be combat strength modifiers, which each have a string describing what the modifier is doing. So a player can see, oh I'm getting +5 from attacking into forested tiles for example:
```sql
INSERT INTO ModifierStrings(ModifierId, Context, Text) VALUES  
('STANDARD_DIPLOMATIC_PLAYER_HATE', 'Sample', 'LOC_DIPLO_EVIL_HATES_GOOD'),
('MINOR_BONUS_AGAINST_MOUNTED', 'Preview', 'LOC_PROMOTION_DRILL4_DESCRIPTION');
```
We can see that you just pass in a modifierId, and then say the text that it uses, and a Context that its used in. There are different contexts here, Sample is used to describe tooltips for why a AI player has a relationship adjustment, and Preview is for the combat preview.
## Nested Requirements

What if we wanted to complicate things further? Lets say we wanted +2 science if the city had a Granary, or had a Sewer and was on Plains. Doing a simple RequirementSet with either ANY or ALL as it needs a combination of OR and AND. We can solve this problem by combining the OR requirements into one single requirement, and that requirement and the other AND requirement are in a TEST_ALL. 
```sql
INSERT INTO RequirementSets(RequirementSetId, RequirementSetType) VALUES  
('CITY_HAS_GRANARY_AND_PLAINS_REQS', 'REQUIREMENTSET_TEST_ANY');  

INSERT INTO Requirements(RequirementId, RequirementType) VALUES ('HAS_SEWER_AND_PLAINS_SATISFIED', 'REQUIREMENT_REQUIREMENTSET_IS_MET');

INSERT INTO RequirementArguments(RequirementId, Name, Value) VALUES  
('HAS_SEWER_AND_PLAINS_SATISFIED', 'RequirementSetId', 'CITY_HAS_GRANARY_AND_PLAINS_REQS');

INSERT INTO Requirements(RequirementId, RequirementType) VALUES  
('REQUIREMENT_CITY_HAS_SEWER', 'REQUIREMENT_CITY_HAS_BUILDING');  
  
INSERT INTO RequirementArguments(RequirementId, Name, Value) VALUES  
('REQUIREMENT_CITY_HAS_SEWER', 'BuildingType', 'BUILDING_SEWER');

INSERT INTO RequirementSets(RequirementSetId, RequirementSetType) VALUES  
('CITY_HAS_GRANARY_AND_PLAINS_OR_SEWER_REQS', 'REQUIREMENTSET_TEST_ALL');

INSERT INTO RequirementSetRequirements(RequirementSetId, RequirementId) VALUES  
('CITY_HAS_GRANARY_AND_PLAINS_OR_SEWER_REQS', 'HAS_SEWER_AND_PLAINS_SATISFIED'),
('CITY_HAS_GRANARY_AND_PLAINS_OR_SEWER_REQS', 'REQUIREMENT_CITY_HAS_SEWER');

INSERT INTO Modifiers(ModifierId, ModifierType, SubjectRequirementSetId) VALUES  
('TEST_MODIFIER_TRAJAN_YIELD_CITIES', 'MOD_TRAJAN_YIELD_CITIES_TYPE', 'CITY_HAS_GRANARY_AND_PLAINS_OR_SEWER_REQS');
```

This **REQUIREMENT_REQUIREMENTSET_IS_MET** lets us combine these requirementSets and control it like a single Requirement.

## Alternate Collection Checking
In some very exotic cases, you don't want to check the object of the Owner, or the object of the Subject. In these odd instances, you are wanting to check a different collection associated with the Subject/Object. Lets make it so instead, Trajan only gets +2 science on cities if he has at least 4 Knights. To do this, we need to query items in **COLLECTION_PLAYER_UNITS** to see if the player has that many Knights, so we use **REQUIREMENT_COLLECTION_COUNT_ATLEAST**. 
This accepts an argument for a Collection to query, and a RequirementSetId, and a Count. Essentially what its doing is checking every member of that collection, seeing if that item satisfies the given RequirementSetId, and if so, counting it. If the total count of items that satisfy it is 4 or more, the requirement is satisfied.

There is other similar collection count requirements, for exactly equals, less than and so on.

```sql
INSERT INTO Requirements(RequirementId, RequirementType) VALUES  
('SLTH_CHECK_PLAYER_HAS_AT_LEAST_4_KNIGHTS_REQ', 'REQUIREMENT_COLLECTION_COUNT_ATLEAST');  
  
INSERT INTO RequirementArguments(RequirementId, Name, Value) VALUES  
('SLTH_CHECK_PLAYER_HAS_AT_LEAST_4_KNIGHTS_REQ', 'CollectionType', 'COLLECTION_PLAYER_UNITS'),  
('SLTH_CHECK_PLAYER_HAS_AT_LEAST_4_KNIGHTS_REQ', 'Count', '4'),  
('SLTH_CHECK_PLAYER_HAS_AT_LEAST_4_KNIGHTS_REQ', 'RequirementSetId', 'SUBREQSET_UNIT_IS_KNIGHT');

-- SUBREQSET_UNIT_IS_KNIGHT defined in ModifierAttachment Nesting
  
INSERT INTO RequirementSetRequirements(RequirementSetId, RequirementId) VALUES  
('PLAYER_HAS_4_KNIGHTS_REQS', 'SLTH_CHECK_PLAYER_HAS_AT_LEAST_4_KNIGHTS_REQ');  
INSERT INTO RequirementSets(RequirementSetId, RequirementSetType) VALUES  
('PLAYER_HAS_4_KNIGHTS_REQS', 'REQUIREMENTSET_TEST_ALL');  

INSERT INTO Modifiers(ModifierId, ModifierType, SubjectRequirementSetId) VALUES  
('TEST_MODIFIER_TRAJAN_YIELD_CITIES', 'MOD_TRAJAN_YIELD_CITIES_TYPE', 'PLAYER_HAS_4_KNIGHTS_REQS');
```


# Workflows and Debugging
When making a modifier, my advice is to build it out iteratively. So often, I see modders build themselves a complicated set of things, then test it, only for it to fail, and them not to understand why. My advice is: make your modifier initially without any requirements, and make sure it works, then slap on the requirements. If it fails to work then, you know the requirement is the problem, and can work on that. Similarly, keep your testing version simple. Rather than make it be a modifier on some late game wonder, at first just put it on the Monument. That way, you can boot up the game, buy a Monument, and see if it works.