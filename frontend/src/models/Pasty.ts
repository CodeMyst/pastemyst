import type {JSONString} from "@sveltejs/kit/types/helper";

export class Pasty {
    id: string;
    title: string;
    language: string;
    content: string;

    static fromJson(json: JSONString): Pasty {
        const res = new Pasty();

        res.id = json["_id"];
        res.title = json["title"];
        res.language = json["language"];
        res.content = json["content"];

        return res;
    }
}
