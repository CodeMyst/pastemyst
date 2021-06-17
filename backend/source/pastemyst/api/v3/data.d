module pastemyst.api.v3.data;

import vibe.d;

import pastemyst.request;

public struct DataApi
{
public:

    @Api("v2")
    @Route("/data/test")
    Json getFoo2()
    {
        return Json(["hello": Json("world2")]);
    }

    @Api("v3")
    @Route("/data/test")
    Json getFoo3()
    {
        return Json(["hello": Json("world3")]);
    }
}
