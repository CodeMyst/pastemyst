import IViewComponent from "router/viewComponent";
import { isLoggedIn } from "api/auth";
import Page from "router/page";
import Modal from "modal";

export default class Navigation implements IViewComponent
{
    public parent: Page;

    public async run (): Promise<void>
    {
        const loggedIn: boolean = await isLoggedIn ();
        
        const loginElement: HTMLElement = document.getElementById ("login");

        if (loggedIn)
        {
            loginElement.setAttribute ("route", "/profile");
            loginElement.textContent = "profile";
        }
        else
        {
            this.parent.viewComponents.forEach ((component: IViewComponent) =>
            {
                const loginModal: Modal = component as Modal;

                if (loginModal !== null && loginModal.name === "login-modal")
                {
                    loginElement.addEventListener ("click", () =>
                    {
                        loginModal.open ();
                    });
                }
            });
        }
    }
}
