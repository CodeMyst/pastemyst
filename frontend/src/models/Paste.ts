import { BasePaste } from "./BasePaste";
import type { Edit } from "./Edit";
import type { Pasty } from "./Pasty";

export class Paste extends BasePaste {
    title: string;
    pasties: Pasty[];
    edits: Edit[];
}