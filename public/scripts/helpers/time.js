export function timeDifferenceToString(timeDifference)
{
    let resTime;
    let resString;

    if (timeDifference <= 59000)
    {
        resTime = Math.ceil(timeDifference / 1000);
        resString = `${resTime.toString()} seconds`;
    }
    else if (timeDifference <= 3540000)
    {
        resTime = Math.ceil(timeDifference / 60000);
        resString = `${resTime.toString()} minutes`;
    }
    else if (timeDifference <= 82800000)
    {
        resTime = Math.ceil(timeDifference / 3600000);
        resString = `${resTime.toString()} hours`;
    }
    else if (timeDifference <= 518400000)
    {
        resTime = Math.ceil(timeDifference / 86400000);
        resString = `${resTime.toString()} days`;
    }
    else if (timeDifference <= 2419200000)
    {
        resTime = Math.ceil(timeDifference / 604800000);
        resString = `${resTime.toString()} weeks`;
    }
    else if (timeDifference <= 28927800000)
    {
        resTime = Math.ceil(timeDifference / 2629800000);
        resString = `${resTime.toString()} months`;
    }
    else
    {
        resTime = Math.ceil(timeDifference / 31557600000);
        resString = `${resTime.toString()} years`;
    }

    // If the time is just one, remove the s so the time is singular
    if (resTime === 1)
    {
        resString = resString.slice(0, resString.length - 1);
    }

    return resString;
}
