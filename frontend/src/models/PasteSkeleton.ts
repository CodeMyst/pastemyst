import type { ExpiresIn } from "./Expires";
import type { Pasty } from "./Pasty";

export enum Visibility {
    Pub = "public",
    Priv = "private",
    Profile = "profile"
}

export class PasteSkeleton {
    title: string;
    expiresIn: ExpiresIn;
    visibility: Visibility;
    tags: string[];
    pasties: Pasty[];
}
