using OfficeOpenXml.Style;
using System.Drawing;
using System.Text.Json.Serialization;

namespace StingrayNET.ApplicationCore.Models.ExcelService
{
    public class ExcelCellFormat
    {
        public bool? Bold { get; private set; }
        public bool? Italic { get; private set; }
        public bool? Underlined { get; private set; }

        [JsonIgnore]
        public Color BGColourDotnet { get; private set; }

        public string? BGColour { get; private set; }

        [JsonIgnore]
        public Color FGColourDotnet { get; private set; }

        public string? FGColour { get; private set; }

        [JsonConverter(typeof(JsonStringEnumConverter))]
        public ExcelBorderStyle? TopBorder { get; private set; }

        [JsonConverter(typeof(JsonStringEnumConverter))]
        public ExcelBorderStyle? BottomBorder { get; private set; }

        [JsonConverter(typeof(JsonStringEnumConverter))]
        public ExcelBorderStyle? LeftBorder { get; private set; }

        [JsonConverter(typeof(JsonStringEnumConverter))]
        public ExcelBorderStyle? RightBorder { get; private set; }

        [JsonConverter(typeof(JsonStringEnumConverter))]
        public ExcelBorderStyle? AllBorder { get; private set; }

        public ExcelCellFormat(bool? bold = false, bool? italic = false, bool? underlined = false, string? bgcolour = @"#FFFFFF", string? fgcolour = @"#010101", ExcelBorderStyle? topBorder = null, ExcelBorderStyle? bottomBorder = null, ExcelBorderStyle? leftBorder = null, ExcelBorderStyle? rightBorder = null, ExcelBorderStyle? allBorder = null)
        {
            Bold = bold;
            Italic = italic;
            Underlined = underlined;

            BGColour = bgcolour;
            BGColourDotnet = ColorTranslator.FromHtml(bgcolour);

            FGColour = fgcolour;
            FGColourDotnet = ColorTranslator.FromHtml(fgcolour);


            if (leftBorder != null || rightBorder != null || bottomBorder != null || topBorder != null)
            {
                TopBorder = topBorder;
                BottomBorder = bottomBorder;
                LeftBorder = leftBorder;
                RightBorder = rightBorder;
            }

            else
            {
                if (allBorder == null)
                {
                    AllBorder = ExcelBorderStyle.Thin;
                }

                else
                {
                    AllBorder = allBorder;
                }

                TopBorder = AllBorder;
                BottomBorder = AllBorder;
                LeftBorder = AllBorder;
                RightBorder = AllBorder;

            }

        }

    }
}
