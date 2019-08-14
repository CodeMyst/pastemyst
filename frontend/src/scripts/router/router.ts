import Page from "page";
import Route from "route";

export default class Router
{
    public routes: Route [] = [];

    public addRoute (route: Route): void
    {
        this.routes.push (route);
    }

    public async init (): Promise<void>
    {
        const content: HTMLElement = null || document.getElementById ("container");
        const request: string = this.parseRequestUrl ();

        let page: Page;
        if (this.routes.some ((r) => r.path === request))
        {
            page = this.routes.find ((r) => r.path === request).page;
        }
        else
        {
            // TODO: Check if ID exists, otherwise return 404
            page = this.routes.find ((r) => r.path === "/:id").page;
        }

        content.innerHTML = await page.render ();
        await page.run ();
        await page.runComponents ();

        const links: NodeListOf<Element> = document.querySelectorAll ("[route]");

        links.forEach ((link: Element) =>
        {
            this.registerLink (link);
        });
    }

    public registerLink (link: Element): void
    {
        link.addEventListener ("click", (event) => this.navigate (event, this.routes), false);
    }

    private parseRequestUrl (): string
    {
        return window.location.pathname.toLowerCase () || "/";
    }

    private async navigate (event: Event, routes: Route []): Promise<void>
    {
        const element: Element = event.target as Element;

        const routeAttr: Attr = element.attributes.getNamedItem ("route");

        if (routeAttr === null)
        {
            console.log ("Link doesn't have a route attribute");
            return;
        }

        const routePath: string = routeAttr.value;

        if (routes.some ((r) => r.path === routePath))
        {
            const route: Route = routes.find ((r) => r.path === routePath);

            window.history.pushState ({}, document.title, route.path);
            window.dispatchEvent (new Event ("popstate"));
        }
        else
        {
            console.log ("Route doesn't exist.");
        }
    }
}
