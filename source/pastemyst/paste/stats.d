module pastemyst.paste.stats;

import pastemyst.data;
import std.typecons;
import std.array;
import std.regex;
import std.string;
import std.math;
import std.conv;

/++
 + returns stats about a paste (lines, words, byte size)
 +/
public Tuple!(int, int, string) getPasteStats(const Paste p)
{
    int lines = 0;
    int words = 0;
    int totalLength = 0;

    foreach (paste; p.pasties)
    {
        lines += paste.code.split("\n").length;
        words += splitter(paste.code.strip(), regex(r"\s+")).array.length;
        totalLength += paste.code.length;
    }

    return tuple(lines, words, byteToHumanReadable(totalLength, 2));
}


private const units = ["kb", "mb", "gb", "tb", "pb", "eb", "zb", "yb"];

/++
 + converts bytes to a human readable string
 +/
public string byteToHumanReadable(ulong size, ulong decimals)
{
    if (size == 0)
    {
        return "0";
    }

    const thresh = 1000;

    if (abs(size) < thresh)
    {
        return size.to!string() ~ "b";
    }

    auto u = -1;
    const r = pow(10, decimals);

    // stupid dscanner warning
    const ul = units.length;

    double s = size;

    do
    {
        s/= thresh;
        ++u;
    } while (round(abs(s) * r) / r >= thresh && u < ul - 1);

    string fmt = "%."~decimals.to!string()~"f"~units[u];
    return format(fmt, s);
}