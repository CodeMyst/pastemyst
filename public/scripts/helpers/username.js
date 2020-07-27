let alpha = "abcdefghijklmnopqrstuvwxyz";
let nums = "0123456789";
let symbols = "-_";
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