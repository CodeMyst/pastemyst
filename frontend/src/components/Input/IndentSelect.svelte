<script lang="ts">
    import { createEventDispatcher } from "svelte";

    import BigSelect from "./PopupSelect.svelte";

    const dispatch = createEventDispatcher();

    let indentSelect: BigSelect;

    const indentUnits: [string, string][] = [
        ["tabs", "tabs"],
        ["spaces", "spaces"]
    ];

    const indentAmounts: [string, string][] = [
        ["1", "1"],
        ["2", "2"],
        ["3", "3"],
        ["4", "4"],
        ["5", "5"],
        ["6", "6"],
        ["7", "7"],
        ["8", "8"]
    ];

    export let selectedIndentUnit = indentUnits[1];
    export let selectedIndentAmount = indentAmounts[3];

    async function onMethodSelected() {
        await indentSelect.setOpen(true);
    }

    function onAmountSelected() {
        dispatch("selected");
    }
</script>

<BigSelect
    id="indent-method"
    label=""
    placeholder="select an indent unit"
    options={indentUnits}
    displayAppend=": {selectedIndentAmount[1].toString()}"
    bind:selectedValue={selectedIndentUnit}
    on:selected={onMethodSelected}
/>

<BigSelect
    id="indent-amount"
    bind:this={indentSelect}
    label=""
    placeholder="select an indent amount"
    options={indentAmounts}
    hiddenLabel={true}
    bind:selectedValue={selectedIndentAmount}
    on:selected={onAmountSelected}
/>
