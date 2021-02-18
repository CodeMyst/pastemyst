## api docs

the base endpoint for the api is `https://paste.myst.rs/api/v2`.

the old v1 api is still available and works at `https://paste.myst.rs/api/` so that means that old applications don't need to change anything to use the api but we strongly suggest you upgrade to the v2 api as the old one might stop working. you can view the docs to the v1 api here: [[v1 api docs]](/api-docs/v1)

you don't need any api keys to access the api, unless you need to access pastes or features that require an account. the api is rate limited to 5 requests per second, after exceeding the rate limit your requests will get a `429 (too many requests)` response code. if you need to do more requests than that contact me.

to get private pastes, edit pastes, or anything like that you need to use a token. you can get your token on your profile settings page. make sure you don't give it to anyone, but if you do you can always regenerate it.

to use the token you simply have to provide it as an `Authorization` header to all requests requiring it. the docs will usually point out which endpoints and in which cases would need an `Authorization` header set.

### list of endpoints

* [/data](/api-docs/data) - getting various simple data
* [/time](/api-docs/time) - useful time operations
* [/paste](/api-docs/paste) - creating and fetching pastes, and more
* [/user](/api-docs/user) - getting users

and all of the objects that are needed for api requests: [objects](/api-docs/objects)

### api libraries

here are some api libraries that are developed by other people. they are not directly supported by me. big thanks to the developers! if you want your library added here just open an issue.

| link                                                                | language | author        | supports v2 |
|---------------------------------------------------------------------|----------|---------------|-------------|
| [pastemyst-rs](https://github.com/ANF/pastemyst-rs)                 | rust     | ANF-Studios   | yes         |
| [pastemyst.js](https://github.com/harshhhdev/pastemyst.js)          | js/ts    | harshhhdev    | yes         |
| [pastemyst-d](https://github.com/CodeMyst/pastemyst-d)              | d        | codemyst      | yes         |
| [pastemyst-py](https://github.com/Dmunch04/pastemyst-py)            | python   | munchii       | yes         |
| [pastemyst-net](https://github.com/dentolos19/PasteMystNet)         | c#       | dentolos19    | yes         |
| [pastemyst-js](https://github.com/FleshMobProductions/PasteMyst-JS) | js       | fmproductions | no          |
| [PasteMystNet](https://github.com/dentolos19/PasteMystNet)          | c#       | dentolos19    | yes         |
| [PasteMyst-JS](https://github.com/FleshMobProductions/PasteMyst-JS) | js       | fmproductions | no          |

you should avoid using a library not supporting the v2 api, since it might break and is lacking a lot of features.
