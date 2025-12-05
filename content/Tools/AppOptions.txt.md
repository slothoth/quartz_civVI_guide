AppOptions.txt is a file that you can edit to adjust certain settings in Civ VI, including ones you cannot access from the regular settings menu. You can find it at:
> C:/Users/$USERNAME$/AppData/Local/Firaxis Games/Sid Meier's Civilization VI

N.B. the semi colon is how you comment out text in this file. Many have been fooled thinking they enabled a setting only to see there is a semi colon at the beginning.
Of interest is values under \[Debug\]:
# Firetuner
```
;Enable FireTuner.
EnableTuner 1
```
Having this entry lets you connect [[Firetuner]] to the game.
# Debug Menu
```
;Enable Debug menu.
EnableDebugMenu 1
```
This entry lets you access the debug console with the tilde (~) key. You can fiddle with many things there, but the main two are the console with the command `Reveal All` to show the whole map, and to reload artdef assets (which I've only tested for Units) with something like `artdef reload Units`

# Plot Tooltip Debug
```
;Enable Debug information in the plot info tooltips.
EnableDebugPlotInfo 1
```
Adds extra information to the plot tooltip when you hover. Suprisingly useful, since it lets you know the x y coordinates of the plot, for doing some script testing in Firetuner

# Supress Popups
```
;Suppress popups that are just informational (e.g., Civic Completed.)
SuppressInfoPopups 1
```
This is incredibly annoying without this, if you are doing tests and unlock all civics and techs, without this you have to click through every single one, like 100+ clicks.