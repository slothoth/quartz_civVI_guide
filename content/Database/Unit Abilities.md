Unit abilities are a bit of a pain to set up, so here is a quick explainer. Note: an ability here doesn't refer to an active, it refers to an effect the unit has. For example, the Aztec Eagle Warrior being able to capture units is an ability.

There are two main classes of Ability: permanent abilities that a type of unit always has, like the Eagle Warrior, and dynamically allocated Abilities that are activated via a modifier. First lets look at a permanent ability that makes it so settlers have 3 more movement when the player has no cities, with the details of the Modifier omitted:

```sql
INSERT INTO Types(Type, Kind) VALUES  
('ABILITY_FIRST_SETTLER_SIGHT_MOVE', 'KIND_ABILITY');

INSERT INTO UnitAbilities(UnitAbilityType, Name, Description, Inactive, Permanent) VALUES  
('ABILITY_FIRST_SETTLER_SIGHT_MOVE', 'LOC_NAME', 'LOC_DESC', '0', '1');
  
INSERT INTO UnitAbilityModifiers(UnitAbilityType, ModifierId) VALUES  
('ABILITY_FIRST_SETTLER_SIGHT_MOVE', 'MODIFIER_3_MORE_MOVES_SETTLER');

INSERT INTO Tags(Tag, Vocabulary) VALUES  
('CLASS_MY_SETTLER', 'ABILITY_CLASS');

INSERT INTO TypeTags(Type, Tag) VALUES  
('UNIT_SETTLER', 'CLASS_MY_SETTLER'),
('ABILITY_FIRST_SETTLER_SIGHT_MOVE', 'CLASS_MY_SETTLER');
```

First, an Ability is defined in *UnitAbilities*, with *Inactive* set to 0, and *Permanent* set to 1. We then attach a Modifier to that Ability in *UnitAbilityModifiers*. Then we associate the Ability and the Unit through the TypeTags system. We define a tag of category **ABILITY_CLASS**, then we associate the Unit with that Tag using TypeTags, and associate the Ability with the Tag in the same way. Settler units should now have this ability.

Now lets look at a dynamically allocated ability. This is for a civ who gets a combat strength bonus on all their Recon units like scouts:

```sql 
INSERT INTO UnitAbilities(UnitAbilityType, Name, Description, Inactive, Permanent) VALUES  
('SLTH_ABILITY_SINISTER', 'LOC_SLTH_ABILITY_SINISTER_NAME', 'LOC_SLTH_ABILITY_SINISTER_DESCRIPTION', '1', '1');  

INSERT INTO Types(Type, Kind) VALUES
('SLTH_ABILITY_SINISTER', 'KIND_ABILITY');

INSERT INTO TypeTags(Type, Tag) VALUES  
('SLTH_ABILITY_SINISTER', 'CLASS_RECON');

INSERT INTO UnitAbilityModifiers(UnitAbilityType, ModifierId) VALUES  
('SLTH_ABILITY_SINISTER', 'MODIFIER_SLTH_ABILITY_SINISTER');

INSERT INTO Modifiers(ModifierId, ModifierType) VALUES  
('MODIFIER_SLTH_ABILITY_SINISTER', 'MODIFIER_UNIT_ADJUST_COMBAT_STRENGTH');

INSERT INTO ModifierArguments(ModifierId, Name, Value) VALUES  
('MODIFIER_SLTH_ABILITY_SINISTER', 'Amount', '5');
```

Note the key difference in the UnitAbilities section: Inactive and Permanent are both set to 1. The ability is now dormant on all units with typeTag entries with CLASS_RECON (omitted for clarity), and we can dynamically activate it with another modifier:

```sql
INSERT INTO TraitModifiers(TraitType, ModifierId) VALUES  
('SLTH_TRAIT_CIVILIZATION_SVARTALFAR', 'TRAIT_SLTH_ABILITY_SINISTER');

INSERT INTO Modifiers(ModifierId, ModifierType) VALUES  
('TRAIT_SLTH_ABILITY_SINISTER', 'MODIFIER_PLAYER_UNITS_GRANT_ABILITY'); 

-- NB: MODIFIER_PLAYER_UNITS_GRANT_ABILITY uses COLLECTION_PLAYER_UNITS and EFFECT_GRANT_ABILITY
  
INSERT INTO ModifierArguments(ModifierId, Name, Value) VALUES  
('TRAIT_SLTH_ABILITY_SINISTER', 'AbilityType', 'SLTH_ABILITY_SINISTER'); 
```

Many modders fall into the pitfall of not including typetag association. There are useful existing Ability_Classes implemented by Firaxis you can piggyback off of, such as **CLASS_LANDCIVILIAN** or **CLASS_RELIGIOUS**. An interesting one is **CLASS_ALL_UNITS**, which applies to every unit, without TypeTag entries.