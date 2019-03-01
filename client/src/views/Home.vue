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
</template>

<style lang="scss" scoped>
select
{
    background-color: $color-nanolight;
    color: $color-white;
    border: none;
    border-radius: $border-radius-std;
    height: 38px;
    font-family: $font-stack;
    font-size: 1.2rem;

    &:hover, &:focus
    {
        border: none;
        outline: none;
        color: $color-white;
    }
}

.expires-in, .language
{
    display: inline-block;
    margin-top: 1rem;

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
</style>

