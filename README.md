<p align="center" style="position: relative">
  <a href="https://paste.myst.rs">
    <img width="500" src="./public/assets/images/pastemyst-display-2.png" /></a><br />
  a powerful website for storing and sharing text and code snippets. completely free and open source.
</p>
<p align="center">
  <a href="./LICENSE">license</a> •
  <a href="https://paste.myst.rs/legal">legal</a> •
  <a href="https://paste.myst.rs/donate">donations</a> •
  <a href="https://paste.myst.rs/changelog">changelog</a> •
  <a href="https://paste.myst.rs/api-docs">api</a> •
  <a href="https://paste.myst.rs/pastry">pastry-cli</a>
</p>
<p align="center">
  <a href="https://discord.gg/SdKbcbq"
    ><img src="https://discordapp.com/api/guilds/298510542535000065/widget.png"
  /></a>
  <a href="https://paste.myst.rs/donate"
    ><img src="https://img.shields.io/badge/-donate-blueviolet" width="49"
  /></a>
  <a href="https://github.com/CodeMyst/pastemyst/actions"
    ><img src="https://github.com/CodeMyst/pastemyst/workflows/CI/badge.svg"
  /></a>
</p>


<h2>about</h2>

if you like this project, please consider donating. any support is appreciated as it helps pay the server. more info at [pastemyst/donate](https://paste.myst.rs/donate)

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

<h3>pastry-cli</h3>

pastemyst also provides a first-party cli tool to interact with pastemyst directly without an interface. you can learn more about pastry from [pastemyst/pastry](https://paste.myst.rs/pastry)

<h2>building and running</h2>

to build and run pastemyst you need `dmd`, `dub`, `libssl-dev` (1.1), `libscrypt` (`libscrypt-dev` in ubuntu repos), `mongodb` and [`pastemyst-autodetect`](https://github.com/codemyst/pastemyst-autodetect).

on windows `libssl` should already be installed and `libscrypt` is prepackaged in `lib/windows/scrypt.lib` (you can build it yourself from https://github.com/CodeMyst/libscrypt).

you also need the `diff` and `patch` tools installed to be able to edit pastes and look at the history.

run the mongodb server on `127.0.0.1` and create 2 databases, `pastemyst` and `pastemyst-test` (for unit testing).

you also need a `config.yaml` file at the root of the project. it should look like [this](config-example.yml).

the github id and secret should be gotten from: [github applications](https://github.com/settings/applications), the homepage url should be: `http://localhost:5000/` and the authorization callback: `http://localhost:5000/login/github/callback`; same with gitlab, just replace `github` with `gitlab`.

don't forget to first pull the submodules:
```sh
git submodule update --init --recursive
```

now simply run `dub run` and everything should work fine.

<h3>docker</h3>

you can run this project with docker.
 * after cloning this project do NOT forget to add the git submodule dependency
 * create a `config.yaml` file and fill it in; you can copy the `config-example.yaml` file in the root folder of this project
 * build the docker-compose: `make build`
 * run the docker-compose: `make up`
 * open your favorite browser and access `localhost:5000`

you **must** run the tests **inside the docker**. To enter the docker run `docker exec -it pastemyst-v2_app_1 sh` (by default) in the root folder of the project. however if you change to root project's folder name or run another image this may not work! to access the image do `docker ps` and then choose the one of the images with `app` in it's name. now you just run `dub test`. to exit the docker just run `exit`.

do **not** forget to run `make down` when you're done!

to run it again just do `make up` and you're good to go!

<h2>contributing</h2>

first find an issue you would like to work on (or create your own and wait for approval). you should work on a separate branch (if you're working on a new feature name the branch `feature/feature-name`, for fixes: `fix/fix-name`, etc).

<h2>api libraries</h2>

here are some api libraries that are developed by other people. they are not directly supported by me. big thanks to the developers! if you want your library added here just open an issue.

| link                                                                | language   | author          | supports v2 |
|---------------------------------------------------------------------|------------|-----------------|-------------|
| [pastemyst.java](https://github.com/YeffyCodeGit/pastemyst.java)    | java       | Yeff            | yes         |
| [pastemyst-cpp](https://github.com/billyeatcookies/pastemyst-cpp)   | c++        | billyeatcookies | yes         |
| [MystPaste.NET](https://github.com/shift-eleven/MystPaste.NET)      | c#         | shift-eleven    | yes         |
| [pastemystgo](https://github.com/WaifuShork/pastemystgo)            | go         | WaifuShork      | yes         |
| [pastemyst.v](https://github.com/billyateallcookies/pastemyst.v)    | v          | billyeatcookies | yes         |
| [pastemyst-ts](https://github.com/YilianSource/pastemyst-ts)        | ts         | YilianSource    | yes         |
| [pastemyst-rs](https://github.com/ANF/pastemyst-rs)                 | rust       | ANF-Studios     | yes         |
| [pastemyst.js](https://github.com/harshhhdev/pastemyst.js)          | js/ts      | harshhhdev      | yes         |
| [pastemyst-d](https://github.com/CodeMyst/pastemyst-d)              | d          | codemyst        | yes         |
| [pastemyst-py](https://github.com/Dmunch04/pastemyst-py)            | python     | munchii         | yes         |
| [PasteMystNet](https://github.com/dentolos19/PasteMystNet)          | c#         | dentolos19      | yes         |
| [PasteMyst-JS](https://github.com/FleshMobProductions/PasteMyst-JS) | js         | fmproductions   | no          |

you should avoid using a library not supporting the v2 api, since it might break and is lacking a lot of features.
