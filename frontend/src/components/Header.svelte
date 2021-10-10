<script lang="ts">
    let showNavbar: boolean = false;
</script>

<div id="header" class={$$props.class}>
    <div class="logo">
        <img src="/images/pastemyst.svg" alt="pastemyst logo" />
        <h1><a href="/">pastemyst</a></h1>
        <span class="version">v3.0.0<span class="beta">b</span></span>

        <span class="navbar-toggle" on:click={() => (showNavbar = !showNavbar)}>
            <ion-icon name="menu" size="large"></ion-icon>
        </span>
    </div>

    <div class={`nav ${showNavbar ? "active" : ""}`}>
        <nav>
            <a href="/api-docs">api</a>
            <span class="delimiter" />
            <a href="/pastry">cli</a>
            <span class="delimiter" />
            <a href="/changelog">changelog</a>
            <span class="delimiter" />
            <a href="/contact">contact</a>
            <span class="delimiter" />
            <a href="/legal">legal</a>
            <span class="delimiter" />
            <a href="/donate" class="donate">donate</a>
        </nav>

        <nav class="login">
            <a href="/login">login</a>
            <span class="delimiter" />
            <a href="/register">register</a>
        </nav>
    </div>
</div>

<style>
    #header {
        margin-top: 1em;
    }

    .logo {
        display: flex;
        flex-direction: row;
        align-items: center;
    }

    img {
        width: 50px;
        margin-right: 1em;
    }

    .version {
        align-self: flex-end;
        margin-left: 0.5em;
        color: var(--color-boulder);
    }

    .beta {
        color: var(--color-accent);
    }

    .nav {
        display: none;
        flex-direction: column;
    }

    .nav.active {
        display: flex;
    }

    .nav nav {
        display: flex;
        flex-direction: column;
        margin-top: 1em;
        margin-left: 1em;
    }

    nav a {
        margin-top: 0.25em;
        font-size: var(--fontsize-medium);
    }

    .navbar-toggle {
        margin-left: auto;
        font-size: 1.5em;
        cursor: pointer;
        color: var(--color-boulder);
    }

    .donate {
        font-weight: bold;
        color: var(--color-accent);
    }

    @media screen and (min-width: 1100px) {
        #header {
            display: flex;
            flex-direction: row;
        }

        .navbar-toggle {
            display: none;
        }

        .nav {
            display: flex;
            flex-direction: row;
            justify-content: space-between;
            align-items: center;
            width: 100%;
        }

        .nav nav {
            flex-direction: row;
            align-items: center;
            margin-top: 0;
        }

        nav a {
            margin-top: 0;
        }

        nav .delimiter {
            margin-top: 3px;
        }

        nav .delimiter::before {
            content: "-";
            margin-left: 0.5em;
            margin-right: 0.5em;
        }
    }
</style>
