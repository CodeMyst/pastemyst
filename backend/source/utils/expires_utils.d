module utils.expires_utils;

import std.datetime;
import std.typecons;
import model;

@safe:

public Nullable!DateTime getDeletionTime(DateTime createdAt, ExpiresIn expiresIn)
{
    DateTime res = createdAt;

    final switch (expiresIn)
    {
        case ExpiresIn.never: return Nullable!DateTime.init;
        case ExpiresIn.oneHour: res.roll!"hours"(1); break;
        case ExpiresIn.twoHours: res.roll!"hours"(2); break;
        case ExpiresIn.tenHours: res.roll!"hours"(10); break;
        case ExpiresIn.oneDay: res.roll!"days"(1); break;
        case ExpiresIn.twoDays: res.roll!"days"(2); break;
        case ExpiresIn.oneWeek: res.roll!"days"(7); break;
        case ExpiresIn.oneMonth: res.roll!"months"(1); break;
        case ExpiresIn.oneYear: res.roll!"years"(1); break;
    }

    return res.nullable;
}

