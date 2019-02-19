let pasteInfos = document.getElementsByClassName ('pasteInfo');

for (let i = 0; i < pasteInfos.length; i++)
{
    let createdAtSpan = pasteInfos [i].getElementsByClassName ('createdAt') [0];
    let expiresInSpan = pasteInfos [i].getElementsByClassName ('expiresIn') [0];

    let date = new Date (createdAtSpan.innerText * 1000);
    createdAtSpan.innerText = date.toLocaleString ();

    if (expiresInSpan !== undefined)
    {
        let expiresInDate = addTime (date, expiresInSpan.innerText);
        let timeDifference = Math.abs (expiresInDate.getTime () - new Date ().getTime ());
        expiresInSpan.innerText = timeDifferenceToString (timeDifference);
    }
}

function addTime (date, amount)
{
    let result = new Date (date);

    switch (amount)
    {
        case '1h':
        {
            result.setTime (result.getTime () + (1*60*60*1000));
        } break;
        case '2h':
        {
            result.setTime (result.getTime () + (2*60*60*1000));
        } break;
        case '10h':
        {
            result.setTime (result.getTime () + (10*60*60*1000));
        } break;
        case '1d':
        {
            result.setTime (result.getTime () + (24*60*60*1000));
        } break;
        case '2d':
        {
            result.setTime (result.getTime () + (48*60*60*1000));
        } break;
        case '1w':
        {
            result.setTime (result.getTime () + (168*60*60*1000));
        } break;
    }

    return result;
}

function timeDifferenceToString (timeDifference)
{
    if (timeDifference <= 59000)
        return Math.ceil (timeDifference / 1000).toString () + ' seconds';
    if (timeDifference <= 3540000)
        return Math.ceil (timeDifference / 60000).toString () + ' minutes';
    if (timeDifference <= 82800000)
        return Math.ceil (timeDifference / 3600000).toString () + ' hours';
    if (timeDifference <= 518400000)
        return Math.ceil (timeDifference / 86400000).toString () + ' days';
}
