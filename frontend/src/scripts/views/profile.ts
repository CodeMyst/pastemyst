import Page from "router/page";
import Navigation from "components/navigation";
import Modal from "components/modal";
import { getUser } from "api/user";
import User from "data/user";

export class ProfilePage extends Page
{
    public async render (): Promise<string>
    {
        /* tslint:disable:max-line-length */
        return `<h1><img class="icon" src="/assets/icons/pastemyst.svg" alt="icon"/><a route="/">PasteMyst</a></h1><p class="description">a simple website for storing and sharing code snippets.
version 2.0.0 (<a href="#" target="_blank">changelog</a>).</p><div class="modal" id="login-modal"><div class="content"><div class="head"><p class="title">login</p><img class="exit" src="/assets/icons/exit.svg"/></div><div class="body"><p>logging in with github you'll be able to do many more things, like seeing a list of all pastes you made, creating private pastes which can only be accessed with your account, labeling pastes and organizing them, and much more.</p><p>only your github id and username will be stored to uniquely identify you and nothing more.</p></div><div class="footer"><a href="http://api.paste.myst/auth/github">login with github</a></div></div></div><nav><ul><li><a route="/">home</a> - </li><li><a id="login">login</a> - </li><li><a href="https://github.com/codemyst/pastemyst" target="_blank">github</a> - </li><li><a href="/api-docs">api docs</a></li></ul></nav><div id="profile-header"><img class="avatar"/><p class="username"></p><a class="logout">logout</a></div><footer><div class="copyright">copyright &copy; <a href="https://github.com/CodeMyst" target="_blank">CodeMyst</a> 2019</div><div class="paste-amount">1337 currently active pastes</div></footer>`;
        /* tslint:enable:max-line-length */        
}

    public async run (): Promise<void>
    {
        this.addComponent (new Navigation (this.router));
        this.addComponent (new Modal (this.router, "login-modal"));

        const user: User = await getUser ();

        const header = document.getElementById ("profile-header");

        header.getElementsByClassName ("avatar") [0].setAttribute ("src", user.avatar);
        header.getElementsByClassName ("username") [0].textContent = user.username;
    }
}
