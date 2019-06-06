module pastemyst.conv.to;

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
 + Value value = valueToEnum!Value ("1"); // returns Value.one
 + -------------------
 +/
public T valueToEnum (T, R) (R value)
{
    T [R] lookup;

    static foreach (member; __traits (allMembers, T))
    {
        lookup [cast (R) __traits (getMember, T, member)] = __traits (getMember, T, member);
    }

    return *(value in lookup);
}
