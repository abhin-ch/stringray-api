using System;
using StingrayNET.ApplicationCore.HelperFunctions;

//namespace DEMSLib
namespace StingrayNET.ApplicationCore.Models.VDU
{
    public class VDSValidationRule
    {
        public int ColRuleId { get; private set; }
        public VDUVerification.TextAllowedValue RuleId { get; private set; }

        //Rule values with custom set criteria
        private string _ruleValue;
        public string RuleValue
        {
            get { return _ruleValue; }
            set
            {
                //Integer required > 0 for maxlength
                if (RuleId == VDUVerification.TextAllowedValue.AF_MaximumLength)
                {
                    if (int.TryParse(value, out int myInteger) && myInteger > 0)
                        _ruleValue = value.Trim();
                }
                else
                {
                    _ruleValue = value;
                }
            }
        }

        public VDSVerification.RuleType RuleType { get; set; }

        //Rule filter
        public string RuleFilter { get; set; }

        //Rule query - resulting query result can be used in value and filter using keywords
        public string RuleQuery { get; set; }

        //Override the default error message
        public string RuleMessageOverride { get; set; }

        public string RuleDesc { get; private set; }

        public VDSValidationRule(int colRuleId, VDUVerification.TextAllowedValue ruleId, string ruleValue, string ruleFilter, string ruleQuery, string ruleMessageOverride, string ruleDesc, VDSVerification.RuleType ruleType)
        {
            ColRuleId = colRuleId;
            RuleId = ruleId;
            RuleValue = ruleValue;
            RuleFilter = ruleFilter;
            RuleQuery = ruleQuery;
            RuleMessageOverride = ruleMessageOverride;
            RuleType = ruleType;
            RuleDesc = ruleDesc;
        }
    }
}