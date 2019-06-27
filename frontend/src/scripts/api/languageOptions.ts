import { apiEndpoint } from "api";

export async function getLanguageOptions (): Promise<LanguageOption []>
{
    const response = await fetch (`${apiEndpoint}/languages`);
    return (JSON.parse (await response.text ())).languages;
}

export class LanguageOption
{
    public name: string;
    public mimes: string [];
    public mode: string;
}
