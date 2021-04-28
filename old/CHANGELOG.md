# changelog

all notable changes to this project will be documented in this file.

## [2.4.0] - 2021-03-16

### added

- reordering pasties (not implemented yet when editing)
- specified how to provide the auth header for the api
- downloading pastes as a zip file
- added V and TS libs to docs (thanks to billyeatcookies and Yilian)

### fixed

- redirecting api requests that have a trailing slash
- correct wrapping of inline code blocks in markdown rendered pastes (and docs)
- faster theme loading (now there shouldn't be a flicker when you use the non-default theme)

## [2.3.2] - 2021-02-21

### added

- added pastemyst.js and pastemyst-rs wrappers
- dark+ theme (thanks to ANF Studios)

### fixed

- updated api docs to show that the extension of a language is optional

## [2.3.1] - 2021-02-07

### added

- added page about pastry the cli tool

### fixed

- fixed the looks of the solarized theme
- fixed profile page sometimes ratelimiting (now all the pastes and their meta show up almost instantly)
- fixed user search sometimes reporting that a user exists due to a bad mongodb query

## [2.3.0] - 2021-01-24

### added

- sessions are now stored in the mongo db
- api now returns supporterLength and contributor for users

### fixed

- codeblocks in markdown with long lines were overflowing

## [2.2.0] - 2021-01-20

### added

- showing api libraries in the api docs
- versioning asset files (no more caching issues)

### fixed

- html isnt rendered anymore in markdown pastes because of security issues
- fixed highlighting lines of a paste (you can now highlight lines again and the browser will correctly scroll to them)

## [2.1.0] - 2020-12-03

huge thanks to yilian and harsh for contributing to this release.

### added

- toggleable options in the navigation change colour depending on the state
- custom scrollbars
- much better markdown styling in markdown pastes
- better error page when an internal server error occurs
- logging internal server errors

### fixed

- editor selection offset
- when copying links the protocol was missing
- fixed html mode
- fixed jsx mode
- returning plain text when the autodetection program fails (when it returns an out of memory exception for some reason)

## [2.0.1] - 2020-11-04

### fixed

- navigation on firefox was wrapping for no reason (added width:100%; to the navigation ul)
- wrong github link in the navigation (was the v2 repo)

## [2.0.0] - 2020-11-03

### added

- pastes can have multiple files (pasties)
- encrypted pastes
- tags
- accounts
- editing pastes
- public profiles
- themes
- default language
- better autodetection
- paste edit history
- viewing a paste at a specific edit
- starring pastes
- deleting pastes
- private pastes
- complete redesign
- more feature complete rest api
- cloning pastes
- copying to clipboard
- highlighting lines
- highlighting lines of specific edits
- better text editor
- able to render markdown pastes
- paste titles
- option for word wrapping
- option to toggle the website width
- embedding into other websites
- deleting accounts
- searching pastes on your profile
