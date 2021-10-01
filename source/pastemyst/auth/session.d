module pastemyst.auth.session;

import vibe.d;
import pastemyst.data;

///
public struct Session
{
    ///
    @name("_id")
    public string id;

    ///
    public string userId;

    ///
    public long createdAt;

    ///
    public long expiresAt;

    ///
    public bool loggedIn() const @safe
    {
        return this != Session.init;
    }

    /++
     + returns the user struct identified with the provided session struct
     +/
    public User getSessionUser() const @safe
    {
        import pastemyst.db : findOneById;

        if (this == Session.init)
        {
            return User.init;
        }

        auto res = findOneById!User(this.userId);

        if (res.isNull)
        {
            return User.init;
        }

        return res.get();
    }
}

private const string cookieName = "session.myst";

/++
 + starts a session and fills it with the provided session struct
 +/
public void startSession(ref HTTPServerRequest req, ref HTTPServerResponse res, Session session) @safe
{
    import std.datetime : Clock;
    import std.string : startsWith;
    import pastemyst.data : config;
    import pastemyst.db : tryFindOneById, insert;
    import pastemyst.util : generateUniqueId;

    if (cookieName in req.cookies)
    {
        if (!tryFindOneById!Session(req.cookies.get(cookieName)).isNull)
        {
            return;
        }
    }

    string id = generateUniqueId!Session();

    auto currentTime = Clock.currTime();
    auto expiresAt = Clock.currTime().add!"months"(1);

    session.id = id;
    session.createdAt = currentTime.toUnixTime();
    session.expiresAt = expiresAt.toUnixTime();

    auto cookie = new Cookie();
    cookie.expires = expiresAt;
    cookie.httpOnly = true;
    cookie.sameSite(Cookie.SameSite.lax);
    cookie.value = id;
    cookie.path = "/";

    if (config.hostname.startsWith("https"))
    {
        cookie.secure = true;
    }

    res.cookies.addField(cookieName, cookie);

    insert!Session(session);
}

/++
 + starts a session and fills it with a default session struct
 +/
public void startSession(ref HTTPServerRequest req, ref HTTPServerResponse res) @safe
{
    startSession(req, res, Session.init);
}

/++
 + returns the session identified with the specified request
 +/
public Session getSession(ref HTTPServerRequest req) @safe
{
    import pastemyst.db : tryFindOneById;

    if (cookieName in req.cookies)
    {
        auto id = req.cookies.get(cookieName);

        auto ses = tryFindOneById!Session(id);

        if (!ses.isNull)
        {
            return ses.get();
        }
    }

    return Session.init;
}

/++
 + sets an existing sessions session struct.
 + the session cookie has to already exist on the client, this means you can run this function in the same function as you started the session, before the client gets refreshed.
 +/
public void setSession(ref HTTPServerRequest req, ref HTTPServerResponse res, Session session) @safe
{
    import pastemyst.db : tryFindOneById, update;

    enforceHTTP(cookieName in req.cookies, HTTPStatus.badRequest, "session not started");

    auto id = req.cookies.get(cookieName);

    auto ses = tryFindOneById!Session(id);

    enforceHTTP(!ses.isNull, HTTPStatus.badRequest, "invalid session id");

    update!Session(["_id": id], session);
}

/++
 + ends the session
 +/
public void endSession(ref HTTPServerRequest req, ref HTTPServerResponse res) @safe
{
    import pastemyst.db : removeOneById;

    if (cookieName in req.cookies)
    {
        auto id = req.cookies.get(cookieName);

        removeOneById!Session(id);

        res.setCookie(cookieName, null);
    }
}

/++
 + deletes expired sessions
 +/
public void deleteExpiredSessions()
{
    import pastemyst.db : remove;
    import std.datetime : Clock;
    import vibe.d : Bson;

    remove!Session(["expiresAt": ["$lt": Clock.currTime().toUnixTime()]]);
}
