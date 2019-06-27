import IViewComponent from "router/viewComponent";
import { isLoggedIn } from "api/auth";

export default class Navigation implements IViewComponent
{
    public async run (): Promise<void>
    {
        const loggedIn: boolean = await isLoggedIn ();

        if (loggedIn)
        {
            const loginElement: Element = document.getElementById ("login");
            loginElement.removeAttribute ("href");
            loginElement.setAttribute ("route", "/profile");
            loginElement.textContent = "profile";
        }
    }
}
