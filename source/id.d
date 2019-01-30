module id;

private const string base36Chars = "0123456789abcdefghijklmnopqrstuvwxyz";

/++
	Encodes a long number into base36. Input has to be >= 0
+/
string encodeBase36 (long input)
							in (input >= 0, "Input has to be >= 0")
{
	import std.algorithm.mutation : reverse;

	char [] result;
	while (input != 0)
	{
		result ~= base36Chars [input % 36];
		input /= 36;
	}

	return cast (string) result.reverse;
}

unittest
{
	assert (encodeBase36 (500) == "dw");
	assert (encodeBase36 (1000) == "rs");
	assert (encodeBase36 (986_835) == "l5g3");
	assert (encodeBase36 (938_756_938) == "fiwthm");
}

string createId ()
{
	import std.random : uniform;

	// The number is between 1296 and 46_655 so it will always have 3 characters
	// 1296 is the smallest 3 character base 36 string (100)
	// 46_655 is the largest 3 character base 36 string (zzz)
	return encodeBase36 (uniform (1296, 46_655));
}

unittest
{
	assert (createId ().length == 3);
	assert (createId ().length == 3);
	assert (createId ().length == 3);
	assert (createId ().length == 3);
	assert (createId ().length == 3);
}
