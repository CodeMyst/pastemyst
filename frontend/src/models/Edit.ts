import type {JSONString} from "@sveltejs/kit/types/helper";
import type { EditType } from "./EditType";

export class Edit {
    id: string;
    groupId: string;
    type: EditType;
    metadata: string[];
    change: string;
    editedAt: number;

    static fromJson(json: JSONString): Edit {
        const res = new Edit();

        res.id = json["_id"];
        res.groupId = json["groupId"];
        res.type = json["type"];
        res.metadata = json["metadata"];
        res.change = json["change"];
        res.editedAt = json["editedAt"];

        return res;
    }
}
