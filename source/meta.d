/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/emeralD/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module meta;

/// Gets this executable file's directory.
string thisExeDir()
{
  import std.path : dirName;
  import std.file : thisExePath;

  return dirName(thisExePath);
}
