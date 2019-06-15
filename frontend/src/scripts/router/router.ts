export class Route
{
    path: string;
    name: string;
    page: Page;

    constructor (path: string, name: string, page: Page)
    {
        this.path = path;
        this.name = name;
        this.page = page;
    }
}

export abstract class Page
{
    abstract async render (): Promise<string>;
    abstract async run (): Promise<void>;
}

export class Router
{
    routes: Array<Route> = new Array<Route> ();

    addRoute (route: Route): void
    {
        this.routes.push (route);
    }

    async init (): Promise<void>
    {
        const content: HTMLElement = null || document.getElementById ("container");
        let request: string = this.parseRequestUrl ();

        let page: Page;
        if (this.routes.some ((r) => r.path == request))
        {
            page = this.routes.find ((r) => r.path == request).page;
        }
        else
        {
            // TODO: Check if ID exists, otherwise return 404
            page = this.routes.find ((r) => r.path == "/:id").page;
        }

        content.innerHTML = await page.render ();
        await page.run ();
    }

    parseRequestUrl (): string
    {
        return window.location.pathname.toLowerCase () || "/";
    }
}
