import type { ExpiresIn } from "./Expires";
import type {Visibility} from "./PasteSkeleton";

export class BasePaste {
    id: string;
    createdAt: Date;
    deletesAt: Date | null;
    expiresIn: ExpiresIn;
    ownerId: string;
    visibility: Visibility;
    tags: string[];
    stars: number;
    isEncrypted: boolean;
}
