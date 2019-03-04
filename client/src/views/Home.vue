<template lang="pug">
#home
    .expires-in
        span.select-label expires in:
        select
            option(value="never") never
            option(value="1h") 1 hour
            option(value="2h") 2 hours
            option(value="10h") 10 hours
            option(value="1d") 1 day
            option(value="2d") 2 days
            option(value="1w") 1 week

    .language
        span.select-label language:
        select
            option(value="autodetect") autodetect

    input(type="text", placeholder="title (optional)", class="title-input")

    textarea.editor

    input(type="checkbox", name="account-paste")#account-paste
    label(for="account-paste") account paste

    input(type="checkbox", name="private-paste")#private-paste
    label(for="private-paste") private paste

    br

    button.button create
</template>

<script lang="ts">
import Vue, { VNode } from 'vue';
import * as cm from 'codemirror';
import 'codemirror/mode/d/d';

export default Vue.extend
({
    mounted () : void
    {
        this.$nextTick (function ()
        {
            const textArea: HTMLTextAreaElement = this.$el.getElementsByClassName ('editor') [0] as HTMLTextAreaElement;
            const editor: cm.Editor = cm.fromTextArea (textArea, { mode: 'text/x-d', theme: 'base16-dark', indentUnit: 4, lineNumbers: true });
        });
    }
});
</script>

<style lang="scss" scoped>
select
{
    background-color: $color-nanolight;
    color: $color-mystge;
    border: none;
    border-radius: $border-radius-std;
    height: 38px;
    font-family: $font-stack;
    font-size: 1.2rem;

    &:hover
    {
        cursor: pointer;
        background-color: $color-mystlu;
        color: $color-nanolight;
    }

    &:hover, &:focus
    {
        border: none;
        outline: none;
    }
}

.expires-in, .language
{
    display: inline-block;
    margin-top: 1rem;

    &:hover
    {
        .select-label
        {
            background-color: $color-mystlu;
        }

        select
        {
            background-color: $color-mystlu;
            color: $color-nanolight;
        }
    }

    @media all and (max-width: $break-small)
    {
        display: block;
    }

    .select-label
    {
        background-color: $color-nanolight;
        border-top-left-radius: 0.3rem;
        border-bottom-left-radius: 0.3rem;
        padding: 0px 10px;
        height: 38px;
        line-height: 39px;
        display: inline-block;
    }

    select
    {
        border-top-left-radius: 0;
        border-bottom-left-radius: 0;
        margin-top: -20px;
    }
}

.language
{
    float: right;

    @media all and (max-width: $break-small)
    {
        float: left;
    }
}

.title-input
{
    display: block;
    width: 100%;
    background-color: $color-nanolight;
    border: none;
    border-radius: $border-radius-std;
    font-family: $font-stack;
    margin-top: 1.5rem;
    padding: 1rem;
    font-size: $font-size-normal;
    box-sizing: border-box;
}

label
{
    margin-right: 1rem;
}

input[type="checkbox"]
{
    margin-right: 0.5rem;
}

.button
{
    margin-top: 2rem;
}
</style>

