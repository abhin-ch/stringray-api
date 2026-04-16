using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using StingrayNET.ApplicationCore.HelperFunctions;

//namespace DEMSLib
namespace StingrayNET.ApplicationCore.Models.VDU
{
    public static class StringExtension
    {
        public enum CharLoc
        {
            First = 1,
            Last = 2
        }

        public static string ReturnBeforeFirstOrLastCharacter(this string myString, string myCharacter, CharLoc myLocation)
        {
            // Error will be handled by the calling function
            string myReturnValue = "";
            if (myLocation == CharLoc.First)
                myReturnValue = myString.Substring(0, myString.IndexOf(myCharacter));
            else if (myLocation == CharLoc.Last)
                myReturnValue = myString.Substring(0, myString.LastIndexOf(myCharacter));

            return myReturnValue;
        }

        /// <summary>
        /// Returns a shorten text e.g. Quick brown fox jumps over the lazy dog can become Quick brown fox... based on length required
        /// </summary>
        /// <param name="myString">Original string to shorten</param>
        /// <param name="myLength">The total length required</param>
        /// <returns></returns>
        public static string ShortenText(this string myString, int myLength)
        {
            if (myString.Length > myLength)
                return myString.Substring(0, myLength - 3) + "...";
            else
                return myString;
        }

        /// <summary>
        /// Returns a truncated string based on length required (no ellipses)
        /// </summary>
        /// <param name="myString">Original string to shorten</param>
        /// <param name="myLength">The total length required</param>
        /// <returns></returns>
        public static string Truncate(this string myString, int myLength)
        {
            if (VDUVerification.IsMyValueEmpty(myString))
                return myString;
            if (myString.Length > myLength)
                return myString.Substring(0, myLength);
            else
                return myString;
        }

        /// <summary>
        /// Returns a string with single quotes on either side if requried i.e. for non numeric text
        /// </summary>
        /// <param name="myString"></param>
        /// <returns></returns>
        public static string DecorateWithQuoteIfRequired(this string myString)
        {
            if (VDUVerification.IsMyPassedTextValid(VDUVerification.TextAllowedValue.F_Integer, myString) == true | VDUVerification.IsMyPassedTextValid(VDUVerification.TextAllowedValue.G_Decimal, myString) == true)
                // It's a number return as is
                return myString;
            else
                // Decorate with single quote
                return string.Format("{0}" + myString + "{1}", "'", "'");
        }
    }

    public static class EnumExtension
    {
        /// <summary>
        /// Checks if the enumerable set of enums contains any of the enums provided in the parameter args
        /// </summary>
        /// <remarks>If project is upgraded to C# 7.3+, change "struct, IConvertible" to "System.Enum"</remarks>
        /// <typeparam name="TEnum">Must be an enum type</typeparam>
        /// <param name="myEnumerable">IEnumerable set of TEnum</param>
        /// <param name="enums">Argument param list of enums to check</param>
        /// <returns>True if any param arg is in the set</returns>
        public static bool HasAnyInList<TEnum>(this IEnumerable<TEnum> myEnumerable, params TEnum[] enums) where TEnum : struct, IConvertible
        {
            Type t = typeof(TEnum);
            if (!t.IsEnum)
                return false;

            HashSet<TEnum> myEnumHashSet = myEnumerable as HashSet<TEnum>; //Create hashset from enumerable if it isn't already one
            if(myEnumHashSet == null)
                myEnumHashSet = new HashSet<TEnum>(myEnumerable);
            return enums.Any(enumVal => myEnumHashSet.Contains(enumVal));
        }

        /// <summary>
        /// Checks if the enumerable set of enums contains all of the enums provided in the parameter args
        /// </summary>
        /// <remarks>If project is upgraded to C# 7.3+, change "struct, IConvertible" to "System.Enum"</remarks>
        /// <typeparam name="TEnum">Must be an enum type</typeparam>
        /// <param name="myEnumerable">IEnumerable set of TENum</param>
        /// <param name="enums">Argument param list of enums to check</param>
        /// <returns>True if any param arg is in the set</returns>
        public static bool HasAllInList<TEnum>(this IEnumerable<TEnum> myEnumerable, params TEnum[] enums) where TEnum : struct, IConvertible
        {
            Type t = typeof(TEnum);
            if (!t.IsEnum)
                return false;

            HashSet<TEnum> myEnumHashSet = myEnumerable as HashSet<TEnum>; //Create hashset from enumerable if it isn't already one
            if (myEnumHashSet == null)
                myEnumHashSet = new HashSet<TEnum>(myEnumerable);
            return enums.All(enumVal => myEnumHashSet.Contains(enumVal));
        }
    }
}
