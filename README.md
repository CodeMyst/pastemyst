# PasteMyst

A lightweight and simple website for pasting text, mainly code snippets.

## Building

Dependencies:

* mariadb-server

You'll need to have an `appsettings.json` file in the root of the project which will contain:

```json
{
    "dbConnection": "host=localhost;user=CodeMyst;db=PasteMyst",
    "hashidsSalt": "pastemyst"
}
```

The `dbConnection` property is the connection string for connecting to the MariaDB. You can also specify the password for the database like so:

```json
"host=localhost;user=CodeMyst;db=PasteMyst;pwd=password"
```

The `hashidsSalt` property is the salt used by [hashids](https://hashids.org/) to generate IDs for PasteMysts.

In [index.dt](/views/index.dt) you'll see that a Google reCAPTCHA key is required. You'll have to generate your own at [reCAPTCHA docs](https://developers.google.com/recaptcha/intro).

To build / run the project simply run `dub build` / `dub run`.
