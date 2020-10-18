module pastemyst.auth.session;

import vibe.d;
import pastemyst.data;

///
public struct Session
{
    ///
    public MinimalUser user;

    ///
    public bool loggedIn() const @safe
    {
        return this != Session.init;
    }
}

private const string cookieName = "session.myst";

private Session[string] sessions;

/++
 + starts a session and fills it with the provided session struct
 +/
public void startSession(ref HTTPServerRequest req, ref HTTPServerResponse res, Session session) @safe
{
    import std.datetime : Clock;
    import std.string : startsWith;
    import pastemyst.data : config;

    if (cookieName in req.cookies)
    {
        if (req.cookies.get(cookieName) in sessions)
        {
            return;
        }
    }

    string id = generateRandomSessionId();

    auto cookie = new Cookie();
    cookie.expires = Clock.currTime.add!"months"(1);
    cookie.httpOnly = true;
    cookie.sameSite(Cookie.SameSite.strict);
    cookie.value = id;
    cookie.path = "/";

    if (config.hostname.startsWith("https"))
    {
        cookie.secure = true;
    }

    res.cookies.addField(cookieName, cookie);

    sessions[id] = session;
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
    if (cookieName in req.cookies)
    {
        auto id = req.cookies.get(cookieName);

        if (id in sessions)
        {
            return sessions[id];
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
    enforceHTTP(cookieName in req.cookies, HTTPStatus.badRequest, "session not started");

    auto id = req.cookies.get(cookieName);

    enforceHTTP(id in sessions, HTTPStatus.badRequest, "invalid session id");

    sessions[id] = session;
}

/++
 + returns the user struct identified with the provided session struct
 +/
public User getSessionUser(Session session) @safe
{
    import pastemyst.db : findOneById;

    if (session == Session.init)
    {
        return User.init;
    }

    auto res = findOneById!User(session.user.id);

    if (res.isNull)
    {
        return User.init;
    }
    
    return res.get();
}

/++
 + ends the session
 +/
public void endSession(ref HTTPServerRequest req, ref HTTPServerResponse res) @safe
{
    if (cookieName in req.cookies)
    {
        res.setCookie(cookieName, null);
    }
}

private string generateRandomSessionId() @safe
{
    import pastemyst.encoding : randomBase36Id;

    string id;

    do
    {
        id = randomBase36Id();
    } while(id in sessions);

    return id;
}
