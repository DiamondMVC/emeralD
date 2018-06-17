# emeralD
Command-line tool for template files useful for generating code files, configurations etc.

## Control Commands

### --remote [root] [template] [url]

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

### --path=[path]

Adds the path in which the template file will be operating on.

Example:

```
--path=controllers
```
		
### --append

Appends the content of the given template to the given operating path, iff the path is a file.

Example:

```
--append
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
