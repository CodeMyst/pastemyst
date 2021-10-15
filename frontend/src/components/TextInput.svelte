<script lang="ts">
    import Select from "./Select.svelte";

    const expiresValues: [string, string][] = [
        ["never", "never"],
        ["1h", "1 hour"],
        ["2h", "2 hours"],
        ["10h", "10 hours"],
        ["1d", "1 day"],
        ["2d", "2 days"],
        ["1w", "1 week"],
        ["1m", "1 month"],
        ["1y", "1 year"]
    ];

    let selectedExpires: [string, string] = expiresValues[0];
</script>

<div class="text-input">
    <input type="text" placeholder={$$props.placeholder} autocomplete="false" />

    <div class="select">
        <Select
            id="expires-in"
            label="expires in:"
            options={expiresValues}
            bind:selectedValue={selectedExpires}
        />
    </div>
</div>

<style>
    .text-input {
        display: flex;
        flex-direction: column;
        margin-bottom: 2em;
    }

    input {
        width: 100%;
        background-color: var(--color-cod-gray-light);
        border: none;
        outline: none;
        border-radius: var(--border-radius) var(--border-radius) 0 0;
        border-bottom: 2px solid var(--color-cod-gray);
        color: var(--color-white);
        padding: 0.5em 1em;
    }

    .select {
        background-color: var(--color-cod-gray-light);
        border-radius: 0 0 var(--border-radius) var(--border-radius);
        padding-left: 1em;
    }

    @media screen and (min-width: 720px) {
        .text-input {
            flex-direction: row;
        }

        input {
            border-bottom: none;
            border-radius: var(--border-radius) 0 0 var(--border-radius);
        }

        .select {
            border-radius: 0 var(--border-radius) var(--border-radius) 0;
        }

        .select :global(.select-label) {
            text-align: right;
            width: 100px;
        }
    }
</style>
