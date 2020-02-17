# PasteMyst ![GitHub Workflow Status](https://img.shields.io/github/workflow/status/CodeMyst/PasteMyst/CI)

A lightweight and simple website for pasting text, mainly code snippets.

## Building

Dependencies:

* mariadb-server
* [shaman - programming language detector](https://github.com/Prev/shaman) (you need to be able to execute `shaman-tester` commands)

> **NOTE:** If you are hosting an instance of PasteMyst and you are on version 1.5 or below you need to install shaman language detector (and add it to your path so you can run the `shaman-tester` command) and you also need to add a new column to the database. The new column should be called `language` of type `longtext` and should be after the `code` column.

You'll need to have an `appsettings.json` file in the root of the project which will contain:

```json
{
    "mysql":
    {
        "host": "localhost",
        "user": "CodeMyst",
        "db": "PasteMyst"
    }
}
```

The `dbConnection` property is the connection string for connecting to the MariaDB. You can also specify the password for the database with the `mysql:pwd` property (this is optional):

```json
"mysql":
{
    "host": "localhost",
    "user": "CodeMyst",
    "db": "PasteMyst",
    "pwd": "supersecurepassword"
}
```

You can also use environment variables instead of `appsettings.json`. The equivalent environment variable names are:

| JSON        | Environment Variable Name |
|-------------|---------------------------|
| mysql:host  | MYSQL_HOST                |
| mysql:user  | MYSQL_USER                |
| mysql:db    | MYSQL_DB                  |
| mysql:pwd   | MYSQL_PWD    *(optional)* |

To build / run the project simply run `dub build` / `dub run`. To unit test the project run `dub test`.

## API Wrappers

| Language | URL                                      |
|----------|------------------------------------------|
| Python   | https://github.com/Dmunch04/PasteMyst.py |
