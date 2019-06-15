import { Page } from "../router/router";

export class Home extends Page
{
    public async render (): Promise<string>
    {
        return `<h1><img class="icon" src="assets/icons/pastemyst.svg" alt="icon"/><a href="/">PasteMyst</a></h1><p class="description">a simple website for storing and sharing code snippets.
version 2.0.0 (<a href="#" target="_blank">changelog</a>).</p><nav><ul><li><a href="/">home</a> - </li><li><a href="/login">login</a> - </li><li><a href="https://github.com/codemyst/pastemyst" target="_blank">github</a> - </li><li><a href="/api-docs">api docs</a></li></ul></nav><div class="options"><div id="expires-in"><div class="dropdown hidden"><div class="label"><p>label:</p></div><div class="dropdown-content"><div class="clickable"><p class="selected">loading...</p><img class="caret" src="assets/icons/caret.svg"/></div><div class="selectable"><input class="search" type="text" name="search" placeholder="search..."/><div class="items"><p class="not-found hidden">no items found</p></div></div></div></div></div><div id="language"><div class="dropdown hidden"><div class="label"><p>label:</p></div><div class="dropdown-content"><div class="clickable"><p class="selected">loading...</p><img class="caret" src="assets/icons/caret.svg"/></div><div class="selectable"><input class="search" type="text" name="search" placeholder="search..."/><div class="items"><p class="not-found hidden">no items found</p></div></div></div></div></div></div><input id="title-input" type="text" name="title" placeholder="title (optional)" autocomplete="off"/><textarea id="editor" autofocus="autofocus"></textarea><div class="create-options"><div class="private-checkbox"><label class="disabled">private<input type="checkbox" disabled="disabled"/><span class="checkmark"></span></label><div class="tooltip" data-tooltip="You need to be logged in to create private pastes."><img src="assets/icons/questionmark.svg" alt="questionmark"/></div></div><a class="button" id="create-button" href="#">create</a></div><footer><div class="copyright">copyright &copy; <a href="https://github.com/CodeMyst" target="_blank">CodeMyst</a> 2019</div><div class="paste-amount">1337 currently active pastes</div></footer>`;
    }

    public async run (): Promise<void> {}
}
