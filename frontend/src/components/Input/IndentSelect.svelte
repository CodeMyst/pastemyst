<script lang="ts">
    import { INDENT_AMOUNTS, INDENT_UNITS } from "../../constants";
    import { createEventDispatcher } from "svelte";
    import BigSelect from "./PopupSelect.svelte";

    const dispatch = createEventDispatcher();

    let indentSelect: BigSelect;

    export let selectedIndentUnit = INDENT_UNITS[1];
    export let selectedIndentAmount = INDENT_AMOUNTS[3];

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
    options={INDENT_UNITS}
    displayAppend=": {selectedIndentAmount[1].toString()}"
    bind:selectedValue={selectedIndentUnit}
    on:selected={onMethodSelected}
/>

<BigSelect
    id="indent-amount"
    bind:this={indentSelect}
    label=""
    placeholder="select an indent amount"
    options={INDENT_AMOUNTS}
    hiddenLabel={true}
    bind:selectedValue={selectedIndentAmount}
    on:selected={onAmountSelected}
/>
