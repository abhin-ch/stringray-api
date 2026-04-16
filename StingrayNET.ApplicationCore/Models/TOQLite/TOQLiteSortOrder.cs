

namespace StingrayNET.ApplicationCore.Models.TOQLite;
public class TOQLiteSortOrder
{
    public string UUID { get; private set; }
    public int SortOrder { get; private set; }

    public TOQLiteSortOrder(string uuid, int sortOrder)
    {
        UUID = uuid;
        SortOrder = sortOrder;
    }

}