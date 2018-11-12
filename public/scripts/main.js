require.config ({ paths: { 'vs': 'vs' }});
        require (['vs/editor/editor.main'], function ()
        {
            window.editor = monaco.editor.create (document.getElementById ('text-editor'),
            {
                value: '',
                language: ''
            });

            document.getElementsByClassName ("editor-language") [0].onchange = () =>
            {
                var select = document.getElementsByClassName ("editor-language") [0];
                window.editor = monaco.editor.create (document.getElementById ('text-editor'),
                {
                    value: window.editor.getValue (),
                    language: select.options [select.selectedIndex].value
                });
                document.getElementById ("text-editor").childNodes [0].remove ();;
            };            

            monaco.editor.setTheme ('vs-dark');
        });

document.getElementsByClassName ("button") [0].onclick = function () { createSnippet (); };

function createSnippet ()
{
    grecaptcha.execute ();
}

function onCreate ()
{
    var form = document.getElementsByTagName ("form") [0];
    form.querySelectorAll ("input[name=code]") [0].value = encodeURIComponent (window.editor.getValue ());
    var expiresInSelect = document.getElementsByClassName ("expires-in") [0];
    form.querySelectorAll ("input[name=expiresIn]") [0].value = expiresInSelect.options [expiresInSelect.selectedIndex].value;
    form.submit ();
}

