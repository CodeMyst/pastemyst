import type { EndpointOutput } from "@sveltejs/kit";

// eslint-disable-next-line @typescript-eslint/explicit-module-boundary-types
export const get = async ({ params }): Promise<EndpointOutput> => {
    const { paste } = params;
    // todo: turn the host into a var
    const res = await fetch(`http://localhost:5001/api/v3/paste/${paste}`);
    const json = await res.json();

    return {
        body: json
    };
};