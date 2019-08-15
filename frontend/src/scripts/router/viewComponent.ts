import Page from "page";
import Router from "router";

export default abstract class ViewComponent
{
    public parent: Page;
    
    protected router: Router;
    
    public constructor (router: Router)
    {
        this.router = router;
    }

    public abstract run (): Promise<void>;
}
