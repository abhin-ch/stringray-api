namespace StingrayNET.ApplicationCore.Abstractions;

public abstract class BaseDB
{
    protected string _connectionString;

    public BaseDB(string connectionString)
    {
        _connectionString = connectionString;
    }
}

