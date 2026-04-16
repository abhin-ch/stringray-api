using System.Text.Json.Serialization;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace StingrayNET.ApplicationCore.Models.File;
public enum FileRequestType
{
    Start,
    Chunk,
    End
}

public class FileRequest
{
    [JsonConverter(typeof(JsonStringEnumConverter))]
    public FileRequestType FileRequestType { get; set; }
    public string FileName { get; set; }

    public int? ChunkCount { get; private set; }

    public string? ParentID { get; private set; }
    public string? GroupBy { get; private set; }
    public string? Module { get; private set; }

    public FileRequest(FileRequestType fileRequestType, string? fileName = null, int? chunkCount = null, string? parentID = null, string? groupBy = null, string? module = null)
    {
        FileRequestType = fileRequestType;

        switch (FileRequestType)
        {
            case FileRequestType.Start:
                {
                    if (chunkCount == null)
                    {
                        throw new ArgumentNullException(nameof(chunkCount), @"chunkCount required for Start File Requests");
                    }

                    ChunkCount = chunkCount;

                    break;
                }

            case FileRequestType.End:
                {
                    if (string.IsNullOrEmpty(fileName))
                    {
                        throw new ArgumentNullException(nameof(fileName), @"fileName required for End File Requests");
                    }

                    bool hasIllegalChar = false;
                    List<char> illegalChars = Path.GetInvalidFileNameChars().ToList();
                    foreach (char c in fileName)
                    {
                        if (illegalChars.Contains(c))
                        {
                            hasIllegalChar = true;
                            break;
                        }
                    }

                    if (!Path.HasExtension(fileName) || hasIllegalChar)
                    {
                        throw new ArgumentOutOfRangeException(nameof(fileName), $"{fileName} is an improper filename. Extension is missing or illegal characters are present");
                    }

                    FileName = fileName;

                    // if (parentID == null)
                    // {
                    //     throw new ArgumentNullException(@"ParentID", @"ParentID required for End File Requests");
                    // }

                    ParentID = parentID;
                    GroupBy = groupBy;

                    break;
                }
        }

    }
}