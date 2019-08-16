export default class Route
{
    public path: string;
    public name: string;

    constructor (path: string, name: string)
    {
        this.path = path;
        this.name = name;
    }
}
