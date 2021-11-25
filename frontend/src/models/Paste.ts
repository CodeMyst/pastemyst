import type {JSONString} from "@sveltejs/kit/types/helper";
import { BasePaste } from "./BasePaste";
import { Edit } from "./Edit";
import { Pasty } from "./Pasty";

export class Paste extends BasePaste {
    title: string;
    pasties: Pasty[];
    edits: Edit[];

    static fromJson(json: JSONString): Paste {
        const res = new Paste();

        res.id = json["_id"];
        res.createdAt = json["createdAt"];
        res.deletesAt = json["deletesAt"];
        res.expiresIn = json["expiresIn"];
        res.ownerId = json["ownerId"];
        res.visibility = json["visibility"];
        res.tags = json["tags"];
        res.stars = json["stars"];
        res.isEncrypted = json["isEncrypted"];
        res.title = json["title"];

        res.edits = [];
        const editsJson = json["edits"];
        for (let i = 0; i < editsJson.length; i++) {
            const edit = Edit.fromJson(editsJson[i]);
            res.edits.push(edit);
        }

        res.pasties = [];
        const pastiesJson = json["pasties"];
        for (let i = 0; i < pastiesJson.length; i++) {
            const pasty = Pasty.fromJson(pastiesJson[i]);
            res.pasties.push(pasty);
        }

        return res;
    }
}
