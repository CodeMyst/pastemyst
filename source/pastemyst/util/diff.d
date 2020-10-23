module pastemyst.util.diff;

import std.exception : basicExceptionCtors;

/++
 + simple diff exception
 +/
public final class DiffException : Exception
{
    mixin basicExceptionCtors;
}

/++
 + generates a diff string between two pasty contents
 +/
public string generateDiff(string id, string before, string after) @safe
{
    import std.array : replace;
    import std.exception : enforce;
    import std.file : exists, mkdir, remove, rmdir, tempDir, write;
    import std.format : format;
    import std.path : buildPath;
    import std.process : execute;
    import std.uuid : randomUUID;

    string dirPath;
    do
    {
        dirPath = buildPath(tempDir(), "pastemystv2-"~randomUUID().toString());
    } while (dirPath.exists);

    // make a temporary directory in your temporary space
    dirPath.mkdir;
    scope(exit) dirPath.rmdir;

    immutable fileBefore = buildPath(dirPath, id~"-before");
    immutable fileAfter = buildPath(dirPath, id~"-after");
    scope(exit)
    {
        fileAfter.remove;
        fileBefore.remove;
    }

    write(fileBefore, before.replace("\r\n", "\n"));
    write(fileAfter, after.replace("\r\n", "\n"));

    const diff = execute(["diff", "-u", fileBefore, fileAfter]);

    enforce!DiffException(diff.status != 2,
        format!"Error while trying to calculate the diff between the pastes with id: %s! Output: %s."(id, diff.output)
    );

    return diff.output;
}

/++
 + generated a string from patching a diff
 +/
public string patchDiff(string id, string current, string diff) @safe
{
    import std.array : replace;
    import std.file : exists, mkdir, readText, remove, rmdir, tempDir, write;
    import std.path : buildPath;
    import std.process : pipeProcess, Redirect, wait;
    import std.uuid : randomUUID;

    string dirPath;
    do
    {
        dirPath = buildPath(tempDir(), "pastemystv2-"~randomUUID().toString());
    } while (dirPath.exists);

    // make a temporary directory in your temporary space
    dirPath.mkdir;
    scope(exit) dirPath.rmdir;

    immutable fileCurrent = buildPath(dirPath, id~"-current");
    scope(exit) fileCurrent.remove;

    write(fileCurrent, current.replace("\r\n", "\n"));
    auto pp = pipeProcess(["patch", "-R", fileCurrent], Redirect.stdin);

    pp.stdin.write(diff.replace("\r\n", "\n"));
    pp.stdin.flush();
    pp.stdin.close();
    wait(pp.pid);

    return readText(fileCurrent);
}
