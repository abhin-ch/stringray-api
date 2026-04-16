using System.Net.WebSockets;
using System;
using System.Collections.Generic;
using System.Linq;

namespace StingrayNET.ApplicationCore.Models.WSService;
public class StingrayWS : IDisposable
{
    public WebSocket WebSocket { get; private set; }
    private DateTime OriginTime { get; set; }
    public bool ConnectionActive { get; set; }
    public List<Dictionary<string, object>>? SequentialSchema { get; private set; }

    public int CurrentSequenceIndex { get; private set; }

    public DateTime LastMessageReceived { get; set; }

    public StingrayWS(WebSocket ws, List<Dictionary<string, object>>? sequentialSchema = null)
    {
        WebSocket = ws;
        OriginTime = DateTime.UtcNow;
        LastMessageReceived = DateTime.UtcNow;
        ConnectionActive = true;

        SequentialSchema = sequentialSchema;

        if (sequentialSchema?.Count > 0)
        {
            CurrentSequenceIndex = 1;
        }
    }

    public void NextIndex()
    {
        if (CurrentSequenceIndex == SequentialSchema.Select(x => Convert.ToInt32(x["StageID"])).Max())
        {
            throw new Exception(@"");
        }

        CurrentSequenceIndex++;
    }

    public void Dispose()
    {
        ConnectionActive = false;
        WebSocket.Dispose();
    }

}
