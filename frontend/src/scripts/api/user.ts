import { apiEndpoint } from "api";
import User from "data/user";
import { getJwt } from "security/cookies";
import { Paste } from "data/paste";

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

export async function getUserPastes (): Promise<Paste []>
{
    const jwtCookie: string = getJwt ();

    const respose: Response = await fetch (`${apiEndpoint}/user/pastes`,
    {
        method: "GET",
        headers:
        {
            Authorization: `Bearer ${jwtCookie}`
        }
    });

    return JSON.parse (await respose.text ());
}
