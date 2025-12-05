# Agendas
Most all AI behaviour is organised by being connected to an Agenda. A AI player can be given an agenda in *HistoricalAgendas*, and additional agendas also distributed randomly at the start of the game. Agenda can link modifiers, affect how much the AI values things, known as Biases, and even have associated Behaviours, which specify actions to take, like marshalling forces to clear a barbarian camp, or siege a city.
# Diplomacy Modifiers

Diplomacy modifiers are an odd thing, and behave quite differently than other modifiers. Here is an example from my own mod, where I have a Lua system checking the "morality" of a given player, by assigning a Plot Property to my capital (see the [[Modifier Bridging]] section for more detail). Players with opposite moralities dislike eachother, and this section implements a player with the Evil stance will dislike players with the Good stance.

```sql
INSERT INTO TraitModifiers(TraitType, ModifierId) VALUES  
('TRAIT_LEADER_MAJOR_CIV', 'STD_DIPLO_EVIL_HATES_GOOD_INTERACTION');

INSERT INTO Modifiers(ModifierId, ModifierType, OwnerRequirementSetId, SubjectRequirementSetId) VALUES  
('STD_DIPLO_EVIL_HATES_GOOD_INTERACTION', 'MODIFIER_PLAYER_DIPLOMACY_SIMPLE_MODIFIER', 'PLAYER_IS_EVIL_REQS', 'OPPOSING_PLAYER_IS_GOOD_REQS');

-- N.B. MODIFIER_PLAYER_DIPLOMACY_SIMPLE_MODIFIER has COLLECTION_MAJOR_PLAYERS and EFFECT_DIPLOMACY_SIMPLE_EFFECT

INSERT INTO ModifierArguments(ModifierId, Name, Value) VALUES  
('STD_DIPLO_EVIL_HATES_GOOD_INTERACTION', 'SimpleModifierDescription', 'LOC_TOOLTIP_SAMPLE_DIPLOMACY_EVIL_HATES_GOOD'),  
('STD_DIPLO_EVIL_HATES_GOOD_INTERACTION', 'InitialValue', '-20');

INSERT INTO ModifierStrings(ModifierId, Context, Text) VALUES  
('STD_DIPLO_EVIL_HATES_GOOD_INTERACTION', 'Sample', 'LOC_DIPLO_EVIL_HATES_GOOD');

INSERT INTO RequirementSets(RequirementSetId, RequirementSetType) VALUES  
('OPPOSING_PLAYER_IS_GOOD_REQS', 'REQUIREMENTSET_TEST_ALL'),  
('PLAYER_IS_EVIL_REQS', 'REQUIREMENTSET_TEST_ALL');

INSERT INTO RequirementSetRequirements(RequirementSetId, RequirementId) VALUES  
('OPPOSING_PLAYER_IS_GOOD_REQS', 'REQUIRE_PLAYER_HAS_GOOD_CAPITAL'),  
('OPPOSING_PLAYER_IS_GOOD_REQS', 'REQUIRES_PLAYERS_HAVE_MET'),  
('PLAYER_IS_EVIL_REQS', 'REQUIRE_PLAYER_HAS_EVIL_CAPITAL');

INSERT INTO Requirements(RequirementId, RequirementType) VALUES
('REQUIRE_PLAYER_HAS_GOOD_CAPITAL', 'REQUIREMENT_COLLECTION_ANY_MET'),
('REQUIRE_PLAYER_HAS_EVIL_CAPITAL', 'REQUIREMENT_COLLECTION_ANY_MET');

INSERT INTO RequirementArguments(RequirementId, Name, Value) VALUES  
('REQUIRE_PLAYER_HAS_GOOD_CAPITAL', 'CollectionType',  'COLLECTION_PLAYER_CAPITAL_CITY'),  
('REQUIRE_PLAYER_HAS_GOOD_CAPITAL', 'RequirementSetId',  'ALIGNMENT_GOOD_REQS');

INSERT INTO RequirementArguments(RequirementId, Name, Value) VALUES
('REQUIRE_PLAYER_HAS_EVIL_CAPITAL', 'CollectionType',  'COLLECTION_PLAYER_CAPITAL_CITY'),  
('REQUIRE_PLAYER_HAS_EVIL_CAPITAL', 'RequirementSetId',  'ALIGNMENT_EVIL_REQS');

INSERT INTO RequirementSets(RequirementSetId, RequirementSetType) VALUES  
('ALIGNMENT_GOOD_REQS', 'REQUIREMENTSET_TEST_ALL'),  
('ALIGNMENT_EVIL_REQS', 'REQUIREMENTSET_TEST_ALL');

INSERT INTO RequirementSetRequirements(RequirementSetId, RequirementId) VALUES  
('ALIGNMENT_GOOD_REQS', 'SLTH_REQUIREMENT_ALIGNMENT_GOOD'),  
('ALIGNMENT_EVIL_REQS', 'SLTH_REQUIREMENT_ALIGNMENT_EVIL');

INSERT INTO Requirements(RequirementId, RequirementType) VALUES  
('SLTH_REQUIREMENT_ALIGNMENT_GOOD', 'REQUIREMENT_PLOT_PROPERTY_MATCHES'),  
('SLTH_REQUIREMENT_ALIGNMENT_EVIL', 'REQUIREMENT_PLOT_PROPERTY_MATCHES');  
  
INSERT INTO RequirementArguments(RequirementId, Name, Value) VALUES  
('SLTH_REQUIREMENT_ALIGNMENT_GOOD', 'PropertyName','alignment_good'),  
('SLTH_REQUIREMENT_ALIGNMENT_GOOD', 'PropertyMinimum','1'),  
('SLTH_REQUIREMENT_ALIGNMENT_EVIL', 'PropertyName','alignment_evil'),  
('SLTH_REQUIREMENT_ALIGNMENT_EVIL', 'PropertyMinimum','1');
```

And if you wanted know the text values:
```
'LOC_DIPLO_EVIL_HATES_GOOD': 'You are Good, they are Evil'
'LOC_TOOLTIP_SAMPLE_DIPLOMACY_EVIL_HATES_GOOD': 'You are Good, Evil hates you'
```
There are also more complicated diplomacy effects, but quite a lot of them are very hard-coded, and would only work for that specific use case. Note that attaching to **TRAIT_LEADER_MAJOR_CIV** is not normal behaviour, as this affects every player. Most of the time, you will end up attaching to an Agenda. This is so that randomly assigned Traits are incompatible with certain Leaders where they would cancel out or stack their effects. For example, the **AGENDA_DARWINIST** is a randomly assigned Agenda that has modifiers to encourage war and cares less about grievances. This would be compounded by Alexanders trait of **AGENDA_SHORT_LIFE_GLORY** or cancelled out by **AGENDA_PEACEKEEPER** of Gandhi's, so entries in *ExclusiveAgendas* of **AGENDA_PEACEKEEPER**,**AGENDA_DARWINIST** and
**AGENDA_SHORT_LIFE_GLORY**,**AGENDA_DARWINIST** prevent them being selected together randomly.
# Biases


# Behaviour Trees