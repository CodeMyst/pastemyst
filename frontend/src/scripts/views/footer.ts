import View from "renderer/view";

export default class Footer extends View
{
    public render (): string
    {
        /* tslint:disable:max-line-length */
        return `<footer><div class="copyright">copyright &copy; <a href="https://github.com/CodeMyst" target="_blank">CodeMyst</a> 2019</div><div class="paste-amount">1337 currently active pastes</div></footer>`;
        /* tslint:enable:max-line-length */
    }
    
    public async run (): Promise<void>
    {
        return;
    }
}
