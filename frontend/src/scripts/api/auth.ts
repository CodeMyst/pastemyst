import { apiEndpoint } from "api";
import { getJwt } from "security/cookies";

export async function isLoggedIn (): Promise<boolean>
{
    const jwtCookie: string = getJwt ();

    if (jwtCookie === "")
    {
        return false;
    }
    else
    {
        const response: Response = await fetch (`${apiEndpoint}/auth/isValidUser`,
        {
            method: "GET",
            headers:
            {
                Authorization: `Bearer ${jwtCookie}`
            }
        });

        return JSON.parse (await response.text ());
    }
}
