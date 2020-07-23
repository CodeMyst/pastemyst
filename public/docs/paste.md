## paste

endpoint for creating and fetching pastes, and more.

### get a paste

<p class="method">GET</p> <code>/paste/<span class="var">{id}</span></code>

[comment]: <> (`POST /paste`)

if you're accessing a private paste you need to provide the `Authorization` header.

it returns a full paste object. [[objects docs]](/api-docs/objects)
