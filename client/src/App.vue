<template lang="pug">
#app
    h1
        a(href="/") PasteMyst

    p.description
        | A simple website for storing and sharing code snippets.
        | Version 2.0.0 (#[a(href="https://github.com/CodeMyst/PasteMyst/blob/develop/CHANGELOG.md", target="_blank") changelog]).

    nav
        ul
            li
                a(href="/") home
                |  - 
            li
                a(href="/login") login
                |  - 
            li
                a(href="https://github.com/codemyst/pastemyst", target="_blank") github
                |  - 
            li
                a(href="/api-docs") api docs
    router-view/
</template>

<style lang="scss">
#app
{
    width: 90%;
    max-width: 960px;
    margin: 0 auto;
    box-sizing: border-box;
    font-family: 'Ubuntu Mono', monospace;
    font-size: $font-size-normal;
}

h1
{
    margin-top: 0;
    font-size: $font-size-big;
    font-weight: normal;
}

nav
{
    background-color: $color-nanolight;
    border-radius: $border-radius-std;

    ul
    {
        padding: 1rem;

        li
        {
            display: inline;
        }
    }
}
</style>

