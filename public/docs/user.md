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
| stars           | string[] | list of paste id's that they stared                              |
| publicProfile   | bool     | if they have a public profile                                    |
| supporterLength | uint     | how long has the user been a supporter for, 0 if not a supporter |
