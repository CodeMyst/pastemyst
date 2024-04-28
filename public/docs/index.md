## api docs

the base endpoint for the api is `https://paste.myst.rs/api/v2`.

the old v1 api is now **deprecated**, but it is still available at `https://paste.myst.rs/api/`. please move on to the v2 api as soon as possible, as it will be removed at some point. you can view the docs to the v1 api here: [[v1 api docs]](/api-docs/v1)

you don't need any api keys to access the api, unless you need to access pastes or features that require an account. the api is rate limited to 5 requests per second, after exceeding the rate limit your requests will get a `429 (too many requests)` response code. if you need to do more requests than that contact me.

to get private pastes, edit pastes, or anything like that you need to use a token. you can get your token on your profile settings page. make sure you don't give it to anyone, but if you do you can always regenerate it.

to use the token you simply have to provide it as an `Authorization` header to all requests requiring it. the docs will usually point out which endpoints and in which cases would need an `Authorization` header set.

the `Authorization` header is in the following format:
```
Authorization: token
```

### list of endpoints

* [/data](/api-docs/data) - getting various simple data
* [/time](/api-docs/time) - useful time operations
* [/paste](/api-docs/paste) - creating and fetching pastes, and more
* [/user](/api-docs/user) - getting users

and all of the objects that are needed for api requests: [objects](/api-docs/objects)

### api libraries

here are some api libraries that are developed by other people. they are not directly supported by me. big thanks to the developers! if you want your library added here just open an issue.

| link                                                                | language   | author          | api version |
|---------------------------------------------------------------------|------------|-----------------|-------------|
| [pastemyst.java](https://github.com/YeffyCodeGit/pastemyst.java)    | java       | Yeff            | v2          |
| [pastemyst-cpp](https://github.com/billyeatcookies/pastemyst-cpp)   | c++        | billyeatcookies | v2          |
| [MystPaste.NET](https://github.com/shift-eleven/MystPaste.NET)      | c#         | shift-eleven    | v2          |
| [pastemystgo](https://github.com/WaifuShork/pastemystgo)            | go         | WaifuShork      | v2          |
| [pastemyst.v](https://github.com/billyateallcookies/pastemyst.v)    | v          | billyeatcookies | v2          |
| [pastemyst-ts](https://github.com/YilianSource/pastemyst-ts)        | ts         | YilianSource    | v2          |
| [pastemyst-rs](https://github.com/ANF/pastemyst-rs)                 | rust       | ANF-Studios     | v2          |
| [pastemyst.js](https://github.com/harshhhdev/pastemyst.js)          | js/ts      | harshhhdev      | v2          |
| [pastemyst-d](https://github.com/CodeMyst/pastemyst-d)              | d          | codemyst        | v2          |
| [pastemyst-py](https://github.com/Dmunch04/pastemyst-py)            | python     | munchii         | v2          |
| [PasteMystNet](https://github.com/dentolos19/PasteMystNet)          | c#         | dentolos19      | v2          |
| [PasteMyst.jl](https://github.com/lines-of-codes/PasteMyst.jl)      | Julia      | lines-of-codes  | v2          |
| [PasteMyst-JS](https://github.com/FleshMobProductions/PasteMyst-JS) | js         | fmproductions   | v1          |

avoid using the v1 api as it's now deprecated and will be removed in a future version of pastemyst.
