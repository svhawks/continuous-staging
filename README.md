[![Stories in Ready](https://badge.waffle.io/movielala/continuous-staging.png?label=ready&title=Ready)](https://waffle.io/movielala/continuous-staging)

Introduction
============

A simple sinatra app to handle post hook actions from github.

## Automatic Updater

1. Gets a list of deploy except runner and shared dirs
2. Goes to each deploy and updates code
3. If remote does not exist, it marks the deploy for deletion


To make it work, please add your server url in webhooks in github.

Ex:
https://github.com/github/repo/settings/hooks

The 
http://runner.staging.xxx.com 

Maintance:

If it is not running
try to run
sudo monit start runner-thin

## Settings

The settings is stored in `config/settings.yml` file. The name of the app should match the name of the project in the github repository. A sample file is included
