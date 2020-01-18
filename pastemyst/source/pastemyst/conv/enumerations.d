module pastemyst.conv.enumerations;

import std.typecons;

version(unittest)
{
    import dshould;
}

/++
 + Converts an enum value to an enum.
 +
 + Examples:
 + --------------------
 + enum Value : string
 + {
 +      one = "1",
 +      two = "2"
 + }
 +
 + Value value = valueToEnum!Value("1"); // returns Value.one
 + -------------------
 +/
public Nullable!T valueToEnum(T, R)(R value) @safe
{
    T[R] lookup;

    static foreach (member; __traits(allMembers, T))
    {
        lookup[cast(R) __traits(getMember, T, member)] = __traits(getMember, T, member);
    }

    if (value in lookup)
    {
        return (*(value in lookup)).nullable;
    }
    else
    {
        return Nullable!T.init;
    }
}

@("valueToEnum")
unittest
{
    enum Value : string
    {
        one = "1",
        two = "2"
    }

    valueToEnum!Value("1").get().should.equal(Value.one);
    valueToEnum!Value("2").get().should.equal(Value.two);
    valueToEnum!Value("4").isNull.should.equal(true);
}
