using System;
using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Text.RegularExpressions;

namespace StingrayNET.ApplicationCore.Models.ExpressionSerializer
{
    public class Expression
    {
        public Dictionary<string, Term> Terms { get; private set; }
        public Dictionary<string, ElementaryExpression> ElementaryExpressions { get; private set; }
        public Dictionary<string, CompositeExpression> CompositeExpressions { get; private set; }

        public string OriginalExpression { get; private set; }

        public string TopExpression { get; private set; }

        public Expression(Dictionary<string, Term> terms, Dictionary<string, ElementaryExpression> elementaryExpressions, Dictionary<string, CompositeExpression> compositeExpressions, string originalExpression, string topExpression)
        {
            if (terms == null || elementaryExpressions == null || compositeExpressions == null || string.IsNullOrEmpty(originalExpression) || string.IsNullOrEmpty(topExpression))
            {
                throw new ArgumentNullException(@"terms, elementaryExpressions, compositeExpressions, originalExpression, and/or topExpression", @"Non-null/empty values must be provided for all parameters");
            }

            Terms = terms;
            ElementaryExpressions = elementaryExpressions;
            OriginalExpression = originalExpression;
            CompositeExpressions = compositeExpressions;

            bool topInCompositeorElem = false;
            if (Regex.IsMatch(topExpression, @"^\@(C|E)[0-9]+\@$"))
            {
                string topExpKey = Regex.Match(topExpression, @"^\@(C|E)[0-9]+\@$").Value;

                if (CompositeExpressions.ContainsKey(topExpKey) || ElementaryExpressions.ContainsKey(topExpKey))
                {
                    topInCompositeorElem = true;
                }
            }

            if (!topInCompositeorElem)
            {
                throw new ArgumentException($"topExpression must be a valid Composite or Elementary Expression with a corresponding entry in either the CompositeExpressions/ElementaryExpressions collections. This usually occurs if the provided original string ({originalExpression}) does not contain comparison operators or spaces. It may also be caused by incomplete logical operations (i.e., and/or expressions without a left or right term)");
            }

            TopExpression = topExpression;

        }

    }
}
