<script lang="ts">
    export let title: string;
</script>

<div class="paste-title">
    <p class="title">{title}</p>

    <div class="right">
        <div class="buttons">
            <div class="btn star" data-tooltip="star">
                <ion-icon name="star" />
                <span class="amount">54</span>
            </div>

            <div class="btn" data-tooltip="edit">
                <ion-icon name="create" />
            </div>

            <div class="btn" data-tooltip="copy the link">
                <ion-icon name="link" />
            </div>

            <div class="btn" data-tooltip="clone">
                <ion-icon name="duplicate" />
            </div>

            <div class="btn" data-tooltip="more options">
                <ion-icon name="ellipsis-horizontal" />
            </div>
        </div>
    </div>
</div>

<style lang="scss">
    @import "../../mixins.scss";

    .paste-title {
        background-color: var(--color-cod-gray-light);
        padding: 0.5em 1em;
        border-radius: var(--border-radius);
        display: flex;
        flex-direction: column-reverse;

        .title {
            margin: 0;
            font-size: var(--fontsize-medium);
            margin-top: 0.5em;
        }

        .buttons {
            display: flex;
            flex-direction: row;

            .btn {
                @include transition();
                padding: 0.5em;
                cursor: pointer;
                background-color: var(--color-cod-gray);
                border-radius: var(--border-radius);
                margin-right: 0.5em;

                &:hover {
                    color: var(--color-accent);
                }

                &:last-child {
                    margin-right: 0;
                }

                ion-icon {
                    font-size: var(--fontsize-medium);
                }
            }

            .star {
                display: flex;
                flex-direction: row;

                ion-icon {
                    margin-right: 0.25em;
                }
            }
        }
    }

    @media screen and (min-width: 640px) {
        .paste-title {
            flex-direction: row;
            align-items: center;

            .title {
                margin-top: 0;
            }

            .right {
                margin-left: auto;
            }
        }
    }
</style>
