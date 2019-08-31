/**
 * Converts the expires in string to a unix time
 * 
 * @param expiresIn expires in string
 * @param unixTime unix time to which expires in is added
 */
export function expiresInToUnixTime (expiresIn: string, unixTime: number): number
{
    let res = unixTime;

    switch (expiresIn)
    {
        case "1h":
            res += 3600;
            break;
        case "2h":
            res += 2 * 3600;
            break;
        case "10h":
            res += 10 * 3600;
            break;
        case "1d":
            res += 24 * 3600;
            break;
        case "2d":
            res += 48 * 3600;
            break;
        case "1w":
            res += 168 * 3600;
            break;
        case "never":
            res = 0;
            break;
        default: break;
    }

    return res;
}

/**
 * Converts a time difference (in milliseconds) to a string
 * 
 * @param timeDifference time in milliseconds
 */
export function timeDifferenceToString (timeDifference: number): string
{
    let resTime: number;
    let resString: string;

    if (timeDifference <= 59000)
    {
        resTime = Math.ceil (timeDifference / 1000);
        resString = `${resTime.toString ()} seconds`;
    }
    else if (timeDifference <= 3540000)
    {
        resTime = Math.ceil (timeDifference / 60000);
        resString = `${resTime.toString ()} minutes`;
    }
    else if (timeDifference <= 82800000)
    {
        resTime = Math.ceil (timeDifference / 3600000);
        resString = `${resTime.toString ()} hours`;
    }
    else if (timeDifference <= 518400000)
    {
        resTime = Math.ceil (timeDifference / 86400000);
        resString = `${resTime.toString ()} days`;
    }
    else
    {
        resTime = Math.ceil (timeDifference / 604800000);
        resString = `${resTime.toString ()} weeks`;
    }

    // If the time is just one, remove the s so the time is singular
    if (resTime === 1)
    {
        resString = resString.slice (0, resString.length - 1);
    }

    return resString;
}
