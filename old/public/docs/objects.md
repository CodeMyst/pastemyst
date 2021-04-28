## paste object

| field     | type     | description                                                                            |
|-----------|----------|----------------------------------------------------------------------------------------|
| \_id      | string   | id of the paste                                                                        |
| ownerId   | string   | id of the owner, if it doesn't have an owner it's set to `""`                          |
| title     | string   | title of the paste                                                                     |
| createdAt | ulong    | unix time of when the paste is created                                                 |
| expiresIn | string   | when the paste will expire, possible values are never, 1h, 2h, 10h, 1d, 2d, 1w, 1m, 1y |
| deletesAt | ulong    | when the paste will be deleted, if it has no expiry time it's set to 0                 |
| stars     | ulong    | number of stars the paste received                                                     |
| isPrivate | bool     | if it's private it's only accessible by the owner                                      |
| isPublic  | bool     | is it displayed on the owner's public profile                                          |
| tags      | string[] | list of tags                                                                           |
| pasties   | pasty[]  | list of pasties/files in the paste, can't be empty                                     |
| edits     | edit[]   | list of edits                                                                          |

## pasty object

| field    | type   | description           |
|----------|--------|-----------------------|
| \_id     | string | id of the pasty       |
| language | string | language of the pasty |
| title    | string | title of the pasty    |
| code     | string | contents of the pasty |

## edit object

| field    | type     | description                                                                                                                  |
|----------|----------|------------------------------------------------------------------------------------------------------------------------------|
| \_id     | string   | unique id of the edit                                                                                                        |
| editId   | string   | id of the edit, multiple edits can share the same id showing that multiple fields were changed at the same time              |
| editType | number   | type of edit, possible values are title(0), pastyTitle(1), pastyLanguage(2), pastyContent(3), pastyAdded(4), pastyRemoved(5) |
| metadata | string[] | various metadata used internally, biggest usecase is storing exactly which pasty was edited                                  |
| edit     | string   | actual paste edit, it stores old data before the edit as the current paste stores the new data                               |
| editedAt | number   | unix time of when the edit was made                                                                                          |
