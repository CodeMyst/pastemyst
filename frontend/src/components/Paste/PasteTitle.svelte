<script lang="ts">
    export let title: string;
</script>

<div class="paste-title">
    <p class="title">{title}</p>
</div>

<style lang="scss">
    .paste-title {
        background-color: var(--color-cod-gray-light);
        padding: 0.5em 1em;
        border-radius: var(--border-radius);

        .title {
            margin: 0;
        }
    }
</style>