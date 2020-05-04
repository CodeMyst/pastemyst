module pastemyst.data.edit;

/++
 + holds information about a single paste edit
 +/
public struct Edit
{
    /++
     + edit id, multiple edits can share the same id to show that multiple properties were edited at the same time
     +/
    public ulong id;

    /++
     + type of edit
     +/
    public EditType editType;
    
    /++
     + various metadata, most used case is for storing which pasty was edited
     +/
    public string[] metadata;
    
    /++
     + actual edit
     +/
    public string edit;

    /++
     + unix time of when the edit was done
     +/
    public ulong editedAt;
}

/++
 + type of paste edit
 +/
public enum EditType
{
    title,
    pastyTitle,
    pastyLanguage,
    pastyContent
}