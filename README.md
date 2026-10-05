# Age-of-Mythology-Mods
Mod for Age of Mythology

Example xs_tool.py command:
```
python .\xs_tool.py "C:\Users\joelu\Documents\github\Age-of-Mythology-Mods" -o "C:\Users\joelu\games\age of mythology retold\76561198051702281\random_maps\output.xs"
```

Optional Requirements:
- Install the vscode extension vscodeextensionretail.7z from your AoM Steam folder.

XS quirks:
- Keep lines under roughly 200 characters when compiling the final .xs output. .xs does not like quotes spanning multiple lines.
- Not found errors are caused by variables and methods being initalized sequentially, from top to bottom.
- Seems that instantiating a class inside another class does not persist the same class. 
- If you want a float make sure all values when applying operations on it have a decimal in place. Having a (float / int) will result in a non-float value.
- Accessing an array via myArray[0].foo() will error out. You must make a variable first before you can call foo().
- Every time you make access a variable it will make a copy. Its actually a detriment to performance if your class is too big. It is better to keep classes small or use no classes access to avoid too many large copies.
- Use mutable methods as placeholders to deal with the lack of abstract classes.
- Can't use ref int as a parameter to access an array.
- Class instance bug, same object is created when used within an array. Workaround this by making a function that creates/returns a new instance of said class.
- When accessing an array and manipulating it. You must set the object back into the array else you will get out of sync errors.
- Avoid using strings at all costs. Low end PCs cannot handle too many strings, especially since XS copies everything. Instead use the cTypes from MythTRConstants.txt which is compiled at run-time when you first start AoM. This is located in your AoM games folder.
- Do as little polling as you can. If you want to know if a unit has died. The best technique is to set spawn replacement data for that unit to spawn another unit upon death. Then use the OnCreationListener to check if said unit has spawned to perform action. On top of that, query the kbStats of a player to check if the death count has increased since the last cache as another way to avoid unnecessary polling. Third option is to use the Hashed Timed Wheel scheduler and set the ms timer to something other than 1ms. This will avoid always polling every frame and instead poll every couple of frames if you must have that much fidelity.

Nottud's UI Notes:
- Need looping trigger calling system.process().
- initialiseUiSystem() as the very first trigger.
- Make sure to save the system back into the uiSystemArray.