import { Page } from "../router/router";

export class Paste extends Page
{
    public async render (): Promise<string>
    {
        return `<p>paste</p>`;
    }

    public async run (): Promise<void> {}
}
