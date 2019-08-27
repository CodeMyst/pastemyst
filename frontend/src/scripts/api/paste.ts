import { Paste, PasteCreateInfo } from "../data/paste";
import { apiEndpoint } from "api";
import { isLoggedIn } from "auth";
import { getJwt } from "security/cookies";

export async function postPaste (paste: PasteCreateInfo): Promise<Paste>
{
    const isLogged: boolean = await isLoggedIn ();
    let token: string;

    if (isLogged)
    {
        token = getJwt ();
    }

    const requestHeaders: Headers = new Headers ();

    requestHeaders.append ("Content-Type", "application/json");

    if (isLogged)
    {
        requestHeaders.append ("Authorization", `Bearer ${token}`);
    }

    const response: Response = await fetch (`${apiEndpoint}/paste`,
    {
        method: "POST",
        headers: requestHeaders,
        body: JSON.stringify (paste)
    });

    return (JSON.parse (await response.text ()));
}

export async function getPaste (id: string): Promise<Paste>
{
    const isLogged: boolean = await isLoggedIn ();
    let token: string;

    if (isLogged)
    {
        token = getJwt ();
    }

    const requestHeaders: Headers = new Headers ();

    requestHeaders.append ("Content-Type", "application/json");

    if (isLogged)
    {
        requestHeaders.append ("Authorization", `Bearer ${token}`);
    }

    const response: Response = await fetch (`${apiEndpoint}/paste/${id}`,
    {
        method: "GET",
        headers: requestHeaders
    });

    const paste: Paste = JSON.parse (await response.text ());

    return paste;
}
