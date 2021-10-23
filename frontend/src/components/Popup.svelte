<script lang="ts">
    export let visible: boolean = false;

    let contentElement: HTMLElement;

    const backgroundClick = (event: MouseEvent) => {
        if (event.target !== contentElement) visible = false;
    };
</script>

<div class="popup">
    <div class="background" class:visible on:click={backgroundClick} />
    <div class="content" class:visible bind:this={contentElement}>
        <slot />
    </div>
</div>

<style lang="scss">
    @import "../mixins.scss";

    .background {
        @include transition();
        width: 100%;
        height: 100%;
        position: fixed;
        z-index: 10;
        top: 0;
        left: 0;
        background-color: var(--color-cod-gray);
        display: block;
        opacity: 0;
        visibility: hidden;

        &.visible {
            opacity: 0.5;
            visibility: visible;
        }
    }

    .content {
        @include shadow();
        z-index: 15;
        position: fixed;
        top: 18px;
        left: 0;
        right: 0;
        max-width: 90%;
        width: 720px;
        margin: 0 auto;
        display: none;

        &.visible {
            display: block;
        }
    }
</style>
