<script lang="ts">
    import Popup from "./Popup.svelte";

    let showNavbar = false;
    let navElement: HTMLElement;
</script>

<div id="header" class={$$props.class}>
    <div class="left">
        <img src="/images/pastemyst.svg" alt="pastemyst logo" />
        <h1><a href="/">pastemyst</a></h1>
    </div>

    <div class="right">
        <div class="profile">
            <ion-icon name="person-circle" />
        </div>

        <div class="navbar-toggle" on:click={() => (showNavbar = !showNavbar)}>
            <ion-icon name="menu" />
        </div>
    </div>
</div>

<Popup bind:visible={showNavbar}>
    <nav class:active={showNavbar} bind:this={navElement}>
        <div class="title">
            <span>menu</span>

            <div class="navbar-toggle" on:click={() => (showNavbar = false)}>
                <ion-icon name="close" />
            </div>
        </div>

        <div class="item">
            <a href="/api-docs">api</a>
            <span class="description">documentation for pastemyst's free api</span>
        </div>

        <div class="item">
            <a href="/changelog">changelog</a>
            <span class="description">see all of the versions and their changes</span>
        </div>

        <div class="item">
            <a href="/pastry">cli</a>
            <span class="description">quickly make pastes straight from a terminal</span>
        </div>

        <div class="item">
            <a href="/contact">contact</a>
            <span class="description">have a question or request? contact us here</span>
        </div>

        <div class="item">
            <a href="/legal">legal</a>
            <span class="description">terms of service and the privacy policy</span>
        </div>

        <div class="item">
            <a href="https://github.com/codemyst/pastemyst">github</a>
            <span class="description"
                >submit an issue, a pr, or just look at the code, it's open source</span
            >
        </div>

        <div class="item">
            <a href="/donate">donate</a>
            <span class="description">donations help keep the site running</span>
        </div>
    </nav>
</Popup>

<style lang="scss">
    @import "../mixins.scss";

    #header {
        margin-top: 1em;
        margin-bottom: 2em;
        display: flex;
        flex-direction: row;
        align-items: center;
        justify-content: space-between;
    }

    h1 {
        margin-top: -3px;
        font-size: var(--fontsize-large);
    }

    img {
        width: 40px;
        margin-right: 1em;
    }

    .left,
    .right {
        display: flex;
        flex-direction: row;
        align-items: center;
    }

    .navbar-toggle,
    .profile {
        cursor: pointer;
        color: var(--color-boulder);
        font-size: 1.5em;
        @include transition();

        &:hover {
            color: var(--color-accent);
        }
    }

    .profile {
        margin-right: 1em;
    }

    nav {
        background-color: var(--color-cod-gray-light);
        border-radius: var(--border-radius);
        display: none;
        flex-direction: column;
        padding: 0.5em 1em;

        &.active {
            display: flex;
        }

        .title {
            display: flex;
            flex-direction: row;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1em;
            font-size: var(--fontsize-medium);

            ion-icon {
                margin-right: -5px;
            }
        }

        .item {
            margin-bottom: 2em;
            display: flex;
            flex-direction: column;

            &:last-child {
                margin-bottom: 1em;
            }

            a {
                font-size: var(--fontsize-medium);
            }

            .description {
                margin-top: 0.5em;
                color: var(--color-boulder);
            }
        }
    }
</style>
