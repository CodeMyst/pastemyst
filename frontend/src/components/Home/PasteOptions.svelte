<script lang="ts">
    import { createEventDispatcher } from "svelte";

    let isEncrypted: boolean = false;
    let isPrivate: HTMLInputElement;
    let isShownOnprofile: HTMLInputElement;
    let isDetached: HTMLInputElement;

    const dispatcher = createEventDispatcher();

    // simulates the behaviour of radio buttons for checkboxes
    // this is because radio buttons can't be unselected
    const onRadioPress = (event: MouseEvent) => {
        let t = event.target as HTMLInputElement;

        if (t.checked) {
            let group = `input[type=checkbox][name='${t.name}']`;

            document.querySelectorAll(group).forEach((e) => {
                (e as HTMLInputElement).checked = false;
            });
            t.checked = true;
        } else {
            t.checked = false;
        }
    };

    const onCreateClick = () => {
        dispatcher("createPaste", {
            isEncrypted: isEncrypted,
            // TODO: account pastes
            // isPrivate: isPrivate.checked,
            // isShownOnprofile: isShownOnprofile.checked,
            // isDetached: isDetached.checked
        });
    };
</script>

<div class="paste-options">
    <div class="options">
        <label data-tooltip="encrypts the paste with a password" class="option">
            <input type="checkbox" bind:checked={isEncrypted} />
            <ion-icon name="key" />
        </label>
        <!-- TODO: account pastes -->
        <!-- <label data-tooltip="only you can view the paste" class="option">
            <input
                type="checkbox"
                name="visibility"
                on:click={onRadioPress}
                bind:this={isPrivate}
            />
            <ion-icon name="lock-closed" />
        </label>
        <label data-tooltip="will be displayed on your profile" class="option">
            <input
                type="checkbox"
                name="visibility"
                on:click={onRadioPress}
                bind:this={isShownOnprofile}
            />
            <ion-icon name="person" />
        </label>
        <label
            data-tooltip="detached - the paste won't be associated with your account"
            class="option"
        >
            <input
                type="checkbox"
                name="visibility"
                on:click={onRadioPress}
                bind:this={isDetached}
            />
            <ion-icon name="finger-print" />
        </label> -->
    </div>

    <div class="create-paste">
        {#if isEncrypted}
            <div class="password">
                <input type="password" placeholder="password..." />
            </div>
        {/if}

        <button on:click={onCreateClick}>create paste</button>
    </div>
</div>

<style lang="scss">
    @import "../../mixins.scss";

    .paste-options {
        background-color: var(--color-cod-gray-light);
        padding: 1em;
        border-radius: var(--border-radius);
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        margin-top: 2em;
    }

    .create-paste button {
        @include transition();
        background-color: var(--color-main);
        color: var(--color-cod-gray);
        padding: 0.5em 1em;
        border-radius: var(--border-radius);
        display: inline-block;
        width: 15em;
        text-align: center;
        border: none;
        outline: none;
        cursor: pointer;
    }

    .create-paste button:hover {
        background-color: var(--color-accent);
    }

    .options {
        display: flex;
        flex-direction: row;
        margin-bottom: 1em;
    }

    .option {
        margin-right: 1.5em;
        display: flex;
        cursor: pointer;
        padding-top: 0.3em;
    }

    .option:last-child {
        margin-right: 0;
    }

    .option ion-icon {
        font-size: var(--fontsize-large);
        transition: 0.1s ease-in-out;
    }

    .option input {
        position: absolute;
        opacity: 0;
        height: 0;
        width: 0;
    }

    .option input:checked ~ ion-icon {
        color: var(--color-main);
    }

    .password {
        margin-bottom: 1em;
    }

    .password input {
        background-color: var(--color-cod-gray);
        width: 15em;
        border: 1px solid var(--color-red);
    }

    @media screen and (min-width: 720px) {
        .paste-options {
            flex-direction: row-reverse;
        }

        .options {
            margin-bottom: 0;
        }
    }
</style>
