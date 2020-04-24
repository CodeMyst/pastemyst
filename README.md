# pastemyst v2 ![CI](https://github.com/CodeMyst/pastemyst-v2/workflows/CI/badge.svg) [![Discord Server](https://discordapp.com/api/guilds/298510542535000065/widget.png)](https://discord.gg/SdKbcbq)

## about

this is the repo of the second version of [pastemyst](https://paste.myst.rs). it's in a separate repo because it's already messy in the main one and the second version is a huge rewrite and brings a lot more features. eventually this repo will end up as the master branch of the original repo once it's finished.

![pastemyst v2 image](https://myst.rs/pastemyst-v2-image.png)

this is pretty much how the end result will look (at least for the home page), some of the new features are:

* multi file pastes
* accounts
* bookmarking
* better editor
* more languages
* labeling / categorizing
* private pastes
* editing
* deleting
* ability to set the default language
* linking to specific line / line ranges
* creating pastes from the command line
* and more stuff...

## building

to build pastemyst you need `dmd`, `dub`, `libssl-dev` (1.1) and `mongodb`.

run the mongodb server on `127.0.0.1` and create 2 databases, `pastemyst` and `pastemyst-test` (for unit testing).

you also need a `config.yaml` file at the root of the project. it should look like:
```yaml
github:
    id: <client id>
    secret: <client secret>

gitlab:
    id: <client id>
    secret: <client secret>
```

the github id and secret should be gotten from: [github applications](https://github.com/settings/applications), the homepage url should be: `http://localhost:5000/` and the authorization callback: `http://localhost:5000//login/github`.

now simply run `dub run` and everything should work fine.

## contributing

first find an issue you would like to work on (or create your own and wait for approval). you should work on a separate branch (if you're working on a new feature name the branch `feature/feature-name`, for fixes: `fix/fix-name`).

after you are done create a pull request and wait for CI to build successfully.
