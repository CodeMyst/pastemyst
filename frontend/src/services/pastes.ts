import { Paste } from "../models/Paste";
import type { PasteSkeleton } from "../models/PasteSkeleton";
import { API_BASE } from "../constants";

/**
 * Creates a paste through the API
 */
export const createPaste = async (skeleton: PasteSkeleton): Promise<Paste> => {
    // TODO: erorr handling
    const res = await fetch(`${API_BASE}/paste/`, {
        method: "post",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify(skeleton)
    });

    const json = await res.json();

    return Paste.fromJson(json);
};
