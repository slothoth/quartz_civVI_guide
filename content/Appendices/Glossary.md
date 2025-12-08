Glossary of terms and columns in database tables

# Tables
## Modifiers
 - *Permanent* means just that, that the modifier, once turned on, is always on, even if the requirement later on is not satisfied. If its not mentioned, its by default off, as 0.

- *RunOnce* is used for effects that you only want to apply once. Our example of granting science yields to cities with Granaries, thats an effect we want to be persistent, across all future turns. But something like Oxford University granting two Technologies, we would only want that to happen once, so it has *RunOnce* set to 1.

- *SubjectStackLimit*. These refer to how instances of this exact modifier can each affect the subject. An example of this would be the negative combat strength caused by Varu to adjacent enemy units. It would be too good if you could reduce that combat strength more than once, so *SubjectStackLimit* is set to 1.
- *OwnerStackLimit*: While unused, I would imagine this would do the same as *SubjectStackLimit* but as an Owner
- Repeatable: Used literally once, for a weird modifier, the Bermuda Triangle teleport. I have not seen a mod successfully use it.
- NewOnly: Unused.
## ModifierArguments
- *ModifierId*: The modifier this argument is for
- *Name*: The name of the parameter this argument is targetting
- *Value*: The value the parameter is being set to.
- *Type*: by default is set to **ARGTYPE_IDENTITY** but there are two other strings used, **ScaleByGameSpeed** and **LinearScaleFromDefaultHandicap**, which are used to scale the effects by game speed or how difficult the AI is set.
-  *Extra* and *SecondExtra* are to be used when Type is not **ARGTYPE_IDENTITY**, and are used to determine the scaling amount, or the variables dependant on the effect

## Requirements
- *Inverse*: This inverts the requirement satisfaction. Rather than turn on if the requirement is satisfied, instead it turns on only when the requirement is not satisfied.
- *ProgressWeight*: Unsure, but bar four requirements, it is always 1, and those requirements all related to game victories.
- *Persistent*: Unclear, only used for **REQUIREMENT_PLAYER_HAS_COMPLETED_PROJECT** in 5 places.
- *Triggered*: Unsure, but is used mostly for Modifiers that affect an AI's opinion of another empire, and all with the **REQUIRES_TURN_STARTED** requirement as owner, so it seems this **REQUIRES_TURN_STARTED** is gating this modifier to only rerun every turn at the start of a given turn.
- *Impact*: Unused
- *Likeliness*: Unused

## RequirementArguments
- *RequirementId*: The modifier this argument is for
- *Name*: The name of the parameter this argument is targetting
- *Value*: The value the parameter is being set to.
- *Type*: Unused, but should behave the same as ModifierArguments.
-  *Extra* and *SecondExtra*, are unused, but should behave the same as ModifierArguments.