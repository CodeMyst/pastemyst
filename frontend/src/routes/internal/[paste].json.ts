import type { EndpointOutput } from "@sveltejs/kit";

export const get = async ({ params }: { params: string }): Promise<EndpointOutput> => {
    // todo: turn the host into a var
    const res = await fetch(`http://localhost:5001/api/v3/paste/${params}`);
    const json = await res.json();

    return {
        body: json
    };
};