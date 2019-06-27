import Page from "page";

export default interface IViewComponent
{
    parent: Page;

    run (): Promise<void>;
}
