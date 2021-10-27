import type { ExpiresIn } from "./Expires";

export class BasePaste {
    id: string;
    createdAt: Date;
    deletesAt: Date | null;
    expiresIn: ExpiresIn;
    ownerId: string;
    isPublic: boolean;
    isPrivate: boolean;
    tags: string[];
    stars: number;
    isEncrypted: boolean;
}