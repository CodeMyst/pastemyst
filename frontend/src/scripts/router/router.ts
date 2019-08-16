import Route from "route";

export type OnRouteChangeDelegate = (route: Route) => void;

export default class Router
{
    public routes: Route [] = new Array<Route> ();

    public onRouteChange: OnRouteChangeDelegate;

    public currentRoute: Route;

    private links: HTMLElement [] = new Array<HTMLElement> ();

    public constructor ()
    {
        window.addEventListener ("popstate", async () => await this.init ());
    }

    public addRoute (route: Route): void
    {
        this.routes.push (route);
    }

    public async init (): Promise<void>
    {
        // NOTE: This will get run every time the route changes.

        const path: string = this.parseRequestUrl ();

        let route: Route = this.routes.find ((r) => r.path === path);
    
        // TODO: Not the best solution for this...
        if (!route)
        {
            route = this.routes.find ((r) => r.path === "/:id");
        }

        if (this.onRouteChange)
        {
            this.onRouteChange (route);
        }

        document.querySelectorAll ("[route]").forEach ((element: HTMLElement) =>
        {
            if (!this.links.some ((l) => l === element))
            {
                this.registerLink (element);
            }
        });

        this.currentRoute = route;
    }

    public registerLink (link: HTMLElement): void
    {
        link.addEventListener ("click", (event) => this.navigateElement (event.target as HTMLElement));
        this.links.push (link);
    }

    public async navigate (path: string): Promise<void>
    {
        const route: Route = this.routes.find ((r) => r.path === path);

        if (!route)
        {
            console.error (`Route ${path} doesn't exist!`);
            return;
        }

        window.history.pushState ({}, document.title, route.path);
        window.dispatchEvent (new Event ("popstate"));
    }

    private async navigateElement (element: HTMLElement): Promise<void>
    {
        const routeAttr: Attr = element.attributes.getNamedItem ("route");

        if (!routeAttr)
        {
            console.error ("Element doesn't have a route attribute!");
            return;
        }

        const routePath: string = routeAttr.value;

        this.navigate (routePath);
    }

    private parseRequestUrl (): string
    {
        return window.location.pathname.toLowerCase () || "/";
    }
}
