import Part from "part";

export default class Renderer
{
    private parts: Part [] = [];

    public addPart (part: Part): void
    {
        this.parts.push (part);
    }

    public async init (): Promise<void>
    {
        const content = document.getElementById ("container");

        this.parts.forEach (async (part) =>
        {
            const element: HTMLElement = document.createElement ("div");
            element.setAttribute ("id", part.name);

            part.element = element;

            part.element.style.display = "none";

            if (part.view)
            {
                part.element.innerHTML = part.view.render ();
            }
            
            content.appendChild (part.element);

            if (part.view)
            {
                await part.view.run ().then (async () =>
                {
                    if (part.element.attributes.getNamedItem ("style"))
                    {
                        part.element.attributes.removeNamedItem ("style");
                    }

                    await part.view.postRun ();
                });
            }
        });
    }

    public async drawView (part: Part): Promise<void>
    {
        if (part.view)
        {
            part.element.style.display = "none";
            part.element.innerHTML = part.view.render ();
            await part.view.run ().then (async () =>
            {
                if (part.element.attributes.getNamedItem ("style"))
                {
                    part.element.attributes.removeNamedItem ("style");
                }

                await part.view.postRun ();
            });
        }
    }
}
