import View from "renderer/view";
import { isLoggedIn } from "api/auth";
import Modal from "components/modal";
import Router from "router/router";

export default class Header extends View
{
    private loginModal: Modal;

    private router: Router;

    public constructor (router: Router)
    {
        super ();

        this.router = router;
    }

    public render (): string
    {
        /* tslint:disable:max-line-length */
        return `<h1><img class="icon" src="/assets/icons/pastemyst.svg" alt="icon"/><a route="/">PasteMyst</a></h1><p class="description">a simple website for storing and sharing code snippets.
version 2.0.0 (<a href="#" target="_blank">changelog</a>).</p><div class="modal" id="login-modal"><div class="content"><div class="head"><p class="title">login</p><ion-icon class="exit" name="close"></ion-icon></div><div class="body"><p>logging in with github you'll be able to do many more things, like seeing a list of all pastes you made, creating private pastes which can only be accessed with your account, labeling pastes and organizing them, and much more.</p><p>only your github id and username will be stored to uniquely identify you and nothing more.</p></div><div class="footer"><a href="http://api.paste.myst/auth/github">login with github</a></div></div></div><nav><ul><li><a route="/">home</a> - </li><li><a id="login">login</a> - </li><li><a href="https://github.com/codemyst/pastemyst" target="_blank">github</a> - </li><li><a href="/api-docs">api docs</a></li></ul></nav>`;
        /* tslint:enable:max-line-length */
    }
    
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
            this.loginModal = new Modal ("login-modal");
            await this.loginModal.run ();

            loginElement.addEventListener ("click", () =>
            {
                this.loginModal.open ();
            });
        }
    }
}
