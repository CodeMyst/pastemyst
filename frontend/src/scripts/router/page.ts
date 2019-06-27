import IViewComponent from "viewComponent";

export default abstract class Page
{
    private viewComponents: IViewComponent [] = new Array<IViewComponent> ();

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
    }
}
