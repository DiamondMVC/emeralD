/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/emeralD/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module cmd;

import std.conv : to;
import std.array : replace, array, split, join;
import std.algorithm : map, endsWith, startsWith, filter;
import std.stdio : File;
import std.file : write, append, read, isFile, mkdirRecurse, dirEntries, SpanMode, exists;
import std.string : indexOf;
import std.path : dirName;
import std.process : executeShell;

import meta : thisExeDir, workFolder;
import templates;

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

  if (args[0] == "--shell" || args[0] == "-sh")
  {
    if (args.length > 1)
    {
      executeShell(args[1 .. $].join(" "), null, Config.none, size_t.max, workFolder && workFolder.length ? workFolder : null);
    }
    
    return;
  }

  if (args[0] == "--remote" || args[0] == "-rm")
  {
    if (args.length == 4)
    {
      if (args[1] == "--scaffold" || args[1] == "-sc")
      {
        addRemoteScaffold(args[2], args[3]);
      }
      else
      {
        addRemoteTemplate(args[1], args[2], args[3]);
        loadRemoteTemplates();
      }
    }

    return;
  }

  if (args[0] == "--project" || args[0] == "-prj")
  {
    if (args.length == 3)
    {
      addWorkFolder(args[1], args[2]);

      return;
    }
  }

  if (args[0] == "--scaffold" || args[0] == "-sc")
  {
    if ((args.length == 2 || args.length == 3 || args.length == 4 || args.length == 5) && args[1] && args[1].length)
    {
      bool excludeScaffoldName;

      foreach (arg; args.dup)
      {
        if (arg && arg.length && (arg == "--exclude" || arg == "-ex"))
        {
          excludeScaffoldName = true;
          args = args.filter!(a => a != "--exclude" && a != "-ex").array;
        }
        else if (arg.startsWith("--project=") || arg.startsWith("-prj="))
        {
          auto nameEndIndex = arg.indexOf('=');

          if (nameEndIndex < (arg.length - 1))
          {
            auto projectName = arg[nameEndIndex + 1 .. $];

            if (projectName && projectName.length)
            {
              setWorkFolder(projectName);
            }
          }

          args = args.filter!(a => !a.startsWith("--project") && !a.startsWith("-prj")).array;
        }
      }

      auto scaffoldTemplate = args[1];
      auto scaffoldPath = (args.length == 3 ? (args[2] ~ "/") : null);

      if (scaffoldTemplate && scaffoldTemplate.length)
      {
        foreach (string item; dirEntries(thisExeDir ~ "/scaffold/" ~ scaffoldTemplate, SpanMode.depth))
        {
          auto itemDir = dirName(item);
          string dirReplace = (thisExeDir ~ "/scaffold/").replace("\\", "/");

          string dest = (item.replace("\\", "/")).replace(dirReplace, "");

          if (scaffoldPath && scaffoldPath.length)
          {
            dest = scaffoldPath ~ "/" ~ dest;
          }

          if (excludeScaffoldName)
          {
            dest = dest.replace(scaffoldTemplate ~ "/", "");
          }

          dest = workFolder ~ dest;
          auto dirDest = dirName(dest);

          if (!exists(dirDest))
          {
            mkdirRecurse(dirDest);
          }

          if (item.isFile)
          {
            write(dest, read(item));
          }
        }
      }

      return;
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

    if (arg.startsWith("--path=") || arg.startsWith("-p="))
    {
      auto pathEndIndex = arg.indexOf('=');

      if (pathEndIndex < (arg.length - 1))
      {
        path = arg[pathEndIndex + 1 .. $];
      }
    }
    else if (arg.startsWith("--project=") || arg.startsWith("-prj="))
    {
      auto nameEndIndex = arg.indexOf('=');

      if (nameEndIndex < (arg.length - 1))
      {
        auto projectName = arg[nameEndIndex + 1 .. $];

        if (projectName && projectName.length)
        {
          setWorkFolder(projectName);
        }
      }
    }
    else if (arg == "--append" || arg == "-a")
    {
      appending = true;
    }
    else if (arg.startsWith("--file=") || arg.startsWith("-f="))
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
    append(workFolder ~ path, templateContent);
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

    write(workFolder ~ path, templateContent);
  }
}
