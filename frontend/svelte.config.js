import preprocess from "svelte-preprocess";

/** @type {import("@sveltejs/kit").Config} */
const config = {
	// Consult https://github.com/sveltejs/svelte-preprocess
	// for more information about preprocessors
	preprocess: [
		preprocess({
			scss: {}
		})
	],

	kit: {
		// hydrate the <div id="svelte"> element in src/app.html
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
