using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.SST;

namespace StingrayNET.Api.Controllers;

[Authorize]
[Route("api/[controller]")]
[ApiController]
public class SSTController : ControllerBase
{
    private readonly IRepositoryL<SSTProcedure, SSTResult> _repository;

    public SSTController(IRepositoryL<SSTProcedure, SSTResult> repository)
    {

        _repository = repository;
    }

    //Get api/sst
    //No params
    [HttpGet]
    public async Task<JsonResult> MainTable()
    {
        var result = await _repository.Op_01();
        foreach (Dictionary<string, object> dict1 in result.Data1)
        {
            //Calculate annual cost w/ OH
            if (dict1["FREQUNIT"] is string && dict1["FREQUENCY"] is double && dict1["SingleExecutionCost"] is double)
            {
                double timesAYear = 0;
                double frequency = (double)dict1["FREQUENCY"];
                if (((string)dict1["FREQUNIT"]).Equals("DAYS"))
                {
                    timesAYear = 365 / frequency;
                }
                else if (((string)dict1["FREQUNIT"]).Equals("WEEKS"))
                {
                    timesAYear = 52 / frequency;
                }
                else if (((string)dict1["FREQUNIT"]).Equals("MONTHS"))
                {
                    timesAYear = 12 / frequency;
                }
                double annualCost = Math.Round(timesAYear * (double)dict1["SingleExecutionCost"], 2);
                dict1.Add("AnnualCostOH",
                (annualCost).ToString()
                );


            }
            else
            {
                dict1.Add("AnnualCostOH",
            (0).ToString()
            );
            }

            //Round other vals down to hundredths
            double SingleExecRounded = Math.Round(double.TryParse(dict1["SingleExecutionCost"]?.ToString(), out double val1) ? val1 : 0, 2);
            double PreDoseCostRounded = Math.Round(double.TryParse(dict1["PreDoseCost"]?.ToString(), out double val2) ? val2 : 0, 2);
            double DoseRounded = Math.Round(double.TryParse(dict1["Dose"]?.ToString(), out double val3) ? val3 : 0, 2);

            dict1["SingleExecutionCost"] = SingleExecRounded.ToString();
            dict1["PreDoseCost"] = PreDoseCostRounded.ToString();
            dict1["Dose"] = DoseRounded.ToString();
        }
        return BaseResult.JsonResult(result);
    }

    //POST api/sst/comment
    //Requires SSTID and CommentType
    [HttpPost]
    [Route("comment")]
    public async Task<JsonResult> GetComments([FromBody] SSTProcedure model)
    {
        var result = await _repository.Op_02(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/sst/comment
    //Requires SSTID, CommentType, and Comment
    [HttpPut]
    [Route("comment")]
    public async Task<JsonResult> AddComment([FromBody] SSTProcedure model)
    {
        var result = await _repository.Op_03(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/sst/comment
    //Requires SSTCommentID
    [HttpDelete]
    [Route("comment")]
    public async Task<JsonResult> RemoveComment([FromBody] SSTProcedure model)
    {
        var result = await _repository.Op_04(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/sst/historical
    //Requires SSTID
    [HttpPost]
    [Route("historical")]
    public async Task<JsonResult> GetHistoricalInfo([FromBody] SSTProcedure model)
    {
        var result = await _repository.Op_05(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/sst/historical/metric
    //Requires SSTID
    [HttpPost]
    [Route("historical/metric")]
    public async Task<JsonResult> GetHistoricalInfoMetrics([FromBody] SSTProcedure model)
    {
        var result = await _repository.Op_06(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/sst/location
    //Requires SSTID
    [HttpPost]
    [Route("location")]
    public async Task<JsonResult> GetLocations([FromBody] SSTProcedure model)
    {
        var result = await _repository.Op_07(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/sst/osr
    //Requires SSTID
    [HttpPost]
    [Route("osr")]
    public async Task<JsonResult> GetOSRs([FromBody] SSTProcedure model)
    {
        var result = await _repository.Op_08(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/sst/soeref
    //Requires SSTID
    [HttpPost]
    [Route("soeref")]
    public async Task<JsonResult> GetSOERefs([FromBody] SSTProcedure model)
    {
        var result = await _repository.Op_09(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/sst/related-pmids
    //Requires SSTNo
    [HttpPost]
    [Route("related-pmids")]
    public async Task<JsonResult> GetRelatedPMIDs([FromBody] SSTProcedure model)
    {
        var result = await _repository.Op_13(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/sst/header
    //Requires SSTID
    [HttpPatch]
    [Route("header")]
    public async Task<JsonResult> UpdateSSTHeaderInfo([FromBody] SSTProcedure model)
    {
        var result = await _repository.Op_14(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/sst/header
    //Requires SSTID
    [HttpPost]
    [Route("header")]
    public async Task<JsonResult> GetSSTHeaderInfo([FromBody] SSTProcedure model)
    {
        var result = await _repository.Op_15(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/sst/all-comments
    //Requires SSTID
    [HttpPost]
    [Route("all-comments")]
    public async Task<JsonResult> GetAllSSTComments([FromBody] SSTProcedure model)
    {
        var result = await _repository.Op_02(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/sst/all-files
    //Requires SSTID
    [HttpPost]
    [Route("all-files")]
    public async Task<JsonResult> GetAllSSTFiles([FromBody] SSTProcedure model)
    {
        var result = await _repository.Op_16(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/sst/copy-comments
    //Requires SSTCloneIDList
    [HttpPost]
    [Route("copy-comments")]
    public async Task<JsonResult> CopyComments([FromBody] SSTProcedure model)
    {
        var result = await _repository.Op_12(model);
        return BaseResult.JsonResult(result);
    }


    //GET api/sst/legacy-file-upload
    [AllowAnonymous]
    [HttpGet]
    [Route("legacy-file-upload")]
    public async Task UploadLegacyFile()
    {
        await _repository.Op_17();
    }
}