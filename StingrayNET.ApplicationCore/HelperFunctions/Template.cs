using System.Collections.Generic;

namespace StingrayNET.ApplicationCore.HelperFunctions;

public class Template
{
    public static string Populate(string template, Dictionary<string, string> keyValue)
    {
        foreach (var item in keyValue)
        {
            template = template.Replace(item.Key, item.Value);
        }
        return template;
    }
}