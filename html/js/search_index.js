var search_data = {"index":{"searchIndex":["app","gli","commands","doc","markdowndocumentlistener","hook","prompt","promptfzf","promptstd","hookapp","hooker","string","all_bookmarks()","beginning()","bookmark_for()","bookmark_from_app()","browse_bookmarks()","cap()","cap!()","clear_screen()","clip()","clip_bookmark()","clone_hooks()","command()","commands()","copy_bookmark()","decode()","default_command()","delete_all_hooks()","delete_hooks()","encode()","end_command()","end_commands()","end_options()","ending()","escape_quotes()","flag()","format_regex()","fzf()","get_hooks()","install_fzf()","link_all()","link_files()","linked_bookmarks()","new()","new()","nil_if_missing()","open_gui()","open_linked()","options()","output_array()","program_desc()","program_long_desc()","restore_std()","search_bookmarks()","search_name()","search_path_or_address()","select_hook()","silence_std()","split_hook()","split_hooks()","switch()","uninstall_fzf()","valid_hook()","valid_hook!()","validate_format()","version()","which_fzf()","readme"],"longSearchIndex":["app","gli","gli::commands","gli::commands::doc","gli::commands::markdowndocumentlistener","hook","hook::prompt","hook::promptfzf","hook::promptstd","hookapp","hooker","string","hookapp#all_bookmarks()","gli::commands::markdowndocumentlistener#beginning()","hookapp#bookmark_for()","hookapp#bookmark_from_app()","hookapp#browse_bookmarks()","string#cap()","string#cap!()","hook::promptstd#clear_screen()","string#clip()","hookapp#clip_bookmark()","hookapp#clone_hooks()","gli::commands::markdowndocumentlistener#command()","gli::commands::markdowndocumentlistener#commands()","hookapp#copy_bookmark()","hookapp#decode()","gli::commands::markdowndocumentlistener#default_command()","hookapp#delete_all_hooks()","hookapp#delete_hooks()","hookapp#encode()","gli::commands::markdowndocumentlistener#end_command()","gli::commands::markdowndocumentlistener#end_commands()","gli::commands::markdowndocumentlistener#end_options()","gli::commands::markdowndocumentlistener#ending()","string#escape_quotes()","gli::commands::markdowndocumentlistener#flag()","hookapp#format_regex()","hook::promptfzf#fzf()","hookapp#get_hooks()","hook::promptfzf#install_fzf()","hookapp#link_all()","hookapp#link_files()","hookapp#linked_bookmarks()","gli::commands::markdowndocumentlistener::new()","hooker::new()","string#nil_if_missing()","hookapp#open_gui()","hookapp#open_linked()","gli::commands::markdowndocumentlistener#options()","hookapp#output_array()","gli::commands::markdowndocumentlistener#program_desc()","gli::commands::markdowndocumentlistener#program_long_desc()","hook::promptstd#restore_std()","hookapp#search_bookmarks()","hookapp#search_name()","hookapp#search_path_or_address()","hookapp#select_hook()","hook::promptstd#silence_std()","string#split_hook()","string#split_hooks()","gli::commands::markdowndocumentlistener#switch()","hook::promptfzf#uninstall_fzf()","string#valid_hook()","string#valid_hook!()","hookapp#validate_format()","gli::commands::markdowndocumentlistener#version()","hook::promptfzf#which_fzf()",""],"info":[["App","","App.html","","<p>Main class for GLI app\n"],["GLI","","GLI.html","",""],["GLI::Commands","","GLI/Commands.html","",""],["GLI::Commands::Doc","","GLI/Commands/Doc.html","",""],["GLI::Commands::MarkdownDocumentListener","","GLI/Commands/MarkdownDocumentListener.html","","<p>DocumentListener class for GLI documentation generator\n"],["Hook","","Hook.html","",""],["Hook::Prompt","","Hook/Prompt.html","",""],["Hook::PromptFZF","","Hook/PromptFZF.html","","<p>Methods for working installing/using FuzzyFileFinder\n"],["Hook::PromptSTD","","Hook/PromptSTD.html","",""],["HookApp","","HookApp.html","","<p>Hook.app functions\n"],["Hooker","","Hooker.html","","<p>Hook.app CLI interface\n"],["String","","String.html","","<p>String helpers\n"],["all_bookmarks","HookApp","HookApp.html#method-i-all_bookmarks","()","<p>Get all known bookmarks. Return array of bookmark hashes.\n"],["beginning","GLI::Commands::MarkdownDocumentListener","GLI/Commands/MarkdownDocumentListener.html#method-i-beginning","()",""],["bookmark_for","HookApp","HookApp.html#method-i-bookmark_for","(url)","<p>Get a Hook bookmark for file or URL. Return bookmark hash.\n"],["bookmark_from_app","HookApp","HookApp.html#method-i-bookmark_from_app","(app, opts)","<p>Get a bookmark from the foreground document of specified app.\n"],["browse_bookmarks","HookApp","HookApp.html#method-i-browse_bookmarks","(glob)",""],["cap","String","String.html#method-i-cap","()","<p>Capitalize only if no uppercase\n"],["cap!","String","String.html#method-i-cap-21","()",""],["clear_screen","Hook::PromptSTD","Hook/PromptSTD.html#method-i-clear_screen","(msg = nil)","<p>Clear the terminal screen\n"],["clip","String","String.html#method-i-clip","()",""],["clip_bookmark","HookApp","HookApp.html#method-i-clip_bookmark","(url, opts)","<p>Create a bookmark for specified file/url and copy to the clipboard.\n"],["clone_hooks","HookApp","HookApp.html#method-i-clone_hooks","(args)","<p>Copy all hooks from source file to target file\n"],["command","GLI::Commands::MarkdownDocumentListener","GLI/Commands/MarkdownDocumentListener.html#method-i-command","(name, aliases, desc, long_desc, arg_name, arg_options)","<p>Gives you a command in the current context and creates a new context of this command\n"],["commands","GLI::Commands::MarkdownDocumentListener","GLI/Commands/MarkdownDocumentListener.html#method-i-commands","()",""],["copy_bookmark","HookApp","HookApp.html#method-i-copy_bookmark","(title, url, opts)","<p>Create a bookmark from specified title and url and copy to the clipboard.\n"],["decode","HookApp","HookApp.html#method-i-decode","(string)",""],["default_command","GLI::Commands::MarkdownDocumentListener","GLI/Commands/MarkdownDocumentListener.html#method-i-default_command","(name)","<p>Gives you the name of the current command in the current context\n"],["delete_all_hooks","HookApp","HookApp.html#method-i-delete_all_hooks","(url, force: false)","<p>Delete all hooked files/urls from target file\n"],["delete_hooks","HookApp","HookApp.html#method-i-delete_hooks","(args, opts)","<p>Delete hooks between two files/urls\n"],["encode","HookApp","HookApp.html#method-i-encode","(string)",""],["end_command","GLI::Commands::MarkdownDocumentListener","GLI/Commands/MarkdownDocumentListener.html#method-i-end_command","(_name)","<p>Ends a command, and “pops” you back up one context\n"],["end_commands","GLI::Commands::MarkdownDocumentListener","GLI/Commands/MarkdownDocumentListener.html#method-i-end_commands","()",""],["end_options","GLI::Commands::MarkdownDocumentListener","GLI/Commands/MarkdownDocumentListener.html#method-i-end_options","()",""],["ending","GLI::Commands::MarkdownDocumentListener","GLI/Commands/MarkdownDocumentListener.html#method-i-ending","()","<p>Called when processing has completed\n"],["escape_quotes","String","String.html#method-i-escape_quotes","()",""],["flag","GLI::Commands::MarkdownDocumentListener","GLI/Commands/MarkdownDocumentListener.html#method-i-flag","(name, aliases, desc, long_desc, default_value, arg_name, must_match, _type)","<p>Gives you a flag in the current context\n"],["format_regex","HookApp","HookApp.html#method-i-format_regex","(options)","<p>Create a single regex for validation of an array by first char or full match.\n"],["fzf","Hook::PromptFZF","Hook/PromptFZF.html#method-i-fzf","()","<p>Get path to fzf binary, installing if needed\n<p>@return     [String] Path to fzf binary\n"],["get_hooks","HookApp","HookApp.html#method-i-get_hooks","(url)","<p>Get bookmarks hooked to file or URL. Return array of bookmark hashes.\n"],["install_fzf","Hook::PromptFZF","Hook/PromptFZF.html#method-i-install_fzf","(force: false)","<p>Install fzf on the current system. Installs to a subdirectory of the gem\n<p>@param      force  [Boolean] …\n"],["link_all","HookApp","HookApp.html#method-i-link_all","(args)","<p>Create bi-directional links between every file/url in the list of arguments\n"],["link_files","HookApp","HookApp.html#method-i-link_files","(args)","<p>Link 2 or more files/urls with bi-directional hooks.\n"],["linked_bookmarks","HookApp","HookApp.html#method-i-linked_bookmarks","(args, opts)","<p>Get a list of all hooks on a file/url.\n"],["new","GLI::Commands::MarkdownDocumentListener","GLI/Commands/MarkdownDocumentListener.html#method-c-new","(_global_options, _options, _arguments, app)",""],["new","Hooker","Hooker.html#method-c-new","()",""],["nil_if_missing","String","String.html#method-i-nil_if_missing","()",""],["open_gui","HookApp","HookApp.html#method-i-open_gui","(url)","<p>Open the Hook GUI for browsing/performing actions on a file or url\n"],["open_linked","HookApp","HookApp.html#method-i-open_linked","(url)","<p>Select from a menu of available hooks and open using macOS `open`.\n"],["options","GLI::Commands::MarkdownDocumentListener","GLI/Commands/MarkdownDocumentListener.html#method-i-options","()",""],["output_array","HookApp","HookApp.html#method-i-output_array","(hooks_arr, opts)","<p>Output an array of hooks in the given format.\n"],["program_desc","GLI::Commands::MarkdownDocumentListener","GLI/Commands/MarkdownDocumentListener.html#method-i-program_desc","(desc)","<p>Gives you the program description\n"],["program_long_desc","GLI::Commands::MarkdownDocumentListener","GLI/Commands/MarkdownDocumentListener.html#method-i-program_long_desc","(desc)",""],["restore_std","Hook::PromptSTD","Hook/PromptSTD.html#method-i-restore_std","()","<p>Restore silenced STDOUT and STDERR\n"],["search_bookmarks","HookApp","HookApp.html#method-i-search_bookmarks","(search, opts)","<p>Search bookmarks, using both names and addresses unless options contain “:names_only”. Return …\n"],["search_name","HookApp","HookApp.html#method-i-search_name","(search)","<p>Search boomark names/titles. Return array of bookmark hashes.\n"],["search_path_or_address","HookApp","HookApp.html#method-i-search_path_or_address","(search)","<p>Search bookmark paths and addresses. Return array of bookmark hashes.\n"],["select_hook","HookApp","HookApp.html#method-i-select_hook","(marks)","<p>Generate a menu of available hooks for selecting one or more hooks to operate on. Revamped to use `fzf`, …\n"],["silence_std","Hook::PromptSTD","Hook/PromptSTD.html#method-i-silence_std","(file = '/dev/null')","<p>Redirect STDOUT and STDERR to /dev/null or file\n<p>@param      file  [String] a file path to redirect to …\n"],["split_hook","String","String.html#method-i-split_hook","()",""],["split_hooks","String","String.html#method-i-split_hooks","()",""],["switch","GLI::Commands::MarkdownDocumentListener","GLI/Commands/MarkdownDocumentListener.html#method-i-switch","(name, aliases, desc, long_desc, negatable)","<p>Gives you a switch in the current context\n"],["uninstall_fzf","Hook::PromptFZF","Hook/PromptFZF.html#method-i-uninstall_fzf","()","<p>Remove fzf binary\n"],["valid_hook","String","String.html#method-i-valid_hook","()",""],["valid_hook!","String","String.html#method-i-valid_hook-21","()",""],["validate_format","HookApp","HookApp.html#method-i-validate_format","(fmt, options)","<p>Check if format fully matches or matches the first character of available options. Return full valid …\n"],["version","GLI::Commands::MarkdownDocumentListener","GLI/Commands/MarkdownDocumentListener.html#method-i-version","(version)","<p>Gives you the program version\n"],["which_fzf","Hook::PromptFZF","Hook/PromptFZF.html#method-i-which_fzf","()","<p>Return the path to the fzf binary\n<p>@return     [String] Path to fzf\n"],["README","","README_rdoc.html","","<p>hookapp\n<p>A CLI for Hook.app on macOS.\n<p>hook - CLI interface for Hook.app (macOS)\n"]]}}