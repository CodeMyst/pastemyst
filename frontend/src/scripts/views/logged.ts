import Page from "router/page";

// This page exists because the token cookie is added after the page loads, this page will redirect to the home page.
export class LoggedPage extends Page
{
    public async render (): Promise<string>
    {
        return "";
    }
    
    public async run (): Promise<void>
    {
        // TODO: Specify a proper url
        window.location.href = "http://paste.myst";
    }
}
