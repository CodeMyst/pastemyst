module pastemyst.paste.langs;

import pastemyst.data;

/++
 + holds the language stats for a paste for a single language
 +/
struct LangStat
{
    /++
     + the name of the language
     +/
    string lang;

    /++
     + the percentage the language has in the paste
     +/
    float perc;
}

/++
 + calculates the language stats of a paste
 + returns an associative array with the language name as the key and the percentage as the value
 +/
public LangStat[] pasteLangStats(const Paste paste) @safe
{
    import std.algorithm : sort;
    import std.array : array;

    LangStat[] res;

    ulong[string] chars;
    ulong total;

    foreach (pasty; paste.pasties)
    {
        if (!(pasty.language in chars))
        {
            chars[pasty.language] = 0;
        }

        chars[pasty.language] += pasty.code.length;
        total += pasty.code.length;
    }

    if (total == 0)
    {
        return res;
    }

    foreach (lang, c; chars)
    {
        float perc = (c / cast(float) total) * 100;
        if (perc != 0)
        {
            res ~= LangStat(lang, perc);
        }
    }

    return res.sort!((a, b) => a.perc > b.perc).array();
}
