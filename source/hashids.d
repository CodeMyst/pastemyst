import std.stdio;
import std.string;
import std.exception;
import std.conv;
import std.regex;
import std.math;
import std.algorithm;

class Hashids {
    private:
    enum ALPHABET = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
    enum SEPS = "cfhistuCFHISTU";
    enum minAlphabetLength = 16;
    enum sepDiv = 3.5;
    enum guardDiv = 12.0;

    string alphabet;
    string seps;
    string guards;
    string salt;
    uint minHashLength;

    string consistentShuffle(const string alphas, const string salt) pure const {
        if(!salt.length) { return alphas; }

        char[] str = alphas.dup;

        for(int i = cast (int) (str.length - 1), v = 0, p = 0; i > 0; i--, v++){
            v %= salt.length;
            int c = salt[v];
            p += c;
            int j = (c + v + p) % i;

            char temp = str[j];
            str[j] = str[i];
            str[i] = temp;
        }
        return str.to!string;
    }

    string hash(ulong input, const string alphabet) pure const{
        char[] hash = [];

        do {
            hash = alphabet[input % $] ~ hash;
            input = input / alphabet.length.to!ulong;
        } while (input);

        return hash.to!string;
    }

    ulong unhash(const string input, const string alphabet) pure const{
        ulong num = 0;
        for (int i = 0; i < input.length; i++){
            ulong pos = alphabet.indexOf(input[i]);
            num += pos * pow(alphabet.length.to!ulong, (input.length - i - 1).to!ulong);
        }

        return num;
    }

    public:

    this(const string _salt="", const uint _minHashLength=0, const string _alphabet=ALPHABET) pure {
        this.salt = _salt;
        this.minHashLength = _minHashLength;

        seps = "";
        alphabet = "";
        foreach(s ; SEPS){
            if(_alphabet.indexOf(s) != -1){
                seps ~= s;
            }
        }

        string uniqueAlphabet = "";
        foreach (s ; _alphabet) {
            if(uniqueAlphabet.indexOf(s) == -1){
                uniqueAlphabet ~= s;
                if(seps.indexOf(s) == -1) {
                    alphabet ~= s;
                }
            }
        }

        enforce(uniqueAlphabet.length >= minAlphabetLength, format("Alphabet must contain atleast %d unique characters.", minAlphabetLength));
        enforce(uniqueAlphabet.indexOf(' ') == -1, "Alphabet cannot contain spaces (' ').");

        seps = consistentShuffle(seps, salt);

        if (!seps.length || (alphabet.length.to!float / seps.length.to!float) > sepDiv) {

            int sepslength = ceil(alphabet.length / sepDiv).to!int;
            if(sepslength == 1) sepslength++;

            if(sepslength > seps.length) {
                int diff = cast (int) (sepslength - seps.length);
                seps = seps ~ alphabet[0..diff];
                alphabet = alphabet[diff..$];
            } else {
                seps = seps[0..sepslength];
            }
        }
        alphabet = consistentShuffle(alphabet, salt);
        int guardCount = ceil(alphabet.length / guardDiv).to!int;

        if(alphabet.length < 3) {
            guards = seps[0..guardCount];
            seps = seps[guardCount..$];
        } else {
            guards = alphabet[0..guardCount];
            alphabet = alphabet[guardCount..$];
        }
    }


    string encode(const ulong[] numbers...) pure const{
        string res = "";

        if(!numbers.length) return res;

        string alphas = alphabet;

        ulong numbersHash;
        foreach(i, num; numbers) {
            numbersHash += (num % (i + 100));
        }

        char lottery = alphabet[numbersHash % $];
        res ~= lottery;

        foreach(i, number; numbers){
            string buffer = lottery ~ salt ~ alphas;
            string tempsalt = buffer[0..alphas.length];
            alphas = consistentShuffle(alphas, tempsalt);
            string last = hash(number, alphas);
            res ~= last;

            if(i + 1 < numbers.length){
                res ~= seps[(number % (last[0] + i)) % $];
            }
        }

        if(res.length < minHashLength) {
            res = guards[(numbersHash + res[0]) % $] ~ res;
            if(res.length < minHashLength) {
                res ~= guards[(numbersHash + res[2]) % $];
            }
        }

        int halflen = cast (int) (alphas.length / 2);
        while (res.length < minHashLength){
            alphas = consistentShuffle(alphas, alphas);
            res = alphas[halflen..$] ~ res ~ alphas[0..halflen];

            int excess = cast (int) (res.length - minHashLength);
            if (excess > 0){
                int half = excess/2;
                res = res[half..half+minHashLength];
            }
        }

        return res;
    }

    ulong[] decode(const string hash) const {
        ulong[] res = [];

        auto gr = regex("[" ~ guards ~ "]", "g");
        auto sr = regex("[" ~ seps ~ "]", "g");

        string[] hashes = hash.split(gr);
        if(!hashes.length) return [];

        int i = 0;
        if (hashes.length == 3 || hashes.length == 2){
            i = 1;
        }
        string breakdown = hashes[i];
        char lottery = breakdown[0];
        breakdown = breakdown[1..$];

        string[] subhashes = breakdown.split(sr);

        string alphas = alphabet;
        foreach(subhash; subhashes) {
            string buffer = lottery ~ salt ~ alphas;
            alphas = consistentShuffle(alphas, buffer[0..alphas.length]);
            res ~= unhash(subhash, alphas);
        }

        if (encode(res) != hash){
            return [];
        }
        return res;
    }

    string encodeHex(const string hex) const {
        auto hexregex = ctRegex!(r"^[0-9a-fA-F]*$");
        if(!hex.match(hexregex)) return "";
        ulong[] numbers = [];
        for(int i = 0; i < hex.length; i += 12){
            string hn = "1" ~ hex[i..min($, i+12)];
            numbers ~= hn.to!ulong(16);
        }
        return encode(numbers);
    }

    string decodeHex(const string hash) const {
        ulong[] numbers = decode(hash);
        string res = "";
        foreach(num ; numbers) {
            res ~= num.to!string(16)[1..$];
        }
        return res;
    }
}

unittest {
    assert(new Hashids().encode() == "");

    assert(new Hashids().encode(1, 2, 3) == "o2fXhV");

    auto h = new Hashids();
    assert(h.encode(12345) == "j0gW");
    assert(h.encode(1) == "jR");
    assert(h.encode(22) == "Lw");
    assert(h.encode(333) == "Z0E");
    assert(h.encode(9999) == "w0rR");

    assert(h.encode(683, 94108, 123, 5) == "vJvi7On9cXGtD");
    assert(h.encode(1, 2, 3) == "o2fXhV");
    assert(h.encode(2, 4, 6) == "xGhmsW");
    assert(h.encode(99, 25) == "3lKfD");

    h = new Hashids("Arbitrary string");
    assert(h.encode(683, 94108, 123, 5) == "QWyf8yboH7KT2");
    assert(h.encode(1, 2, 3) == "neHrCa");
    assert(h.encode(2, 4, 6) == "LRCgf2");
    assert(h.encode(99, 25) == "JOMh1");

    h = new Hashids ("", 0, "!\"#%&',-/0123456789:;<=>ABCDEFGHIJKLMNOPQRSTUVWXYZ_`abcdefghijklmnopqrstuvwxyz~");
    assert(h.encode(2839, 12, 32, 5) == "_nJUNTVU3");
    assert(h.encode(1, 2, 3) == "7xfYh2");
    assert(h.encode(23832) == "Z6R>");
    assert(h.encode(99, 25) == "AYyIB");

    h = new Hashids("", 25);
    assert(h.encode(7452, 2967, 21401) == "pO3K69b86jzc6krI416enr2B5");
    assert(h.encode(1, 2, 3) == "gyOwl4B97bo2fXhVaDR0Znjrq");
    assert(h.encode(6097) == "Nz7x3VXyMYerRmWeOBQn6LlRG");
    assert(h.encode(99, 25) == "k91nqP3RBe3lKfDaLJrvy8XjV");

    h = new Hashids("arbitrary salt", 16, "abcdefghijklmnopqrstuvwxyz");
    assert(h.encode(7452, 2967, 21401) == "wygqxeunkatjgkrw");
    assert(h.encode(1, 2, 3) == "pnovxlaxuriowydb");
    assert(h.encode(60125) == "jkbgxljrjxmlaonp");
    assert(h.encode(99, 25) == "erdjpwrgouoxlvbx");

    h = new Hashids("", 0, "abdegjklmnopqrvwxyzABDEGJKLMNOPQRVWXYZ1234567890");
    assert(h.encode(7452, 2967, 21401) == "X50Yg6VPoAO4");
    assert(h.encode(1, 2, 3) == "GAbDdR");
    assert(h.encode(60125) == "5NMPD");
    assert(h.encode(99, 25) == "yGya5");

    h = new Hashids("", 0, "abdegjklmnopqrvwxyzABDEGJKLMNOPQRVWXYZ1234567890uC");
    assert(h.encode(7452, 2967, 21401) == "GJNNmKYzbPBw");
    assert(h.encode(1, 2, 3) == "DQCXa4");
    assert(h.encode(60125) == "38V1D");
    assert(h.encode(99, 25) == "373az");

    assert(new Hashids().encodeHex("507f1f77bcf86cd799439011") == "y42LW46J9luq3Xq9XMly");
    assert(new Hashids("", 1000).encodeHex("507f1f77bcf86cd799439011").length >= 1000);
    assert(new Hashids().encodeHex( "f000000000000000000000000000000000000000000000000000000000000000000000000000000000000f") == "WxMLpERDrmh25Lp4L3xEfM6WovWYO3IjkRMKR2ogCMVzn4zQlqt1WK8jKq7OsEpy2qyw1Vi2p");

    assert(new Hashids().encodeHex("") == "");
    assert(new Hashids().encodeHex("1234SGT8") == "");

    assert(new Hashids().decode("") == []);

    assert(new Hashids().decode("o2fXhV") == [1, 2, 3]);

    h = new Hashids();
    assert(h.decode("j0gW") == [12345]);
    assert(h.decode("jR") == [1]);
    assert(h.decode("Lw") == [22]);
    assert(h.decode("Z0E") == [333]);
    assert(h.decode("w0rR") == [9999]);

    assert(h.decode("vJvi7On9cXGtD") == [683, 94108, 123, 5]);
    assert(h.decode("o2fXhV") == [1, 2, 3]);
    assert(h.decode("xGhmsW") == [2, 4, 6]);
    assert(h.decode("3lKfD") == [99, 25]);

    h = new Hashids("Arbitrary string");
    assert(h.decode("QWyf8yboH7KT2") == [683, 94108, 123, 5]);
    assert(h.decode("neHrCa") == [1, 2, 3]);
    assert(h.decode("LRCgf2") == [2, 4, 6]);
    assert(h.decode("JOMh1") == [99, 25]);

    h = new Hashids("", 0, "!\"#%&\',-/0123456789:;<=>ABCDEFGHIJKLMNOPQRSTUVWXYZ_`abcdefghijklmnopqrstuvwxyz~");
    assert(h.decode("_nJUNTVU3") == [2839, 12, 32, 5]);
    assert(h.decode("7xfYh2") == [1, 2, 3]);
    assert(h.decode("Z6R>") == [23832]);
    assert(h.decode("AYyIB") == [99, 25]);

    h = new Hashids("", 25);
    assert(h.decode("pO3K69b86jzc6krI416enr2B5") == [7452, 2967, 21401]);
    assert(h.decode("gyOwl4B97bo2fXhVaDR0Znjrq") == [1, 2, 3]);
    assert(h.decode("Nz7x3VXyMYerRmWeOBQn6LlRG") == [6097]);
    assert(h.decode("k91nqP3RBe3lKfDaLJrvy8XjV") == [99, 25]);

    h = new Hashids("arbitrary salt", 16, "abcdefghijklmnopqrstuvwxyz");
    assert(h.decode("wygqxeunkatjgkrw") == [7452, 2967, 21401]);
    assert(h.decode("pnovxlaxuriowydb") == [1, 2, 3]);
    assert(h.decode("jkbgxljrjxmlaonp") == [60125]);
    assert(h.decode("erdjpwrgouoxlvbx") == [99, 25]);

    assert(new Hashids("", 0, "abcdefghijklmnop").decode("qrstuvwxyz") == []);

    h = new Hashids("", 0, "abdegjklmnopqrvwxyzABDEGJKLMNOPQRVWXYZ1234567890");
    assert(h.decode("X50Yg6VPoAO4") == [7452, 2967, 21401]);
    assert(h.decode("GAbDdR") == [1, 2, 3]);
    assert(h.decode("5NMPD") == [60125]);
    assert(h.decode("yGya5") == [99, 25]);

    h = new Hashids("", 0, "abdegjklmnopqrvwxyzABDEGJKLMNOPQRVWXYZ1234567890uC");
    assert(h.decode("GJNNmKYzbPBw") == [7452, 2967, 21401]);
    assert(h.decode("DQCXa4") == [1, 2, 3]);
    assert(h.decode("38V1D") == [60125]);
    assert(h.decode("373az") == [99, 25]);

    auto hex_str = "507F1F77BCF86CD799439011";
    assert(new Hashids().decodeHex("y42LW46J9luq3Xq9XMly") == hex_str);
    h = new Hashids("", 1000);
    assert(h.decodeHex(h.encodeHex(hex_str)) == hex_str);
    assert(new Hashids().decodeHex("WxMLpERDrmh25Lp4L3xEfM6WovWYO3IjkRMKR2ogCMVzn4zQlqt1WK8jKq7OsEpy2qyw1Vi2p") ==                "F000000000000000000000000000000000000000000000000000000000000000000000000000000000000F");

    assert(new Hashids().decodeHex("") == "");
    assert(new Hashids().decodeHex("WxMLpERDrmh25Lp4L3xEfM6WovWYO3IjkRMKR2ogCMVlqt1WK8jKq7OsEp1Vi2p") == "");
}
