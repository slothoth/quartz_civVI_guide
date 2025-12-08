Having a good code editor will speed your modding so you can do more with less time, catch bugs before you make them, prevent syntax errors, and generally make the experience better. There are many options for code editors. Visual Studio Code, Sublime, PyCharm, even something very basic like Notepad++. You can even use code editors inside a Database Viewer like DBeaver. Most code editors are created roughly equal, so if you already use one of those, I'd just say stick with it. Lets go through installing a code editor, and what advantages it brings:

# Installing a Code Editor

For this tutorial we will use [Visual Studio Code](https://code.visualstudio.com/Download), as it is simple yet allows hooking up the test Database, Lua linting, XML linting and other useful tools with a few simple plugins. It should be simple to install. These setups will probably apply to any other code editor.
# Setting up a Project
Open Visual Studio and use File > Open Folder and navigate to a folder you want to work in and click Open. This is now a Project Workspace you can use, where it can use the contents of anything in this project to help you write in your current file. You can make new files in this window with Ctrl-N or rightclick New File. You can then save that file with Ctrl-S or File>Save As... . By saving with a given file extension like .lua or .xml, that file will then automatically get checked for syntax.

# Find in Files

One way the Project Workspace helps us out is finding files. As your project starts getting bigger, you will start finding it harder to find exactly where you wrote something. This is where a Find in Files tool helps. In Sublime, do Ctrl-Shift-F (or Cmd-Shift-F for Mac). This opens a finder window at the bottom, which you can use to find those instances.

This is useful for more than just your own files! I often set up workspaces in the games DLC and Base folder, and use them to search for text I am interested in. Say I want to know how the Oppidum is set up, I can just make a workspace in the DLC folder and I can then find every instance its used. This also is very useful for mods I want to understand so I can do something similar.

You can also achieve this effect with Notepad++ Find in Files, or a Command line tool like RipGrep, or software like AgentRansack.
# Lua setup

You can use plugins in Visual Studio Code (or in most other editors) to check your code:
![[lua_for_linting.png]]


You can see this Lua code is incorrect, it starts a for loop, but doesn't have an *end* clause, and so the *for* has the red squiggle. We can also hover the line to see the cause of it:
![[lua_linting_error_explain.png]]

How do we set this up? On the left side, this 3-4 block icon opens the Extensions tab. You can then search Lua in the extensions marketplace to find this, the Lua Language server. Installing that and restarting VS Code should enable it.
![[lua_vs_extension.png]]
We can go one step further, and get some information for what functions certain objects have:
![[wildWCompletions.png]]
This is done using another plugin that modder WildW made. You can find it by searching for their name in the extensions marketplace.
![[wildw_marketplace.png]]
The real power of this is it has Type information through a lot of function signatures, and lets you autocomplete. It can save a lot of time going back and forth on the modding companion 2.0 sheet.

# XML setup
You should be able to get some nice basic XML highlighting almost out the box for .xml files. But importantly, quite a lot of files have a different extension than .xml, but are XML, and are not correctly detected as XML. So you need to tell your editor how to interpret that extension. The easiest way in VS Code is to open a file with that given extension, then click the highlighted section on the bottom right, in this case, saying XML as I already have this configured. You can be sure its the right one if you hover it and it says "Select Language Mode".
![[XML_Formatting.png]]
Click it, and you should get a dropdown, and you can select XML:
![[select_lang_vsCode.png]]
Now you should have better XML highlighting and syntax, seeing mistakes at a glance, like the missing Dependencies end Tag here:
![[xml_lint_syntax_error.png]]
# SQL Setup
Running SQL commands within your editor is possible. This can also be done in Database Viewer software like DBeaver, which have in built simple editors you can run against the database. In an editor like VS Code, you need to hook up your database copy to your editor. For this, you will need two plugins, SQLTools and SQLTools-sqlite from the marketplace.
![[sqltools-vscode.png]]
Once installed, you should have an extra cylinder icon on the left bar. Click it, and Add New Connection, and choose SQLite. Then give it a name and its location:
![[vs_code_sqlite_connection.png]]

You can then inspect the database as you would for a database viewer:

![[vscode_sql_inspect.png]]

You can then get some decent completions in script files:
![[vscode_sql_completion.png]]
## The best SQL coding experience (that isn't free)
The best code editor for SQL coding is hands down Datagrip, or any IntelliJ product with their Database Tools and SQL add-on. The reason I don't recommend it primarily is that its a paid product, though University students can likely get it free from a student license. But if you can get it for free, I highly recommend it. Like others, it can hook up the gameplay database, but it has extra features that others do not:
![[intelliJ_linting_good.png]]

That you wouldn't get with VS Code:
![[vscode_missing_sql_linting.png]]
It also provides better completions for columns.


# Fast logging checks
A nice thing with code editors is that they will update information in real-time. So you can have your modding.log, Database.log and Lua.log open, and see changes in real time. To make this the most efficient, it can be good to have a "shortcut" inside your project to access those files: