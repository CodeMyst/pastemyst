<template lang="pug">
footer
    p.number-of-pastes 8472 currently active pastes
    p.copyright copyright #[span.copyright-symbol &#169;] #[a(href="https://github.com/codemyst")  CodeMyst] 2019
</template>

<script lang="ts">
import Vue from 'vue';

export default class FooterComponent extends Vue {}
</script>

<style lang="scss">
footer
{
    width: 100%;
    background-color: $color-nanolight;
    border-radius: $border-radius-std;
    padding: 1rem;
    box-sizing: border-box;
    margin: 3rem 0;
    font-size: 1rem;

    p
    {
        margin: 0;
        display: inline;
    }

    .number-of-pastes
    {
        float: right;
    }

    .copyright-symbol
    {
        font-family: sans-serif;
        font-size: 1rem;
    }
}
</style>


