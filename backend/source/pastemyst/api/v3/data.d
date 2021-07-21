module pastemyst.api.v3.data;

import vibe.d;

import pastemyst.request;

/**
 * Endpoint for providing various simple data.
 */
public struct DataApi
{
public:

    /**
     * Returns the list of all supported languages.
     */
    @Api("v3")
    @Route("/data/langs")
    RouteResponse getLangs()
    {
        import pastemyst.data.files : langs;

        RouteResponse res;
        res.json = serializeToJson(langs);
        return res;
    }
}
