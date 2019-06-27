import IViewComponent from "viewComponent";

export default abstract class Page
{
    public viewComponents: IViewComponent [] = new Array<IViewComponent> ();

    public abstract async render (): Promise<string>;
    public abstract async run (): Promise<void>;

    public async runComponents (): Promise<void>
    {
        this.viewComponents.forEach (async (component) =>
        {
            await component.run ();
        });
    }

    public addComponent (component: IViewComponent): void
    {
        this.viewComponents.push (component);
        component.parent = this;
    }

    // public getComponent<T extends IViewComponent> (component: T): T
    // {
    //     this.viewComponents.forEach ((c: IViewComponent) =>
    //     {
    //         if ((c as any).name === (component as any).name)
    //         {
    //             return c;
    //         }
    //     });

    //     return null;
    // }

    // public getComponents<T extends IViewComponent> (component: IViewComponent): IViewComponent []
    // {
    //     const res: IViewComponent [] = new Array<IViewComponent> ();

    //     this.viewComponents.forEach ((c: IViewComponent) =>
    //     {
    //         if ((c as any).name === (component as any).name)
    //         {
    //             res.push (c);
    //         }
    //     });

    //     return res;
    // }
}
