import type { EndpointOutput } from "@sveltejs/kit";

export async function get({ params }): Promise<EndpointOutput> {
    const { paste } = params;

    const res = await fetch(`http://localhost:5001/api/v3/paste/${paste}`);
    const json = await res.json();

    return {
        body: json
    };
}