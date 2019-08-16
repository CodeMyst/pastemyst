import View from "renderer/view";
import Router from "router/router";

// This page exists because the token cookie is added after the page loads, this page will redirect to the home page.
export default class Logged extends View
{
    private router: Router;

    public constructor (router: Router)
    {
        super ();

        this.router = router;
    }

    public render (): string
    {
        return "";
    }
    
    public async run (): Promise<void>
    {
        this.router.navigate ("/");
        location.reload ();
    }
}
