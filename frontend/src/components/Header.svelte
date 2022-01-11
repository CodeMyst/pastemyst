<script lang="ts">
    import Popup from "./Popup.svelte";
    import Select from "./Input/Select.svelte";
    import { INDENT_AMOUNTS, INDENT_UNITS } from "../constants";
    import { getGlobalSettings, GlobalSettings, saveGlobalSettings } from "../settings";
    import { getLangNames } from "../services/langs";
    import { onMount } from "svelte";

    let showNavbar = false;
    let showSettings = false;

    let globalSettings: GlobalSettings;
    let loadedSettings = false;

    let defLangsPromise = getLangNames();

    onMount(async () => {
        globalSettings = await getGlobalSettings();
        loadedSettings = true;
    });

    const saveSettings = () => {
        saveGlobalSettings(globalSettings);
    };
</script>

<div id="header" class={$$props.class}>
    <div class="left">
        <img src="/images/pastemyst.svg" alt="pastemyst logo" />
        <h1><a href="/">pastemyst</a></h1>
    </div>

    <div class="right">
        <div class="header-button profile">
            <ion-icon name="person-circle" />
        </div>

        <div class="header-button settings-toggle" on:click={() => (showSettings = true)}>
            <ion-icon name="settings" />
        </div>

        <div class="header-button navbar-toggle" on:click={() => (showNavbar = true)}>
            <ion-icon name="menu" />
        </div>
    </div>
</div>

<Popup bind:visible={showNavbar}>
    <nav class="popup-content">
        <div class="title">
            <span>menu</span>

            <div class="header-button navbar-toggle" on:click={() => (showNavbar = false)}>
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

<Popup bind:visible={showSettings}>
    <div class="popup-content settings">
        <div class="title">
            <span>settings</span>

            <div class="header-button settings-toggle" on:click={() => (showSettings = false)}>
                <ion-icon name="close" />
            </div>
        </div>

        <div class="description">
            global website settings. if you login these settings will get saved to your account.
        </div>

        <div class="items">
            {#if loadedSettings}
                <div class="item">
                    <span class="name">default indentation</span>
                    <span class="description">editors will default to these indentation settings when creating a new paste.</span>

                    <div class="option">
                        <Select
                            id="indent-units"
                            label="units"
                            options={INDENT_UNITS}
                            filterEnabled={false}
                            bind:selectedValue={globalSettings.indentUnit}
                            on:selected={saveSettings}
                        />
                    </div>

                    <div class="option">
                        <Select
                            id="indent-amount"
                            label="amount"
                            options={INDENT_AMOUNTS}
                            filterEnabled={false}
                            bind:selectedValue={globalSettings.indentAmount}
                            on:selected={saveSettings}
                        />
                    </div>
                </div>

                <div class="item">
                    <label for="override-indentation" class="name">
                        override indentation
                        <input type="checkbox" name="override-indentation" id="override-indentation" bind:checked={globalSettings.overrideIndent} on:change={saveSettings} />
                        <div class="check">
                            <ion-icon name="checkmark" />
                        </div>
                    </label>
                    <span class="description">override indentation when viewing pastes with the default indentation setting.</span>
                </div>

                <div class="item">
                    <span class="name">default language</span>
                    <span class="description">default language for editors when creating a paste</span>

                    {#await defLangsPromise then langNames}
                        <Select
                            id="default-language"
                            label="lang"
                            options={langNames}
                            bind:selectedValue={globalSettings.defaultLang}
                            on:selected={saveSettings}
                        />
                    {/await}
                </div>

                <div class="item">
                    <label for="full-width" class="name">
                        full width page
                        <input type="checkbox" name="full-width" id="full-width" bind:checked={globalSettings.fullWidth} on:change={saveSettings} />
                        <div class="check">
                            <ion-icon name="checkmark" />
                        </div>
                    </label>
                    <span class="description">the page content will take up more horizontal space.</span>
                </div>
            {/if}
        </div>
    </div>
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

    .header-button {
        cursor: pointer;
        font-size: 1.5em;
        margin-left: 1rem;
        @include transition();

        &:hover {
            color: var(--color-accent);
        }
    }

    .profile,
    .settings-toggle {
        font-size: 1.25rem;
    }

    .popup-content {
        background-color: var(--color-cod-gray-light);
        border-radius: var(--border-radius);
        display: flex;
        flex-direction: column;
        padding: 0.5em 1em;

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
    }

    nav {
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

    .settings {
        .description {
            color: var(--color-boulder);
            font-size: var(--fontsize-small);
        }

        .items {
            margin-top: 2rem;

            .item {
                display: flex;
                flex-direction: column;
                margin-bottom: 2rem;

                .name {
                    margin-bottom: 0.5rem;
                }

                .description {
                    margin-bottom: 0.5rem;
                }

                .option {
                    margin-bottom: 0.5rem;
                }

                :global(.container) {
                    justify-content: space-between;
                    text-transform: lowercase;
                }

                :global(.container input) {
                    background-color: var(--color-cod-gray);
                }
            }
        }

        label {
            cursor: pointer;
            display: flex;
            justify-content: space-between;

            ion-icon {
                margin-right: 0;
                @include transition();
                display: none;
            }

            .check {
                background-color: var(--color-cod-gray);
                width: 20px;
                height: 20px;
                border-radius: var(--border-radius);
                padding: 0.1rem;
            }

            input {
                opacity: 0;
                height: 0;
                width: 0;

                &:checked ~ .check ion-icon {
                    color: var(--color-main);
                    display: initial;
                }
            }
        }
    }
</style>
