module pastemyst.auth.jwt;

import pastemyst.data : User;

public string getUserJwt(User user)
{
    import stringbuffer : StringBuffer;
    import fastjwt.jwt : encodeJWTToken, JWTAlgorithm;
    import pastemyst.data : config;

    StringBuffer sb;
    encodeJWTToken(sb, JWTAlgorithm.HS512, config.jwt.secret, "sub", user.id, "name", user.username);

    return sb.getData().dup;
}
