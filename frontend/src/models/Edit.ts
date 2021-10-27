import type { EditType } from "./EditType";

export class Edit {
    id: string;
    groupId: string;
    type: EditType;
    metadata: string[];
    change: string;
    editedAt: number;
}