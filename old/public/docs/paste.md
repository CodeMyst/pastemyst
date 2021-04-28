## paste

endpoint for creating and fetching pastes, and more.

the api isn't usable with encrypted pastes. support for this might be added in the future.

the list of all languages supported can be found in the github repo in the `data/languages.json` file.

### get a paste

<p class="method">GET</p> <code>/paste/<span class="var">{id}</span></code>

[comment]: <> (`GET /paste/:id`)

if you're accessing a private paste you need to provide the `Authorization` header.

it returns a full paste object. [[objects docs]](/api-docs/objects)

### create a paste

<p class="method">POST</p> <code>/paste</code>

[comment]: <> (`POST /paste`)

if you want the paste to be tied to your account, or create a private/public paste, or want to use tags you need to provide the `Authorization` header.

required JSON body:

| field     |  optional | type    | description                                                                            |
|-----------|-----------|---------|----------------------------------------------------------------------------------------|
| title     |  yes      | string  | title of the paste                                                                     |
| expiresIn |  yes      | string  | when the paste will expire, possible values are never, 1h, 2h, 10h, 1d, 2d, 1w, 1m, 1y |
| isPrivate |  yes      | bool    | if it's private it's only accessible by the owner                                      |
| isPublic  |  yes      | bool    | is it displayed on the owner's public profile                                          |
| tags      |  yes      | string  | list of tags, comma separated                                                          |
| pasties   |  no       | pasty[] | list of pasties                                                                        |

check out [[objects docs]](/api-docs/objects) for the `pasty` object.

### edit a paste

<p class="method">PATCH</p> <code>/paste/<span class="var">{id}</span></code>

[comment]: <> (`PATCH /paste/:id`)

you can only edit pastes on your account, so you must provide the `Authorization` header.

it returns a full paste object. [[objects docs]](/api-docs/objects)

to edit a paste you need to provide only the values you are editing in the JSON body.

these are the values you can edit:

* title
* isPrivate
* isPublic
* tags
* pasties

to edit a single pasty you will need to provide all of the original pasties changing the fields you want. it's not possible to update a single pasty without providing all of the pasties.

### delete a paste

<p class="method">DELETE</p> <code>/paste/<span class="var">{id}</span></code>

[comment]: <> (`DELETE /paste/:id`)

you can only delete pastes on your account, so you must provide the `Authorization` header. this action is irreversible.
