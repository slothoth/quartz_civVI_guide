Firaxis uses XML for all their database modding. This was probably generated via a program with a graphical user interface. Us plebs have to do without however, so XML is a pain we have to write by hand. That XML is then transformed inside Civ into SQL commands. Here is an example:
```xml
<GameInfo>    
    <Modifiers>    
       <Row>    
          <ModifierId>PAPAL_PRIMACY_PRESSURE_ON_ADOPTION</ModifierId>  
          <ModifierType>MY_MODIFIER_TYPE</ModifierType>    
       </Row>    
    </Modifiers>    
    <ModifierArguments>    
       <Row>    
          <ModifierId>PAPAL_PRIMACY_PRESSURE_ON_ADOPTION</ModifierId>    
          <Name>Amount</Name>    
          <Value>200</Value>    
       </Row>    
    </ModifierArguments>    
    <BeliefModifiers>    
       <Row BeliefType="BELIEF_PAPAL_PRIMACY">    
          <ModifierId>PAPAL_PRIMACY_PRESSURE_ON_ADOPTION</ModifierId>    
       </Row>    
    </BeliefModifiers>  
</GameInfo>
```
The XML is always within a \<GameInfo\> Tag. Within that, a Tag is opened to specify the table to target with commands, like \<Modifiers\>. Then a command is started, like \<Row\> to add a new entry, and the details of what to include in that command are Tags or Properties of that Tag. As seen in specifying the ModifierId or ModifierType as Tags in the first example, or the BeliefType in the last example. It seems to be an idiosyncrasy why a Property or nested Tag is used, either works.
Here are the corresponding command translations:
- \<Row\>: INSERT INTO. This simply adds a new row to the database.
- \<Update\> UPDATE. This edits an existing entry in the database.
- \<Delete\> DELETE. This deletes an entry in the database.
- \<Replace\> INSERT OR REPLACE. This can be thought of as INSERT, except if the database already has a row with the same primary key, it overwrites that entry.
- \<InsertOrIgnore\> INSERT OR IGNORE. This can be thought of as INSERT, except if the database already has a row with the same primary key, nothing is written.
