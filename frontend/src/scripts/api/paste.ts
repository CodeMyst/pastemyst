import { Paste, PasteCreateInfo } from "../data/paste";
import { apiEndpoint } from "api";

export async function postPaste (paste: PasteCreateInfo)
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
