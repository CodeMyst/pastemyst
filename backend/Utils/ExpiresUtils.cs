using System;
using PasteMyst.Models;

namespace PasteMyst.Utils
{
    public static class ExpiresUtils
    {
        /// <summary>
        /// Returns the time when the paste is supposed to be deleted, based on its creation time and the expires in value.
        /// </summary>
        public static DateTime? GetDeletionTime(DateTime createdAt, ExpiresIn expiresIn) => expiresIn switch
        {
            ExpiresIn.Never => null,
            ExpiresIn.OneHour => createdAt.AddHours(1),
            ExpiresIn.TwoHours => createdAt.AddHours(2),
            ExpiresIn.TenHours => createdAt.AddHours(10),
            ExpiresIn.OneDay => createdAt.AddDays(1),
            ExpiresIn.TwoDays => createdAt.AddDays(2),
            ExpiresIn.OneWeek => createdAt.AddDays(7),
            ExpiresIn.OneMonth => createdAt.AddMonths(1),
            ExpiresIn.OneYear => createdAt.AddYears(1),
            _ => null,
        };
    }
}