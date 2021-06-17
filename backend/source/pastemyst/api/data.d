module pastemyst.api.data;

import vibe.d;

import pastemyst.request.router;
import pastemyst.request.request;

public struct TestApi
{
public:

    @Route("/data/test")
    Json getTest()
    {
        return Json(["hello": Json("world")]);
    }
}

