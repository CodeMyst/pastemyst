import { apiEndpoint } from "api";

export async function getExpireOptions (): Promise<ExpireOption []>
{
    const response = await fetch (`${apiEndpoint}/expireOptions`);
    return (JSON.parse (await response.text ())).expireOptions;
}

export class ExpireOption
{
    public value: string;
    public pretty: string;
}