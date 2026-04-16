using System.Collections.Generic;

namespace StingrayNET.ApplicationCore.Abstractions;

public abstract class BaseOperation
{
    public int RowsAffected { get; set; }
    public object Data { get; set; }
    public List<object> Data1 { get; set; }
    public List<object> Data2 { get; set; }
    public List<object> Data3 { get; set; }
    public List<object> Data4 { get; set; }
}


public abstract class BaseOperation<TValue>
{
    public int RowsAffected { get; set; }
    public TValue Data { get; set; }
    public List<TValue> Data1 { get; set; }
    public List<object> Data2 { get; set; }
    public List<object> Data3 { get; set; }
    public List<object> Data4 { get; set; }
}

public abstract class BaseOperation<TValue1, TValue2>
{
    public int RowsAffected { get; set; }
    public TValue1 Data { get; set; }
    public List<TValue1> Data1 { get; set; }
    public List<TValue2> Data2 { get; set; }
    public List<object> Data3 { get; set; }
    public List<object> Data4 { get; set; }
}