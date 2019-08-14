import { apiEndpoint } from "api";
import User from "data/user";
import { getJwt } from "security/cookies";

export async function getUser (): Promise<User>
{
    // TODO: Token might not exists!

    const jwtCookie: string = getJwt ();

    const response: Response = await fetch (`${apiEndpoint}/user`,
    {
        method: "GET",
        headers:
        {
            Authorization: `Bearer ${jwtCookie}`
        }
    });

    return JSON.parse (await response.text ());
}
