## data

this endpoint is for getting various simple data.

### get a language by name

<p class="method">GET</p> <code>/data/language?name=<span class="var">{language}</span></code>

get the language information for a specific language, returns a `404` status if the language couldn't be found. note that the language name must be [percent encoded](https://en.wikipedia.org/wiki/Percent-encoding).

| field | type         | description                             | optional? |
|-------|--------------|-----------------------------------------|-----------|
| name  | string       | language name                           | no        |
| mode  | string       | language mode to be used in the editor  | no        |
| mimes | string array | list of mimes used by the language      | no        |
| ext   | string array | list of extensions used by the language | yes       |
| color | string       | color representing the language         | yes       |

```json
{
  "ext": [
    "d"
  ],
  "name": "D",
  "color": "#ba595e",
  "mode": "d",
  "mimes": [
    "text/x-d"
  ]
}
```

### get a language by extension

<p class="method">GET</p> <code>/data/languageExt?extension=<span class="var">{extension}</span></code>

get the language information for a specific language found by the extension, returns a `404` status if the language couldn't be found.

returns the same object as getting the language by name.

[comment]: <> (TODO: how to get all possible language values? and should they use the name, mode or mime?)

### get the number of currently active pastes

<p class="method">GET</p> <code>/data/numPastes</code>

returns the number of currently active pastes.

| field     | type  |
| ----------|-------|
| numPastes | ulong |
