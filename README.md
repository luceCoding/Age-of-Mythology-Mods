# Age-of-Mythology-Mods
Mod for Age of Mythology

Example xs_tool.py command:
```
python .\xs_tool.py "C:\Users\joelu\Documents\github\Age-of-Mythology-Mods" -o "C:\Users\joelu\games\age of mythology retold\76561198051702281\random_maps\output.xs"
```

Optional Requirements:
- Install the vscode extension vscodeextensionretail.7z from your AoM Steam folder.

Quirks found:
- Keep lines under roughly 200 characters when compiling the final .xs output.
- .xs does not like quotes spanning multiple lines.
- Not found errors are caused by variables and methods being initalized sequentially, from top to bottom.
- Ref used as a parameter has to be the first parameters.

Nottud's UI Notes:
- Need looping trigger calling system.process().
- initialiseUiSystem() as the very first trigger.
- Make sure to save the system back into the uiSystemArray.