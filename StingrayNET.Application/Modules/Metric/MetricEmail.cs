using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.Graph;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.HelperFunctions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Admin;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.Models.Metric;
using StingrayNET.ApplicationCore.Specifications;

public interface IMetricEmails
{
    public void SendEmail(MetricProcedure model);
}

public class MetricEmails : IMetricEmails
{

    readonly IRepositoryXL<MetricProcedure, MetricResult> _repository;
    readonly IHttpContextAccessor _httpContextAccessor;
    readonly IBaseEmailService _baseEmailService;


    public class MetricRecord
    {
        public string UniqueID { get; set; }
        public string MeasureName { get; set; }
        public string OwnerC { get; set; }
        public string Owner { get; set; }
        public string Email { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Status { get; set; }
        // public string DueDate { get; set; }
    }

    public MetricEmails(IRepositoryXL<MetricProcedure, MetricResult> repository, IBaseEmailService baseEmailService,
    IHttpContextAccessor httpContextAccessor)
    {
        _httpContextAccessor = httpContextAccessor;
        _repository = repository;
        _baseEmailService = baseEmailService;
    }

    public async void SendEmail(MetricProcedure model)
    {
        User? originalUser = (User)_httpContextAccessor.HttpContext.Items[@"OriginalSTNGUser"];
        bool impersonating = _httpContextAccessor.HttpContext.Request.Headers.ContainsKey(@"STNG-IMPERSONATE-AS");

        MetricProcedure emailModel = new MetricProcedure();
        emailModel.Value1 = model.Value1;

        model.SubOp = 1;
        MetricResult allMetrics = await _repository.Op_80(model);

        model.SubOp = 2;
        MetricResult emailTemplate = await _repository.Op_80(model);

        List<string> EmailUsersToBeSent = DataParser.GetListFromData(allMetrics.Data1, "Email");

        EmailUsersToBeSent = EmailUsersToBeSent
            .Where(s => !string.IsNullOrWhiteSpace(s))
            .Distinct()
            .ToList();

        // //email template
        var subject = DataParser.GetValueFromData<string>(emailTemplate.Data1, "Subject");
        var body = DataParser.GetValueFromData<string>(emailTemplate.Data1, "Body");

        List<object> metricData = allMetrics.Data1;

        // Convert database rows (Dictionary<string,object>) → MetricRecord objects
        var typedMetricData = metricData
            .Cast<Dictionary<string, object>>()
            .Select(d => new MetricRecord
            {
                UniqueID = d["UniqueID"]?.ToString(),
                MeasureName = d["MeasureName"]?.ToString(),
                OwnerC = d["OwnerC"]?.ToString(),
                Owner = d["Owner"]?.ToString(),
                Email = d["Email"]?.ToString(),
                FirstName = d["FirstName"]?.ToString(),
                LastName = d["LastName"]?.ToString(),
                Status = d["StatusC"]?.ToString()
            })
            .ToList();

        for (int i = 0; i < EmailUsersToBeSent.Count; i++)
        {
            var email = new QuickEmailTemplate();
            email.toList = new List<string> { EmailUsersToBeSent[i] };

            var userMetricData = typedMetricData
                .Where(x => x.Email == EmailUsersToBeSent[i])
                .ToList();

            await _baseEmailService.SendEmail(
                token => BuildEmail(emailModel, userMetricData, email, subject, body),
                originalUser,
                impersonating
            );
        }

    }


    private async Task<QuickEmailTemplate> BuildEmail(MetricProcedure model, List<MetricRecord> data, QuickEmailTemplate emailTemplate, string subject, string body)
    {

        // //fields
        string? name = data.FirstOrDefault()?.FirstName;
        //Inserted Values
        var keyValuePairs = new Dictionary<string, string>
        {
            { "[Name]", name },
        };

        // //hyperlink dependent on environment
        // string? env = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT");
        // string DeepLink = "https://stingray.brucepower.com/er";

        // if (env == null || env.Equals("Production", StringComparison.OrdinalIgnoreCase))
        // {
        //     DeepLink = $"https://stingray.brucepower.com/ER?ER={ER}";
        // }
        // else if (env.Equals("QA", StringComparison.OrdinalIgnoreCase))
        // {
        //     DeepLink = $"https://stingrayqafe.azurewebsites.net/ER?ER={ER}";
        // }
        // else if (env.Equals("Development", StringComparison.OrdinalIgnoreCase))
        // {
        //     DeepLink = $"https://stingraydevfe.azurewebsites.net/ER?ER={ER}";
        // }
        // keyValuePairs.Add("[DeepLink]", DeepLink);

        //Metric Table






        var metricTable = "<style>table{border-style: solid;border-width:1px;border-color: black;border-collapse: collapse;}</style><table cellpadding=5 cellspacing=0 border='1'><tr> <td bgcolor=#E6E6FA><b>Metric Name</b></td> <td bgcolor=#E6E6FA><b>Status</b></td>";

        for (int i = 0; i < data.Count; i++)
        {
            var status = data[i].Status?.Trim() ?? string.Empty;
            var statusLower = status.ToLowerInvariant();
            string statusColor = statusLower switch
            {
                "awaiting input" => "#fff563",
                "revision required" => "red",
                "ready for review" => "white",
                _ => "white"
            };

            metricTable += "<tr><td>[MeasureName" + i.ToString() + "]</td><td style='background-color:" + statusColor + "'>[Status" + i.ToString() + "]</td>";
            keyValuePairs.Add($"[MeasureName{i}]", data[i].MeasureName.Equals("") ? "" : data[i].MeasureName.ToString());
            keyValuePairs.Add($"[Status{i}]", data[i].Status.Equals("") ? "" : data[i].Status.ToString());
        }
        metricTable += "</table>";

        metricTable = Template.Populate(metricTable, keyValuePairs);
        keyValuePairs.Add("[MetricTable]", metricTable);


        emailTemplate.subject = Template.Populate(subject, keyValuePairs);
        emailTemplate.emailBody = Template.Populate(body, keyValuePairs);

        return emailTemplate;
    }

}