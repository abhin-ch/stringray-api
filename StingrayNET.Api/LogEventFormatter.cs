using Serilog.Events;
using Serilog.Formatting;
using System;
using System.IO;
using System.Linq;

namespace StingrayNET.Api
{
    public class LogEventFormatter : ITextFormatter
    {
        public static LogEventFormatter Formatter { get; } = new LogEventFormatter();

        public void Format(LogEvent logEvent, TextWriter output)
        {
            logEvent.Properties.ToList()
                .ForEach(e => output.Write($"{e.Key}={e.Value} "));
        }
    }
}
