export class Paste
{
    /* tslint:disable-next-line */
    public _id: string;
    public createdAt: number;
    public expiresIn: string;
    public title: string;
    public code: string;
    public language: string;
    public ownerId: string;
    public isPrivate: boolean;
    public isEdited: boolean;
}

export class PasteCreateInfo
{
    public expiresIn: string;
    public title?: string;
    public code: string;
    public language: string;
    public isPrivate: boolean;
}
