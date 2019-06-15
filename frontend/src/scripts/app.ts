import { Route, Router } from "router/router";
import { Home } from "views/home";
import { Paste } from "views/paste";

let router: Router;

function initRouter ()
{
    router = new Router ();
    router.addRoute (new Route ("/", "Home", new Home ()));
    router.addRoute (new Route ("/:id", "Paste", new Paste ()));
    router.init ();
}

window.addEventListener ("popstate", () => initRouter ());

initRouter ();
