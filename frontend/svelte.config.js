import preprocess from "svelte-preprocess";

/** @type {import("@sveltejs/kit").Config} */
const config = {
    preprocess: [
        preprocess({
            scss: {}
        })
    ],

    kit: {
        target: "#svelte",

        vite: {
            css: {
                preprocessorOptions: {
                    scss: {}
                }
            }
        }
    }
};

export default config;
