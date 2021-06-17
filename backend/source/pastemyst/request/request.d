module pastemyst.request.request;

import vibe.d;

struct Request
{
    HTTPServerRequest request;
    HTTPServerResponse response;
}
