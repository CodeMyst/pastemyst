require.config ({ paths: { 'vs': 'vs' }});
        require (['vs/editor/editor.main'], function ()
        {
            window.editor = monaco.editor.create (document.getElementById ('textEditor'),
            {
                value: '',
                language: ''
            });

            document.getElementsByTagName ("select") [0].onchange = () =>
            {
                var select = document.getElementsByTagName ("select") [0];
                window.editor = monaco.editor.create (document.getElementById ('textEditor'),
                {
                    value: window.editor.getValue (),
                    language: select.options [select.selectedIndex].value
                });
                document.getElementById ("textEditor").childNodes [0].remove ();;
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
    form.querySelectorAll ("input[type=hidden]") [0].value = encodeURIComponent (window.editor.getValue ());
    form.submit ();
}

