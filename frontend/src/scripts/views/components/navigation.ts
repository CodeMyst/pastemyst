import ViewComponent from "router/viewComponent";
import { isLoggedIn } from "api/auth";
import Modal from "modal";

export default class Navigation extends ViewComponent
{
    public async run (): Promise<void>
    {
        const loggedIn: boolean = await isLoggedIn ();
        
        const loginElement: HTMLElement = document.getElementById ("login");

        if (loggedIn)
        {
            loginElement.setAttribute ("route", "/profile");
            loginElement.textContent = "profile";
            this.router.registerLink (loginElement);
        }
        else
        {
            this.parent.viewComponents.forEach ((component: ViewComponent) =>
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
