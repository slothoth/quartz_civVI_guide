![[unhandled_exception.png]]
You've met with a terrible fate, haven't you? Civ VI has gone and crashed, and you as a modder don't know why, or what you did to break it. This will be a guide to figuring out what caused your crash, using an attached debugger and a copy of the decompiled DLL, which admittedly can be hard to find. You could get to a point where you can see the cause of your crash relatively easy, using a program like Visual Studio, and a third party injector that overrides the Steam protection on the debugging thread. I will be using Visual Studio 2019, but any IDE worth its salt should be able to do this. Also download and build this [repository](https://github.com/Ricardonacif/steam-loader). You will want to build it for Release, and using (86x/Win32). This is what allows attaching to the debug process. 


![[build_solution.png]]


Ok now you've build the solution, run it. Before doing so, restart Steam:
![[debug_dll_start.png]]

You should get this window, let it do its thing until it gets to Injected, Have fun:
![[debug_dll_black_box.png]]

Ok. Now we launch Civ VI. Then in Visual Studio, we attach to the process:
![[debug_dll_attach_to_process.png]]![[debug_dll_attach_to_process_2.png]]
Now do whatever it was in Civ that caused your exception. If your crash isn't replicable, you would probably be better served doing a detailed crash dump, which I will explain elsewhere (once I understand it myself).

All things gone right (or rather, intentionally badly), you should hit an exception, which should happen in VS.

![[db_dll_exception_thrown_debugger.png]]

Now sadly, this will be very hard to interpret, as its basically just assembly information. For understanding it, we need a disassembled copy of the DLL, in a format that the debugger can use.

In the [contributors guide](https://github.com/Wild-W/CivilizationVI_CommunityExtension/wiki/Contributor's-Guide) was detailed how to get your DLL copy demangled, using the .map file. However, its very likely this version of the DLL is slightly out of date. Even though most everything is the same, all the addresses will differ from the working copy Civ uses. So we need to somehow update our decompiled code to have the same addresses. For that, we need to use the Version Manager in Ghidra.

First, import the most recent DLL file into Ghidra as though you were going to decompile it. It should be at something like: '\Steam\steamapps\common\Sid Meier's Civilization VI\DLC\Expansion2\Binaries\Win64\GameCore_XP2_FinalRelease.dll':
![[debug_dll_ghidra_version_tracker.png]]


I won't specify exactly how to update your version, as I'd be retreading ground already done in much better tutorials, like this [one](https://www.lrqa.com/en/cyber-labs/version-tracking-in-ghidra/) that I followed. If that link has gone dead, you should be able to find out how to do it quite easily by just googling 'Version Tracking Ghidra Tutorials”.

Assuming you've done it correctly, you should now have an updated dissassembly, with some caveats. The process isnt exact, and so a lot of addresses and memories arent mapped. However its the best we have. Now open your updated version of the DLL, as we are going to use an external Ghidra plugin to make a .PDB file, that the VS debugger can use to map the addresses when debugging.

Download the latest release of this [plugin](https://github.com/wandel/pdbgen) (this tutorial was done on v0.3.0). Also download the source code zip. Due to a bug, you then want to replace the PdbGen.java file in the release copy, with the one in the source code, found at ghidra/PdbGen.java.

Ok, so now you have a .java file, and pdbgen.exe. You need to both make Ghidra be able to access the .java specification, and also your computer be able to run pdbgen.exe from the command line:

### Copy PdbGen.java into your Ghidra scripts folder:
- Locate the file PdbGen.java in the assets folder.
- Copy it to your Ghidra scripts directory, which is usually at:
C:\Users\<YourUsername>\ghidra_scripts
- You can also open this folder by typing %USERPROFILE%\ghidra_scripts into File Explorer.

### Copy pdbgen.exe into a folder that is on your system’s PATH:
- Find the pdbgen.exe file in the assets folder.
- Move or copy it into a directory that’s already listed in your system’s PATH environment variable  e.g., C:\Windows\System32, or a development tools folder that you use. To check what folders are in your PATH:
search for environment variables in your windows search, and open the result. It should say something like “Edit Environment Variables”
- Click "Environment Variables..."
- In the "System variables" or "User variables" section, find and select Path, then click "Edit" to view/edit the list of folders. 
You could add a folder where your pdbgen.exe lives. Or you could find an unassuming location thats unlikely to change, and just copy  pdbgen.exe there.

You may now need to restart Ghidra. When you reopen, if all things have gone well, you should now have a Generate Pdb Action.
![[debug_dll_ghidra_generate_pdb.png]]

Use it, and it will probably ask for a location to save it. Do it wherever. Once its complete, you should have a pdb generated, like GameCore_XP2_FinalRelease.pdb.

Great! Now we are ready to attach the pdb to our debugger process. Go to Modules while debugging, and scroll to find GameCore_XP2_FinalRelease.dll. Yours will have a different Symbol status, as I have already done mine. Right click the Symbol Status entry for that dll.

![[debug_dll_symbols_loaded.png]]

Now click Load Symbols. Then navigate to your generated pdb and load it.
![[debug_dll_load_symbols.png]]

Congratulations! Your debugger process should now understand the stack far better, and give you a lot more information on whats gone wrong.

![[debug_dll_found_error_source_stack.png]]

You can see in my example the error came when doing the World Congress, which makes sense, as I have 2 players that are held in reserve and not even spawned in yet, which the developers would never expect. To fix my problem, I just turned off the World Congress capability using SQL. If you needed to dive deeper though, you could go to different dissembly points.

![[debug_dll_to_disassembly_vs.png]]

I will note that due to the version Tracking we did not being complete, some addresses will not resolve correctly. You can manually track those however by going to your older copy of the disassembly and finding where the addresses map to. Happy hunting!