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

to build and run pastemyst you need `dmd`, `dub`, `libssl-dev` (1.1), `libscrypt`, `mongodb` and [`pastemyst-autodetect`](https://github.com/codemyst/pastemyst-autodetect).

run the mongodb server on `127.0.0.1` and create 2 databases, `pastemyst` and `pastemyst-test` (for unit testing).

you also need a `config.yaml` file at the root of the project. it should look like [this](config-example.yml).

the github id and secret should be gotten from: [github applications](https://github.com/settings/applications), the homepage url should be: `http://localhost:5000/` and the authorization callback: `http://localhost:5000/login/github/callback`; same with gitlab, just replace `github` with `gitlab`.

now simply run `dub run` and everything should work fine.

## contributing

first find an issue you would like to work on (or create your own and wait for approval). you should work on a separate branch (if you're working on a new feature name the branch `feature/feature-name`, for fixes: `fix/fix-name`).

after you are done create a pull request and wait for CI to build successfully.

## docker

you can run this project with docker.
 * after cloning this project do NOT forget to add the git submodule dependency
 * create a `config.yaml` file; you can copy the `config-example.yaml` file
 existent in the root folder of this project
 * go to your Github and Gitlab accounts and get the id and secret
   * for Github:
     * go to [Developer Settings](https://github.com/settings/apps)
     * fill `GitHub App name` with a name of your choice
     * fill `Homepage URL` with `http://localhost:5000/`
     * fill `User authorization callback URL` with `http://localhost:5000/login/github/callback`
     * save the application and copy both `Client id` and `Secret` to your
     `config.yaml` under the `github` section
   * for Gitlab:
     * go to [Applications](https://gitlab.com/profile/applications)
     * fill `Name` with a name of your choice
     * fill `Redirect URI` with `http://localhost:5000/login/gitlab/callback`
     * optional `Confidential`
     * choose a `Scope` (`api` for example)
     * save application and copy both `Id` and `Secret` to your `config.yaml`
     under the `gitlab` section
 * build the docker-compose: `make build`
 * run the docker-compose: `make up`
 * open your favorite browser and access `localhost:5000`

you **must** run the tests **inside the docker**. To enter the docker run
`docker exec -it pastemyst-v2_app_1 sh` (by default) in the root folder of the
project. however if you change to root project's folder name or run another
image this may not work! to access the image do `docker ps` and then choose the
one of the images with `app` in it's name. now you just run `dub test`. to exit
the docker just run `exit`.

do **not** forget to run `make down` when you're done!

to run it again just do `make up` and you're good to go!
