module pastemyst.paste.tags;

/++
 + converts a tags string from the frontend in a proper tag array
 +/
public string[] tagsStringToArray(string tags)
{
    import std.array : split, array;
    import std.string : strip;
    import std.algorithm : sort, uniq;

    string[] arr = tags.split(",");
    string[] processed;
    foreach (i, tag; arr)
    {
        string processedTag = tag.strip();
        if (processedTag != "")
        {
            processed ~= processedTag;
        }
    }
    return processed.sort.uniq.array;
}
