import Page from "page";

export default class Route
{
    public path: string;
    public name: string;
    public page: Page;

    constructor (path: string, name: string, page: Page)
    {
        this.path = path;
        this.name = name;
        this.page = page;
    }
}
