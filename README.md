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

Nottud's UI Notes:
- Need looping trigger calling system.process().
- initialiseUiSystem() as the very first trigger.
- Make sure to save the system back into the uiSystemArray.