# pastemyst ![CI](https://github.com/CodeMyst/pastemyst/workflows/CI/badge.svg) [![Discord Server](https://discordapp.com/api/guilds/298510542535000065/widget.png)](https://discord.gg/SdKbcbq)

## about

a powerful website for storing and sharing text and code snippets. completely free and open source.

https://paste.myst.rs/

if you like this project please consider donating. any support is appreciated as it helps pay the server. https://paste.myst.rs/donate

features:
* simple and beautiful interface
* multi file pastes
* accounts
* good editor
* a lot of languages
* tagging pastes
* private pastes
* encrypted pastes
* editing pastes and a full history system
* simple to use and mostly restriction free REST API

## building

to build and run pastemyst you need `dmd`, `dub`, `libssl-dev` (1.1), `libscrypt` (`libscrypt-dev` in ubuntu repos), `mongodb` and [`pastemyst-autodetect`](https://github.com/codemyst/pastemyst-autodetect).

you also need the `diff` and `patch` tools installed to be able to edit pastes and look at the history.

run the mongodb server on `127.0.0.1` and create 2 databases, `pastemyst` and `pastemyst-test` (for unit testing).

you also need a `config.yaml` file at the root of the project. it should look like [this](config-example.yml).

the github id and secret should be gotten from: [github applications](https://github.com/settings/applications), the homepage url should be: `http://localhost:5000/` and the authorization callback: `http://localhost:5000/login/github/callback`; same with gitlab, just replace `github` with `gitlab`.

don't forget to first pull the submodules:
```sh
git submodule update --init --recursive
```

now simply run `dub run` and everything should work fine.

## contributing

first find an issue you would like to work on (or create your own and wait for approval). you should work on a separate branch (if you're working on a new feature name the branch `feature/feature-name`, for fixes: `fix/fix-name`, etc.).

## docker

you can run this project with docker.
 * after cloning this project do NOT forget to add the git submodule dependency
 * create a `config.yaml` file and fill it in; you can copy the `config-example.yaml` file in the root folder of this project
 * build the docker-compose: `make build`
 * run the docker-compose: `make up`
 * open your favorite browser and access `localhost:5000`

you **must** run the tests **inside the docker**. To enter the docker run `docker exec -it pastemyst-v2_app_1 sh` (by default) in the root folder of the project. however if you change to root project's folder name or run another image this may not work! to access the image do `docker ps` and then choose the one of the images with `app` in it's name. now you just run `dub test`. to exit the docker just run `exit`.

do **not** forget to run `make down` when you're done!

to run it again just do `make up` and you're good to go!

## api libraries

here are some api libraries that are developed by other people. they are not directly supported by me. big thanks to the developers! if you want your library added here just open an issue.

| link                                                                | language | author        | supports v2 |
|---------------------------------------------------------------------|----------|---------------|-------------|
| [pastemyst-d](https://github.com/CodeMyst/pastemyst-d)              | d        | codemyst      | yes         |
| [pastemyst-py](https://github.com/Dmunch04/pastemyst-py)            | python   | munchii       | yes         |
| [pastemyst-net](https://github.com/dentolos19/PasteMystNet)         | c#       | dentolos19    | yes         |
| [pastemyst-js](https://github.com/FleshMobProductions/PasteMyst-JS) | js       | fmproductions | no          |

you should avoid using a library not supporting the v2 api, since it might break and is lacking a lot of features.
