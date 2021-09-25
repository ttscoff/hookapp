# hookapp

Hook.app CLI

## Editing

Main executable is located in `bin/hook`. All commands are defined here.

Helpers and main classes are in `lib/`.

@run(subl -p hookapp.sublime-project)

## Building the Gem

@run(rake clobber rdoc package)

## Deploy

1. Bump version
2. Commit and push to GitHub
3. See Updating the Docs
4. Package the gem (See Building the Gem)
5. Push the gem with `gem push pkg/hookapp-[VERSION].gem`

## Updating the Docs

Update the docs with `bundle exec bin/hook _doc --format=markdown` and `bundle exec bin/hook _doc --format=rdoc`, then run `rake rerdoc`

@run(bundle exec bin/hook _doc --format=rdoc && bundle exec bin/hook _doc --format=markdown && rake rerdoc)

## Test

Run all tests using `rake test`.

Run verbose using `rake test TESTOPT="-v"`

Run a single test using `rake test TEST=test/TEST_FILE.rb`

This howzit task accepts an optional argument pointing to a specific test (just the test part of the filename, e.g. archive runs `test/doing_archive_test.rb`).

`howzit -r test -- archive` (or `bld test archive` with the Fish function)

```run
#!/bin/bash
if [[ -n $1 ]]; then
    rake test TESTOPT="-v" TEST=test/hook_$1_test.rb
    if [[ $? != 0 ]]; then
        echo "Available tests"
        echo -e "\033[1;32;40m"
        FILES="test/hook_*_test.rb"
        for file in $FILES; do
            echo $(basename $file ".rb") | sed -E 's/hook_(.*)_test/- \1/'
        done
        echo -e "\033[0m"
    fi
else
    rake test TESTOPT="-v"
fi
```
