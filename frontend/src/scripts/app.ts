import { Route, Router } from "router/router";
import { HomePage } from "views/home";
import { PastePage } from "views/paste";

let router: Router;

function initRouter ()
{
    router = new Router ();
    router.addRoute (new Route ("/", "Home", new HomePage ()));
    router.addRoute (new Route ("/:id", "Paste", new PastePage ()));
    router.init ();
}

window.addEventListener ("popstate", () => initRouter ());

initRouter ();
