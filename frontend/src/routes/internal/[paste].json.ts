import type { EndpointOutput } from "@sveltejs/kit";
import { API_BASE } from "../../constants";

// eslint-disable-next-line @typescript-eslint/explicit-module-boundary-types
export const get = async ({ params }): Promise<EndpointOutput> => {
    const { paste } = params;
    const res = await fetch(`${API_BASE}/paste/${paste}`);
    const json = await res.json();

    return {
        body: json
    };
};