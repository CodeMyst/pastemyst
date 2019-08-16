import View from "view";

export default class Part
{
    public name: string;

    public element: HTMLElement;

    public view: View;

    public constructor (name: string)
    {
        this.name = name;
    }

    public setView (view: View): void
    {
        this.view = view;
    }
}
