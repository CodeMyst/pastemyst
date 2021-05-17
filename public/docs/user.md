## user

endpoint for getting users.

### check if a user exists

<p class="method">GET</p> <code>/user/<span class="var">{username}</span>/exists</code>

[comment]: <> (`GET /user/:username/exists`)

returns `200 OK` if the user exists and `404 NOT FOUND` if it doesn't.

### get a user

<p class="method">GET</p> <code>/user/<span class="var">{username}</span></code>

[comment]: <> (`GET /user/:username`)

returns the user if found. the user has to have a public profile enabled for it to be fetched through the api.

returned JSON body:

| field           | type     | description                                                      |
|-----------------|----------|------------------------------------------------------------------|
| \_id            | string   | id of the user                                                   |
| username        | string   | username of the user                                             |
| avatarUrl       | string   | url of their avatar image                                        |
| defaultLang     | string   | the default language                                             |
| publicProfile   | bool     | if they have a public profile                                    |
| supporterLength | uint     | how long has the user been a supporter for, 0 if not a supporter |
| contributor     | bool     | if the user is a contributor to pastemyst                        |

### get the current user

<p class="method">GET</p> <code>/user/self</code>

[comment]: <> (`GET /user/self`)

returns the current user identified by the token. you have to provide the `Authorization` header.

this method returns more data than the `/user/{username}` method.

added fields:

| field           | type     | description                                                      |
|-----------------|----------|------------------------------------------------------------------|
| stars           | string[] | list of paste ids the user has starred                           |
| serviceIds      | object   | user ids of the service the user used to create an account       |

example JSON:

```json
{
    "_id": "gvtfvy9h",
    "avatarUrl": "https://avatars.githubusercontent.com/u/7966628?v=4",
    "contributor": true,
    "defaultLang": "D",
    "publicProfile": true,
    "serviceIds": {
        "github": "1111111"
    },
    "stars": ["cw09wh9y"],
    "supporterLength": 24,
    "username": "CodeMyst"
}
```
