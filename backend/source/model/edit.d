module model.edit;

import model;

/** 
 * Holds information about a single paste edit.
 */
public class Edit
{
    /** 
     * Edit ID.
     */
    public string id;

    /** 
     * Multiple edits with the same GroupId means that they were edited all at once.
     */
    public string groupId;

    /** 
     * Type of edit.
     */
    public EditType type;

    /** 
     * General storage for edits. Most used case is for storing which pasty was edited.
     */
    public string[] metadata;

    /** 
     * Actual edit changes, usually stores the previous paste data, as the current paste holds the new data.
     */
    public string change;

    /** 
     * When the edit was done, unix time.
     */
    public ulong editedAt;
}
