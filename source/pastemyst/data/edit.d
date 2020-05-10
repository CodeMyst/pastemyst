module pastemyst.data.edit;

import vibe.data.serialization;

/++
 + holds information about a single paste edit
 +/
public struct Edit
{
    /++
     + edit id, multiple edits can share the same id to show that multiple properties were edited at the same time
     +/
    @name("_id")
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
     + actual edit, usually stores the old data
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

/++
 + returns the description of an edit type
 +/
public string editTypeDescription(EditType type)
{
    final switch (type)
    {
        case EditType.title:
            return "changed title";
        case EditType.pastyTitle:
            return "changed title";
        case EditType.pastyLanguage:
            return "changed language";
        case EditType.pastyContent:
            return "changed content";
    }
}