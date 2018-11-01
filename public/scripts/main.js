require.config({ paths: { 'vs': 'vs' }});
        require(['vs/editor/editor.main'], function() {
            var editor = monaco.editor.create(document.getElementById('textEditor'), {
                value: '',
                language: ''
            });

            document.getElementsByTagName ("select") [0].onchange = () =>
            {
                var select = document.getElementsByTagName ("select") [0];
                editor = monaco.editor.create(document.getElementById('textEditor'), {
                    value: editor.getValue (),
                    language: select.options [select.selectedIndex].value
                });
                document.getElementById ("textEditor").childNodes [0].remove ();;
            };

            monaco.editor.setTheme ('vs-dark');

            document.getElementsByClassName ("button") [0].onclick = function () { createSnippet (); };

            function createSnippet ()
            {
                var form = document.getElementsByTagName ("form") [0];
                form.querySelectorAll ("input[type=hidden]") [0].value = encodeURI (editor.getValue ());
                console.log (encodeURI (editor.getValue ()));
                form.submit ();
            }
        });