/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/emeralD/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module cmd;

import std.conv : to;
import std.array : replace, array, split;
import std.algorithm : map, endsWith, startsWith;
import std.stdio : File;
import std.file : write, append;
import std.string : indexOf;

import meta : thisExeDir;

/**
* Executes an array of command-line args.
* Params:
*   args = The command-line args.
*/
void executeCommands(string[] args)
{
  if (!args || !args.length)
  {
    return;
  }

  if (args[0] == "--remote")
  {
    if (args.length == 4)
    {
      import templates;

      addRemoteTemplate(args[1], args[2], args[3]);
      loadRemoteTemplates();
    }

    return;
  }

  string path;
  bool appending;
  string root;
  string templateName;
  string name;
  string[] arguments;
  string remoteUrl;
  string fileName;

  foreach (arg; args)
  {
    if (!arg || !arg.length)
    {
      continue;
    }

    if (arg.startsWith("--path="))
    {
      auto pathEndIndex = arg.indexOf('=');

      if (pathEndIndex < (arg.length - 1))
      {
        path = arg[pathEndIndex + 1 .. $];
      }
    }
    else if (arg == "--append")
    {
      appending = true;
    }
    else if (arg.startsWith("--file="))
    {
      auto pathEndIndex = arg.indexOf('=');

      if (pathEndIndex < (arg.length - 1))
      {
        fileName = arg[pathEndIndex + 1 .. $];
      }
    }
    else
    {
      if (!root)
      {
        root = arg;
      }
      else if (!templateName)
      {
        templateName = arg;
      }
      else if (!name)
      {
        name ~= arg;
      }
      else
      {
        arguments ~= arg;
      }
    }
  }

  if (!root || !root.length || !templateName || !templateName.length)
  {
    return;
  }

  if (fileName && fileName.length)
  {
    fileName = fileName.replace("$1", name);

    foreach (i; 0 .. arguments.length)
    {
      fileName = fileName.replace("$" ~ to!string(i + 2), arguments[i]);
    }
  }

  if (templateName.endsWith(".emd"))
  {
    auto cmdArgs = File(thisExeDir ~ "/templates/" ~ root ~ "/" ~ templateName);

    foreach (line; cmdArgs.byLine.map!(a => a.replace("\r", "")))
    {
      if (!line || !line.length)
      {
        continue;
      }

      executeCommands(line.split(" ").map!((lineArg)
      {
        if (name && name.length)
        {
          lineArg = lineArg.replace("$1", name);
        }

        foreach (i; 0 .. arguments.length)
        {
          lineArg = lineArg.replace("$" ~ to!string(i + 2), arguments[i]);
        }

        return cast(string)lineArg;
      }).array);
    }

    return;
  }

  if (!name || !name.length)
  {
    return;
  }

  import templates;

  auto templateContent = readTemplate(root, templateName);

  if (!templateContent || !templateContent.length)
  {
    return;
  }

  templateContent = templateContent.replace("$1", name);

  foreach (i; 0 .. arguments.length)
  {
    templateContent = templateContent.replace("$" ~ to!string(i + 2), arguments[i]);
  }

  if (appending)
  {
    append(path, templateContent);
  }
  else
  {
    fileName = fileName ? fileName : name ~ templateName[templateName.indexOf('.') .. $];

    if (path)
    {
      path ~= "/" ~ fileName;
    }
    else
    {
      path = fileName;
    }

    write(path, templateContent);
  }
}
