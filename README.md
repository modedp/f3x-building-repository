# This does have some unique utilities!

Beyond being used for exploits, it's pretty compatible with running in empty games with only BTools.

## What can I do with this?

You can transfer your builds that you have obtained on Roblox Studio using your Level 7 Executor to a Roblox game of your choosing that allows for F3X Building Tools (HD Admin is an example).

## Studio? How does it work?

You use the autobuilder in the Roblox Studio to let your builds be placed in runtime without needing to export into Modules or any other site inconveniences. This process takes less effort and can be saved locally too.

## What should I have to make this work?

1. An empty baseplate in studio, the positions of all parts will transfer over. 
2. The autobuilder pasted on the command bar.
3. A folder with the name Build in workspace, containing all of the parts
4. Your build must contain zero extraneous base parts that can not be inserted with the BTools. IE: Union Operations. Separate them or convert them into MeshParts.
5. Once you have loaded this in, the output will be shown in console, usually if your build is too large it will not appear totally. Printing it in steps will work surely, or using StringValues to hold them separately can help too. Clear your console and try again using either option.
6. Once you have the data, you must use the executor and the Autobuilder to paste it into the game. The script has built in logging functionality, so it will print to console any steps that you have instructed and how much % it has finished.
7. Boom, you can enjoy the build from Studio temporarily in game, no matter what it was you wanted to import. This can be useful for importing large maps as well into games that you do not have Studio Access in, but only rudimentary BTools.
