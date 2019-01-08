# PasteMyst [![Build Status](https://travis-ci.com/CodeMyst/PasteMyst.svg?branch=master)](https://travis-ci.com/CodeMyst/PasteMyst)

A lightweight and simple website for pasting text, mainly code snippets.

## Building

Dependencies:

* mariadb-server

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
