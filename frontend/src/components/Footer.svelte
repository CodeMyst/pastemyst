<footer>
    <div class="copy">
        © <a href="https://myst.rs/">codemyst</a> 2021
    </div>

    <div class="version">v3.0.0-alpha</div>

    <div class="paste-count">0 currently active pastes</div>
</footer>

<style lang="scss">
    footer {
        border-top: 2px solid var(--color-mineshaft);
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        padding: 1em 0;
        flex-shrink: 0;
        max-width: 90%;
        width: 1280px;
        margin: 0 auto;
        margin-top: 2em;
        line-height: 1.5;
    }

    @media screen and (min-width: 640px) {
        footer {
            flex-direction: row;
        }
    }
</style>
