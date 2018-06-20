/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/emeralD/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module templates;

import std.file : dirEntries, SpanMode, isDir, isFile, mkdirRecurse, rmdirRecurse, write, readText, read, exists, append;
import std.path : baseName, dirName;
import std.stdio : File;
import std.string : format, strip;
import std.array : split, replace;
import std.algorithm : map, endsWith;
import std.zip : ZipArchive;

import meta : thisExeDir, workFolder;

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

/**
* Adds a remote scaffolding archive.
* Params:
*   name = The name of the scaffolding archive.
*   url =  The url of the archive. (Must be zip.)
*/
void addRemoteScaffold(string name, string url)
{
  import std.net.curl : download, HTTP;

  if (!url.endsWith(".zip"))
  {
    return;
  }

  auto rootPath = thisExeDir ~ "/scaffold/" ~ name;
  auto path = rootPath ~ "/__archive.zip";

  if (!exists(path))
  {
    rmdirRecurse(rootPath);
    rmdirRecurse(rootPath);
  }

  download!HTTP(url, path);

  auto zip = new ZipArchive(read(path));


  foreach (name, am; zip.directory)
  {
    zip.expand(am);

    auto filePath = (rootPath ~ "/" ~ name).replace("\\", "/");
    auto dir = dirName(filePath).replace("\\", "/");

    if (!exists(dir))
    {
      mkdirRecurse(dir);
    }

    auto base = baseName(filePath);
    auto data = base.split(".");

    if (data.length >= 2 && data[0] && data[0].strip().length)
    {
      write(filePath, am.expandedData);
    }
  }
}

/// The work folders.
private string[string] _workFolders;

/// Loads all work folders.
void loadWorkFolders()
{
  if (_workFolders && _workFolders.length)
  {
    _workFolders.clear();
  }

  auto projects = File(thisExeDir ~ "/projects.emd");

  foreach (line; projects.byLine.map!(l => l.replace("\r", "")))
  {
    if (!line || !line.length)
    {
      continue;
    }

    auto data = line.split("|");

    if (!data || data.length != 2)
    {
      continue;
    }

    immutable workFolderName = cast(immutable)data[0];
    immutable workFolderPath = cast(immutable)data[1];

    _workFolders[workFolderName] = workFolderPath;
  }
}

/**
* Adds a work folder.
* Params:
*   name = The name of the work folder to add.
*   path = The path of the work folder.
*/
void addWorkFolder(string name, string path)
{
  append(thisExeDir ~ "/projects.emd", "%s|%s\r\n".format(name, path));

  loadWorkFolders();

  setWorkFolder(name);
}

/**
* Sets a work folder.
* Params:
*   name = The name of the work folder to set.
*/
void setWorkFolder(string name)
{
  workFolder = _workFolders.get(name, "");

  if (workFolder && workFolder.length && workFolder[$-1] != '/')
  {
    workFolder ~= "/";
  }
}
