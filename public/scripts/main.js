require.config ({ paths: { 'vs': 'vs' }});
        require (['vs/editor/editor.main'], function ()
        {
            createMonacoEditor ('', '');

            document.getElementsByClassName ('editor-language') [0].onchange = () =>
            {
                let select = document.getElementsByClassName ('editor-language') [0];

                createMonacoEditor (window.editor.getValue (), select.options [select.selectedIndex].value);

                deleteMonacoEditor ();
            };            

            monaco.editor.setTheme ('vs-dark');
        });

document.getElementsByClassName ('button') [0].onclick = function () { createSnippet (); };

document.getElementById ('plaintext-checkbox').onchange = function () { toggleEditor (); };

enableTextareaTab ();

function createSnippet ()
{
    let form = document.getElementById ('create-paste-form');
    
    let content;
    if (isUsingMonaco ())
        content = window.editor.getValue ();
    else
        content = document.getElementById ('plaintext-editor').value;

    form.querySelectorAll ('input[name=code]') [0].value = encodeURIComponent (content);
    let expiresInSelect = document.getElementsByClassName ('expires-in') [0];
    form.querySelectorAll ('input[name=expiresIn]') [0].value = expiresInSelect.options [expiresInSelect.selectedIndex].value;
    form.submit ();
}

function isUsingMonaco ()
{
    let plaintextEditor = document.getElementById ('plaintext-editor');
    return plaintextEditor.classList.contains ('hidden');
}

function toggleEditor ()
{
    let plaintextEditor = document.getElementById ('plaintext-editor');
    let select = document.getElementsByClassName ('editor-language') [0];

    if (plaintextEditor.classList.contains ('hidden'))
        plaintextEditor.classList.remove ('hidden');
    else
        plaintextEditor.classList.add ('hidden');

    if (!plaintextEditor.classList.contains ('hidden'))
    {
        plaintextEditor.value = window.editor.getValue ();
        deleteMonacoEditor ();
        document.getElementById ('text-editor').classList.add ('hidden');
        select.classList.add ('hidden');
    }
    else
    {
        document.getElementById ('text-editor').classList.remove ('hidden');
        createMonacoEditor (plaintextEditor.value, select.options [select.selectedIndex].value);
        select.classList.remove ('hidden');
    }
}

function createMonacoEditor (value, language)
{
    window.editor = monaco.editor.create (document.getElementById ('text-editor'),
    {
        value: value,
        language: language,
        fontFamily: 'Ubuntu Mono'
    });
}

function deleteMonacoEditor ()
{
    document.getElementById ('text-editor').childNodes [0].remove ();
}

function enableTextareaTab ()
{
    let textArea = document.getElementById ('plaintext-editor');
    textArea.onkeydown = function (e)
    {
        if (e.keyCode == 9 || e.which == 9)
        {
            e.preventDefault ();
            let s = this.selectionStart;
            this.value = this.value.substring (0, this.selectionStart) + '    ' + this.value.substring (this.selectionEnd);
            this.selectionEnd = s + 4;
        }
    }
}
