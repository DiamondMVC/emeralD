/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/emeralD/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module main;

private:
/**
* The entry point.
* Params:
*   args = The command-line arguments passed to emeralD.
*/
void main(string[] args)
{
  if (!args || args.length == 1)
  {
    return;
  }

  import templates;
  loadTemplates();
  loadRemoteTemplates();

  args = args[1 .. $];

  import cmd;
  executeCommands(args);
}
