## api docs

the base endpoint for the api is `https://paste.myst.rs/api`.

you don't need any api keys to access the api. the api is rate limited to 5 requests per second, after exceeding the rate limit your requests will get a `429 (too many requests)` response code. if you need to do more requests than that contact me.

### list of endpoints

* [/data](/api-docs/data) - getting various simple data
* [/time](/api-docs/time) - useful time operations
* [/paste](/api-docs/paste) - creating and fetching pastes, and more