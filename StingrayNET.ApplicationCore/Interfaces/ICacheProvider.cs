using System;

namespace StingrayNET.ApplicationCore.Interfaces;

public interface ICacheProvider
{
    bool Exists(string key);
    bool TryGet<T>(string key, out T data);
    T Set<T>(string key, T data, TimeSpan? expiration = null);
    void Remove(string key);
    public void Clear();
}