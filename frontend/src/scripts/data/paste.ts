export class Paste
{
    /* tslint:disable-next-line */
    public _id: string;
    public createdAt: number;
    public expiresIn: string;
    public title: string;
    public ownerId: string;
    public pasties: Pasty [];
    public isPrivate: boolean;
}

export class PasteCreateInfo
{
    public expiresIn: string;
    public title: string;
    public pasties: Pasty [];
    public isPrivate: boolean;
}

export class Pasty
{
    public title: string;
    public language: string;
    public code: string;
}
