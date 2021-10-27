using System;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PasteMyst.Utils
{
    public static class IdUtils
    {
        private const string Base36Chars = "0123456789abcdefghijklmnopqrstuvwxyz";

        private static readonly Random Rnd = new();

        /// <summary>
        ///     Encodes a long value to a base36 string.
        /// </summary>
        public static string EncodeBase36(long value)
        {
            var sb = new StringBuilder();
            long temp = value;
            while (temp != 0)
            {
                sb.Append(Base36Chars[(int) (temp % 36)]);
                temp /= 36;
            }

            return new string(sb.ToString().Reverse().ToArray());
        }

        /// <summary>
        ///     Generates a random 8 character ID.
        /// </summary>
        public static string RandomId()
        {
            // magic numbers for smallest and biggest 8 character ids.
            const long min = 78_364_164_096;
            const long max = 2_821_109_907_455;

            const ulong range = max - min;

            // generate random long number in range
            // https://stackoverflow.com/a/13095144
            ulong ulongRand;
            do
            {
                var buf = new byte[8];
                Rnd.NextBytes(buf);
                ulongRand = (ulong) BitConverter.ToInt64(buf, 0);
            } while (ulongRand > ulong.MaxValue - (ulong.MaxValue % range + 1) % range);

            long rand = (long) (ulongRand % range) + min;

            return EncodeBase36(rand);
        }

        /// <summary>
        ///     Generates a random 8 character ID as long as the predicate is true.
        /// </summary>
        public static async Task<string> RandomIdPred(Func<string, Task<bool>> p)
        {
            string id;

            do
            {
                id = RandomId();
            } while (await p.Invoke(id));

            return id;
        }
    }
}