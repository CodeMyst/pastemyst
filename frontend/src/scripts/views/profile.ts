import { getUser } from "api/user";
import User from "data/user";
import { deleteCookie } from "security/cookies";
import View from "renderer/view";
import Router from "router/router";
import { isLoggedIn } from "api/auth";

export default class Profile extends View
{
    private router: Router;

    public constructor (router: Router)
    {
        super ();

        this.router = router;
    }

    public render (): string
    {
        /* tslint:disable:max-line-length */
        return `<div id="profile-header"><img class="avatar"/><p class="username"></p><a class="logout">logout</a></div>`;
        /* tslint:enable:max-line-length */        
    }

    public async run (): Promise<void>
    {
        if (!(await isLoggedIn ()))
        {
            this.router.navigate ("/");
            return;
        }

        const user: User = await getUser ();

        console.log (user);

        const header = document.getElementById ("profile-header");

        header.getElementsByClassName ("avatar") [0].setAttribute ("src", user.avatar);
        header.getElementsByClassName ("username") [0].textContent = user.username;

        header.getElementsByClassName ("logout") [0].addEventListener ("click", (event) =>
        {
            deleteCookie ("github", "/");
            this.router.navigate ("/");
        });
    }
}
