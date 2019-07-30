import { apiEndpoint } from "api";

export async function isLoggedIn (): Promise<boolean>
{
    const jwtCookie: string = getCookie ("github");

    if (jwtCookie === null)
    {
        console.log ("reee");
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

export async function getJwt (): Promise<string>
{
    const jwtCookie: string = getCookie ("github");

    if (jwtCookie !== null)
    {
        return jwtCookie;
    }
}

function getCookie (name: string): string
{
    const nameEQ: string = name + "=";
    const cookies: string [] = document.cookie.split(";");
    
    for (let i: number = 0; i < cookies.length; i++)
    {
        let cookie: string = cookies [i];
        
        while (cookie.charAt (0) === " ")
        {
            cookie = cookie.substring (1, cookie.length);
        }

        if (cookie.indexOf (nameEQ) === 0)
        {
            return cookie.substring (nameEQ.length, cookie.length);
        }
    }

    return null;
}
