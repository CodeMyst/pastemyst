let alpha = "abcdefghijklmnopqrstuvwxyz";
let nums = "0123456789";
let alphanum = alpha + nums;
let symbols = "-_.";
let alphanumerics = alpha + nums + symbols;

export function usernameHasSpecialChars(username)
{
    for (let i = 0; i < username.length; i++)
    {
        if (!alphanumerics.includes(username.charAt(i).toLowerCase()))
        {
            return true;
        }
    }

    return false;
}

export function usernameStartsWithSymbol(username)
{
    if (!alphanum.includes(username.charAt(0).toLowerCase()))
    {
        return true;
    }

    return false;
}

export function usernameEndsWithSymbol(username)
{
    if (!alphanum.includes(username.charAt(username.length-1).toLowerCase()))
    {
        return true;
    }

    return false;
}