## time

endpoint for useful time oprations.

### expires in to a unix timestamp

<p class="method">GET</p> <code>/time/expiresInToUnixTime?createdAt=<span class="var">{createdAt}</span>&expiresIn=<span class="var">{expiresIn}</span></code>

[comment]: <> (`GET /time/expiresInToUnixTime?createdAt={createdAt}&expiresIn={expiresIn}`)

converts an `expiresIn` value to a specific time when a paste should expire.

* `createdAt` - unix timestamp of a creation date
* `expiresIn` - when a paste expires

[comment]: <> (TODO: list all possible `expiresIn` values.)

#### returns

| field  | type   | description                |
|--------|--------|----------------------------|
| result | number | when a paste should expire |

#### example request

<p class="method">GET</p> <code>/time/expiresInToUnixTime?createdAt=<span class="var">1588441258</span>&expiresIn=<span class="var">1w</span></code>

[comment]: <> (`/time/expiresInToUnixTime?createdAt=1588441258&expiresIn=1w`)

```json
{
  "result": 1589046058
}
```