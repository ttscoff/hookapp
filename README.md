# hookapp

A CLI for Hook.app on macOS. 

## Installation

`gem install hookapp`. 

If you're on a stock Ruby install (i.e. have never installed `rvm` or `rbenv`), you may need sudo and your system password: `sudo gem install hookapp`.

## Usage

Run `hook help` for usage:

	NAME
	    hook - CLI interface for Hook.app (macOS)

	SYNOPSIS
	    hook [global options] command [command options] [arguments...]

	VERSION
	    0.0.1

	GLOBAL OPTIONS
	    --help    - Show this message
	    --version - Display the program version

    COMMANDS
        clip       - Copy Hook URL for file/url to clipboard
        clone, cp  - Clone all hooks from one file or url onto another
        help       - Shows a list of commands or help for one command
        link, ln   - Create bidirectional hooks between two or more files/urls
        list, ls   - List hooks on a file or url
        open, gui  - Open the specified file or url in Hook GUI
        remove, rm - Remove a hook between two files/urls
        select     - Select from hooks on a file/url and open in default application

Run `hook help COMMAND` on any of the commands for more details.

## Basics

### Creating hooks

The `link` command always creates bidirectional hooks. Give it two or more files or urls and it will create links between them. By default it links all files to the last file in the list. Add the `--all` flag to link all files to every other file in the list. This can be abbreviated as `hook ln -a file1.md file2.pdf "https://brettterpstra.com"`.

Similar to the way you would use the GUI, you can use `hook clip file1.md` to copy a Hook URL to the clipboard, and then use `hook ln -p file2.pdf` to create a link from the clipboard to `file2.pdf`.

You can also clone all of the links on one file to another, great for adding a new file to a group that's fully crosslinked. Just use `hook clone file1.md file2.pdf`. This command is abbreviated as `cp`.

### Listing hooks

Use the `list` (aliased as `ls`) command to list all attached hooks for a file. With no output format specified, `ls` will show the paths to all hooks, or the hook url if the hook doesn't have a file path (e.g. a URL). You can specify an output format using `--output_format` (abbreviated as `-o`) with one of "markdown", "hooks", "paths", or "verbose". Formats can be abbreviated to their first letter, so to display a Markdown list of all hooked files, use `hook ls -o m file1.md`.

### Removing hooks

Use `hook remove file1.md file2.pdf` to remove the bidirectional link between `file1.md` and `file2.pdf`. Add the `--all` flag (abbr. `-a`) with one or more files to remove ALL the hooks on them. This option requires confirmation.

#### Super nerdy scripting trick

The `--output_format=paths` option (abbr. `-o p`) combined with the `--files_only` flag (abbr. `-f`) will list just the paths and only include hooks that have file paths (i.e. exclude web, email, and other URLs). This can be combined with `--null` to output the list using a NULL separator, perfect for use with `xargs` or other command line tools.

### Acting on hooks

You can open a hooked file or URL by running `hook select file1.md`. This will display a menu of all the hooks on `file1.md`, and entering the number of a selection will open that file in its default application.

You can also open a file in the Hook GUI using `hook open file1.md`.
