using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StingrayNET.ApplicationCore.Models.ExpressionSerializer
{
    public enum ComparisonOperator
    {
        Equals = 1,
        NotEquals = 2,
        GreaterThan = 3,
        LessThan = 4,
        GreaterThanEquals = 5,
        LessThanEquals = 6
    }

    public enum LogicalOperator
    {
        AND = 1,
        OR = 2
    }

}
