import { Paste, PasteCreateInfo } from "../data/paste";
import { apiEndpoint } from "api";

export async function postPaste (paste: PasteCreateInfo): Promise<Paste>
{
    const response: Response = await fetch (`${apiEndpoint}/paste`,
    {
        method: "POST",
        headers:
        {
            "Content-Type": "application/json"
        },
        body: JSON.stringify (paste)
    });

    return (JSON.parse (await response.text ()));
}

export async function getPaste (id: string): Promise<Paste>
{
    const response: Response = await fetch (`${apiEndpoint}/paste/${id}`,
    {
        method: "GET"
    });

    const paste: Paste = JSON.parse (await response.text ());

    return paste;
}
