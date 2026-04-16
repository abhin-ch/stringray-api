using StingrayNET.ApplicationCore.Interfaces;
using System;
using Microsoft.Extensions.Caching.Memory;
using System.Threading;
using Microsoft.Extensions.Configuration;

namespace StingrayNET.Infrastructure.Services;

public class CacheProvider : ICacheProvider
{
    private readonly IMemoryCache _cache;
    private readonly TimeSpan _defaultExpiration;
    public CacheProvider(IMemoryCache cache, IConfiguration config)
    {
        _cache = cache;
        _defaultExpiration = TimeSpan.FromMinutes(
            config.GetValue<int>("Cache:DefaultExpirationMinutes", 15));
    }

    public void Clear()
    {
        if (_cache is MemoryCache concreteMemoryCache)
        {
            concreteMemoryCache.Clear();
        }
    }

    public bool TryGet<T>(string key, out T data)
    {
        return _cache.TryGetValue(key, out data);
    }

    public bool Exists(string key)
    {
        return _cache.TryGetValue(key, out _);
    }

    public T Set<T>(string key, T data, TimeSpan? expiration = null)
    {
        var options = new MemoryCacheEntryOptions
        {
            AbsoluteExpirationRelativeToNow = expiration ?? _defaultExpiration
        };
        return _cache.Set(key, data, options);
    }

    public void Remove(string key)
    {
        _cache.Remove(key);
    }
}

