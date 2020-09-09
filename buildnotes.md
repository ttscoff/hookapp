# hookapp

Hook.app CLI

## Editing

Main executable is located in `bin/hook`. All commands are defined here.

Helpers and main classes are in `lib/`.

@run(subl -p hookapp.sublime-project)

## Build

@run(rake package)

## Deploy

1. Bump version
2. Commit and push to GitHub
3. See Updating the Docs
4. Package the gem with @run(rake clobber package)
5. Push the gem with `gem push pkg/hookapp-[VERSION].gem`

## Updating the Docs

Update the docs with `bundle exec bin/hook _doc --format=markdown` and `bundle exec bin/hook _doc --format=rdoc`, then run `rake rerdoc`

@run(bundle exec bin/hook _doc --format=markdown)

