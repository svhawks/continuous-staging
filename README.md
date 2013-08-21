Introduction
============

A simple sinatra app to handle post hook actions from github.

## Automatic Updater

1. Gets a list of deploy except runner and shared dirs
2. Goes to each deploy and updates code
3. If remote does not exist, it marks the deploy for deletion
