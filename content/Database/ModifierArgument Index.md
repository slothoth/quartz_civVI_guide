This document will detail any quirks in the attached GameEffectsArguments table and used GameEffect arguments in RequirementArguments or ModifierArguments. A note is that this list does not include Effects from the Zombies game mode, as that is a pain to datamine as it destroys a lot of other content in the database.

The effects were mined using this SQL command:
```sql
SELECT DISTINCT  
    E.EffectType,  
    A.Name,  
    G.Description,  
    G.ArgumentType,  
    G.DefaultValue,  
    G.Required,  
    G.DatabaseKind  
FROM Modifiers AS M  
INNER JOIN DynamicModifiers AS E  
    ON M.ModifierType = E.ModifierType  
LEFT JOIN ModifierArguments AS A  
    ON M.ModifierId = A.ModifierId  
LEFT JOIN GameEffectArguments AS G  
    ON G.Type = E.EffectType  
    AND G.Name = A.Name  
  
UNION  
  
SELECT  
    G.Type,  
    G.Name,  
    G.Description,  
    G.ArgumentType,  
    G.DefaultValue,  
    G.Required,  
    G.DatabaseKind  
FROM GameEffectArguments AS G  
WHERE G.Type LIKE '%EFFECT%';
```

And the Requirements using this:
```sql
SELECT  
  RequirementType,  
  Name,  
  Example,  
  Description,  
  ArgumentType,  
  DefaultValue,  
  Required,  
  DatabaseKind  
FROM (  
  SELECT DISTINCT  
    R.RequirementType,  
    A.Name,  
    A.Value AS Example,  
    G.Description,  
    G.ArgumentType,  
    G.DefaultValue,  
    G.Required,  
    G.DatabaseKind  
  FROM Requirements AS R  
  LEFT JOIN RequirementArguments AS A  
    ON R.RequirementId = A.RequirementId  
  LEFT JOIN GameEffectArguments AS G  
    ON G.Type = R.RequirementType  
    AND G.Name = A.Name  
  
  UNION  
  
  SELECT    G.Type,  
    G.Name,  
    G.Description,  
    G.ArgumentType,  
    G.DefaultValue,  
    G.Required,  
    NULL,  
    G.DatabaseKind  
  FROM GameEffectArguments AS G  
  WHERE G.Type LIKE '%REQUIREMENT_%'  
    AND G.Type NOT LIKE 'EFFECT_%'  
)  
GROUP BY RequirementType, Name;
```
