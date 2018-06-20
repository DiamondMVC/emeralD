# emeralD

Command-line tool for generating files from templates, scaffolding, generic shell command-passing etc.

## Control Commands

### --remote [root] [template] [url] || -rm [root] [template] [url]

Adds a template from a remote url.

#### root

The name of the root template folder.

Example:
```
diamond
```

#### template

The name of the template to add.

Example:

```
view.dd
```

#### url

The url of the remote template.

Example:

```
http://website/template.d
```

### --remote -scaffold [name] [url] || -rm -sc [name] [url]

Adds a scaffolding template from a remote url.

#### name

The name of the scaffolding template to add.

Example:

```
somescaffoldingtemplate
```

#### url

The url of the scaffolding template's archive.

*Note: Must be a zip archive for now.*

Example:

```
someremoteurl.com/somescaffoldingarchive.zip
```

### --path=[path] || -p=path

Adds the path in which the template file will be operating on.

Example:

```
--path=controllers
```

### --append || -a

Appends the content of the given template to the given operating path, iff the path is a file.

Example:

```
--append
```

### --file=[filename] || -f=[filename]

Adds an explicit filename, that can include arguments passed.

Example:

```
--file=$3.txt
```

### --scaffold [template] || -sc [template]

Scaffolds a scaffolding template into the current directory.

#### template

The name of the scaffolding template.

Example:

```
dub
```

Example:

```
--scaffold dub
```

### --scaffold [template] [destination] || -sc [template] [destination]

Scaffolds a scaffolding template into the specified destination.

#### template

The name of the scaffolding template.

Example:

```
dub
```

#### destination

The destination path.

Example:

```
myproject
```

Example:

```
--scaffold dub myproject
```

### --scaffold [template] [destination] --exclude || -sc [template] [destination] -ex

Scaffolds a scaffolding template into the specified destination and excludes the template name.


#### template

The name of the scaffolding template.

Example:

```
dub
```

#### destination

The destination path.

Example:

```
myproject
```

Example:

```
--scaffold dub myproject --exclude
```

### --project=[name] || -prj=[name]

Sets the current working folder to the one specified by the project.

This command can be appended to `--scaffold` and when using operating commands.

Example:

```
--project=mytest

...

--scaffold dub --project=mytest
```

### --project [name] [path] || -prj [name] [path]

Adds a new project to emeralD.

Projects are folders that can be invoked without being in the working folder.

This is useful to work across folders without having to manually switch around.

Example:

```
--project mytest /somefolder/anotherfolder/mytest
```

### --shell [args ...] || -sh [args ...]

Passes the arguments on to the command-line.

Example:

```
--shell cd tools
--shell dub build
```

## Operating Arguments:

### [root] [template] [name ($1)] [args ($2 - $x) ...]

#### root

The name of the root template folder.

Example:

```
diamond
```

#### template

The name of the template to use.

Example:

```
view.dd
```

#### name ($1)

The name of the result. The filename will be this appended with template's extension.

Example:

```
home
```

#### args ($2 - $x) ...

The arguments to pass to the template.

Example:

```
Home
```

Example:

```
diamond view.dd home Home
```

### [control commands ...] [root] [template] [name ($1)] [args ($2 - $x) ...]

#### root

The name of the root template folder.

Example:

```
diamond
```

#### template

The name of the template to use.

Example:

```
view.dd
```

#### name ($1)

The name of the result. The filename will be this appended with template's extension.

Example:

```
home
```

#### args ($2 - $x) ...

The arguments to pass to the template.

Example:

```
Home
```

Example:

```
--path=views diamond view.dd home Home
```

## .emd files:

If a template file has the extension .emd then each line will represent a command that will be passed to emeralD. You can pass the current arguments on to the next command.

Example:

**mvc.emd:**
```
--path=views diamond view.dd $1 $2
--path=controllers diamond viewcontroller.d --file=$1controller $1 $2
--path=controllers/package.d --append d import.d controllers.$1controller
--path=models d class.d $1 models.$1 $2
--path=models/package.d --append d import.d models.$1
```

The above template file will create mvc templates for a Diamond view, model and controller.

Example cmd:

```
diamond mvc.emd home Home
```

## Building emeralD

You can build emeralD using any D compiler:

https://dlang.org/download.html

It's recommended to build using DUB:

https://code.dlang.org/download

Simply invoke the following command:

```
dub build
```
