/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/emeralD/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module templates;

import std.file : dirEntries, SpanMode, isDir, isFile, mkdirRecurse, write, readText, exists, append;
import std.path : baseName;
import std.stdio : File;
import std.string : format;
import std.array : split, replace;
import std.algorithm : map;

import meta : thisExeDir;

/// Collection of templates.
private string[string][string] _templates;

/// Loads the template paths.
void loadTemplates()
{
  import std.stdio : writeln;
  writeln(thisExeDir);
  foreach (string root; dirEntries(thisExeDir ~ "/templates", SpanMode.shallow))
  {
    if (root.isDir)
    {
      auto rootName = baseName(root);

      foreach (string templatePath; dirEntries(root, SpanMode.shallow))
      {
        if (templatePath.isFile)
        {
          auto templateName = baseName(templatePath);

          _templates[rootName][templateName] = templatePath;
        }
      }
    }
  }
}

/// Loads all remote templates.
void loadRemoteTemplates()
{
  auto templates = File(thisExeDir ~ "/remotetemplates.emd");

  foreach (line; templates.byLine.map!(l => l.replace("\r", "")))
  {
    if (!line || !line.length)
    {
      continue;
    }

    auto data = line.split('|');

    if (data.length != 3)
    {
      continue;
    }

    immutable root = cast(immutable)data[0];
    immutable name = cast(immutable)data[1];
    immutable url = cast(immutable)data[2];

    if (root !in _templates || name !in _templates[root])
    {
      import std.net.curl : get, HTTP;

      import std.stdio : writefln;
      writefln("'%s'", url);

      auto templateResult = cast(string)get!HTTP(url);

      if (templateResult)
      {
        auto rootPath = thisExeDir ~ "/templates/" ~ root;

        if (!exists(rootPath))
        {
          mkdirRecurse(rootPath);
        }

        auto path = rootPath ~ "/" ~ name;

        write(path, templateResult);

        _templates[root][name] = path;
      }
    }
  }
}

/**
* Reads a template.
* Params:
*   root = The root of the template.
*   name = The name of the template.
*/
string readTemplate(string root, string name)
{
  auto templates = _templates.get(root, null);

  if (!templates)
  {
    return null;
  }

  auto path = templates.get(name, null);

  if (!path)
  {
    return null;
  }

  return readText(path);
}

/**
* Adds a remote template.
* Params:
*   root = The root of the template.
*   name = The name of the template.
*   url =  The url of the template.
*/
void addRemoteTemplate(string root, string name, string url)
{
  append(thisExeDir ~ "/remotetemplates.emd", "%s|%s|%s\r\n".format(root, name, url));
}
