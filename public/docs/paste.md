## paste

endpoint for creating and fetching pastes, and more.

### create a paste

<p class="method">POST</p> <code>/paste</code>

[comment]: <> (`POST /paste`)

#### json body parameters

| field     | type         | description                  | optional?              |
|-----------|--------------|------------------------------|------------------------|
| title     | string       | title of the paste           | yes                    |
| expiresIn | string       | when a paste expires         | yes, defaults to never |
| isPrivate | bool         | whether the paste is private | yes, defaults to false |
| pasties   | object array | list of pasties              | no                     |

**pasty object**

| field    | type   | description           | optional? |
|----------|--------|-----------------------|-----------|
| title    | string | title of the pasty    | yes       |
| language | string | language of the pasty | yes       |
| code     | string | contents of the pasty | no        |

#### returns

| field     | type         | description                                  |
|-----------|--------------|----------------------------------------------|
| _id       | string       | unique id of the paste                       |
| ownerId   | string       | user id of the user that created the paste   |
| createdAt | number       | unix timestamp of when the paste was created |
| title     | string       | title of the paste                           |
| expiresIn | string       | when a paste expires                         |
| isPrivate | bool         | whether the paste is private                 |
| pasties   | object array | list of pasties                              |

#### example request

<p class="method">POST</p> <code>/paste</code>

**json body:**

```json
{
  "title": "example paste",
  "expiresIn": "never",
  "isPrivate": false,
  "pasties":
  [
    {
      "title": "first pasty",
      "language": "plain text",
      "code": "first pasty contents"
    },
    {
      "title": "second pasty",
      "language": "plain text",
      "code": "second pasty contents"
    }
  ]
}
```

**result:**

```json
{
  "ownerId": "",
  "isPublic": false,
  "expiresIn": "never",
  "createdAt": 1588442362,
  "isPrivate": false,
  "title": "example paste",
  "_id": "gsgbdyf6",
  "pasties": [
    {
      "language": "plain text",
      "title": "first pasty",
      "code": "first pasty contents"
    },
    {
      "language": "plain text",
      "title": "second pasty",
      "code": "second pasty contents"
    }
  ]
}
```