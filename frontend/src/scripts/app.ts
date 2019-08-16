import Renderer from "renderer/renderer";
import Part from "renderer/part";
import Header from "views/header";
import Footer from "views/footer";
import Home from "views/home";
import Paste from "views/paste";
import Logged from "views/logged";
import Profile from "views/profile";
import Router from "router/router";
import Route from "router/route";

async function init (): Promise<void>
{
    const header: Part = new Part ("header");
    const body: Part = new Part ("body");
    const footer: Part = new Part ("footer");

    const router: Router = new Router ();
    const renderer: Renderer = new Renderer ();

    renderer.addPart (header);
    renderer.addPart (body);
    renderer.addPart (footer);

    header.setView (new Header (router));
    footer.setView (new Footer ());

    await renderer.init ();

    router.addRoute (new Route ("/", "Home"));
    router.addRoute (new Route ("/:id", "Paste"));
    router.addRoute (new Route ("/logged", "Logged"));
    router.addRoute (new Route ("/profile", "Profile"));

    router.onRouteChange = (route: Route) =>
    {
        // TODO: Clean this
        if (!router.currentRoute || router.currentRoute !== route)
        {
            if (route.path === "/")
            {
                body.setView (new Home ());
            }
            else if (route.path === "/:id")
            {
                body.setView (new Paste ());
            }
            else if (route.path === "/logged")
            {
                body.setView (new Logged (router));
            }
            else if (route.path === "/profile")
            {
                body.setView (new Profile (router));
            }
            
            renderer.drawView (body);
        }
    };

    await router.init ();
}

init ();
