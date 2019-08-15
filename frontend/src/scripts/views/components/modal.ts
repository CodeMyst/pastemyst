import ViewComponent from "router/viewComponent";
import Router from "router/router";

export default class Modal extends ViewComponent
{
    public name: string;

    private modalElement: HTMLElement;
    private closeButton: Element;

    public constructor (router: Router, name: string)
    {
        super (router);

        this.name = name;
    }

    public async run (): Promise<void>
    {
        this.modalElement = document.getElementById (this.name);
        this.closeButton = this.modalElement.getElementsByClassName ("exit") [0];

        this.closeButton.addEventListener ("click", () =>
        {
            this.modalElement.style.display = "none";
        });

        window.addEventListener ("click", (event: Event) =>
        {
            if (event.target === this.modalElement)
            {
                this.modalElement.style.display = "none";
            }
        });
    }

    public open (): void
    {
        this.modalElement.style.display = "block";
    }
}
