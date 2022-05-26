# changelog

all notable changes to this project will be documented in this file.

## [2.8.0] - 2022-05-27

### added

- added API endpoint `data/numPastes` for getting the currently active number of pasteget the language information for a specific language found by the extension, returns a `404` status if the language couldn't be found.

returns the same object as getting the language by name.s

## [2.7.1] - 2022-05-02

### added

- added new theme - catppuccin

## [2.7.0] - 2021-10-02

### added

- showing some stats about a paste in the meta section (line count, word count, byte size)
- ability to add html to the head tag of all pages through the config file (useful for adding analytics scripts)

### fixed

- typo in time api endpoint documentation (thanks to billyeatcookies)
- fixed a login bug, no need to refresh the page an additional time through js after logging in (cookie was set to strict)
- password field for encrypting/decrypting a paste wasn't a proper password field

## [2.6.0] - 2021-07-15

### added

- new pasty editor button is now clearer (thanks to TheDutchMagikarp)
- added MystPaste.NET to docs (thanks to shift-eleven)
- added pastemyst-cpp do docs (thanks to billyeatcookies)
- added pastemyst.java to docs (thanks to Yeffy)
- when autodetect is selected, it will try and get the language from the pasty's title if it has an extension

## [2.5.0] - 2021-05-17

### added

- added getting the current user through the api
- added getting all of current user's pastes through the api
- specified that the param should be encoded for the api/data/language endpoint (thanks to ANF-Studios)
- added pastemystgo to the docs (thanks to WaifuShork)

### fixed

- unbreakable words will now wrap in markdown
- tables now properly scroll on overflow
- fixed the link to pastemyst.v in the docs

## [2.4.1] - 2021-03-30

thanks to ANF-Studios for help on this hotfix.

### fixed

- pastes with an id of length 3 or less were crashing the program because it tried to get the .zip part of the url
- pastemyst now successfully builds on windows

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
