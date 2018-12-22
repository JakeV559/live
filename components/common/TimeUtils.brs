'*************************************************************
'** nameOfFunction getTwelveHourClockTime
'** @brief get 12-hour clock time,end with am or pm
'** @param param the "yyyy-MM-dd" time string
'** @return return "hh:mm am" or "hh:mm pm"
'*************************************************************
function getTwelveHourClockTime(s as String) as String
    t = right(s, 8)
    t = left(t, 5)
    h = val(left(t,2), 10)
    if h <> invalid
        if h = 0
            h = 12
            return h.ToStr() + right(t, 3) + " am"
        else if h < 12
            return t + " am"
        else if h = 12
            return t + " pm"
        else
            h = (h - 12)
            return h.ToStr() + right(t, 3) + " pm"
        end if
    else
        print "format time error: param is invalid"
        return ""
    end if
end function

'*************************************************************
'** transferToLocalDate
'** @brief  transfer UTC Time to LocalTime
'** @param playTimeinMills as String:
'** @return String :format String: eg.2017-01-05 16:31:56
'*************************************************************
function transferToLocalDate(playTimeinMills as String) as String
    date = CreateObject("roDateTime")
    timeZoneOffset = date.GetTimeZoneOffset()
    if playTimeinMills.Len()>3
        subPlayTimeinMillsStr = left(playTimeinMills, playTimeinMills.Len()-3)
        date.FromSeconds(subPlayTimeinMillsStr.ToInt()-timeZoneOffset*60)
        s = date.ToISOString()  'eg: 2017-01-03T16:44:37Z
        if s.Len() >= 20
            s =  Mid(s,1,10) + " " + Mid(s,12,8)
        else
            s = ""
        end if
        return s
    end if
    return ""
end function

function getPlayTime(playTimeinMills as String) as String
    if playTimeinMills <>invalid
        playTime = transferToLocalDate(playTimeinMills)
        playTime = getTwelveHourClockTime(playTime)
        return playTime
    else
        return ""
    end if
end function

'*************************************************************
'** getDayNearToday
'** @brief get all today yes,tom  in24h
'** @param param as playTimeinMills :String
'** @return String dateFormart
'*************************************************************
function getDayNearToday(playTimeinMills as Object) as String
        if playTimeinMills <>invalid
            playTime = transferToLocalDate(playTimeinMills)
            if playTimeinMills.Len()>3 and playTime.Len()>14
                subWebTimeStr = left(playTimeinMills, playTimeinMills.Len()-3)
                date = CreateObject("roDateTime")
                date.ToLocalTime()

                oneDaySecond = 60*60*24
                sencondstotal = Abs(subWebTimeStr.ToInt() - date.AsSeconds())  'sub of two days
                timeHM = getTwelveHourClockTime(playTime)

                'in 48h
                if sencondstotal < oneDaySecond*2
                    ld = date.GetDayOfMonth()
                    if isSameDay(playTimeinMills)
                        return timeHM
                    end if

                    'yesterday
                    date.FromSeconds(subWebTimeStr.ToInt()+oneDaySecond)
                    date.ToLocalTime()
                    webYestodayTime = date.GetDayOfMonth()
                    if ld = webYestodayTime
                        return "yday " + timeHM
                    end if

                    'tomorow
                    date.FromSeconds(subWebTimeStr.ToInt()-oneDaySecond)
                    date.ToLocalTime()
                    webTomorowTime = date.GetDayOfMonth()
                    if ld = webTomorowTime
                        return "tmr " + timeHM
                    end if
                end if

                'others' case
                return Mid(playTime,6,5) + " "+ timeHM
            end if
        end if
    return ""
end function

'*************************************************************
'** isSameDay
'** @brief is the SameDay
'** @param param as playTimeinMills String
'** @return ObjectR Boolean
'************************************************************* d
function isSameDay(playTimeinMills as Object) as Boolean
    if playTimeinMills <>invalid
        playTime = transferToLocalDate(playTimeinMills)
        playTimeinMills = playTimeinMills
        if playTime.Len()>=14
            wy = left(playTime, 4).ToInt()
            wm = Mid(playTime,6,2).ToInt()
            wd = Mid(playTime,9,2).ToInt()
            wh = Mid(playTime,12,2).ToInt()

            date = CreateObject("roDateTime")
            date.ToLocalTime()
            ly = date.GetYear()
            lm = date.GetMonth()
            ld = date.GetDayOfMonth()
            lh = date.GetHours()

            if wy=ly and wm = lm and wd = ld
                return true
            else
                return false
            end if
        else
            return false
        end if
    end if
end function

'*************************************************************
'** nameOfFunction getHours
'** @brief convert seconds to hours, end with hrs
'** @param param the seconds string
'** @return return "xxx hrs"
'*************************************************************
function getHours(d as String) as String
    if d <> invalid
        temp = val(d)
        temp = temp / 3600
        return mid(str(temp), 1, 4) + "hrs"
    else
        return ""
    end if
end function

function getCurrentDateSeconds() as Integer
    date = CreateObject("roDateTime")
    curSencond = date.AsSeconds()
    return curSencond
end function

'*************************************************************
'** getPlayTimeinMillsSeconds
'** @param param as playTimeinMills:String
'** @return true:playTimeinMills:Integer
'*************************************************************
function getPlayTimeinMillsSeconds(playTimeinMills as String) as Integer
    if playTimeinMills.Len()>3
        subPlayTimeinMillsStr = left(playTimeinMills, playTimeinMills.Len()-3)
        subTime = subPlayTimeinMillsStr.toInt()
        return subTime
    end if
    return 0
end function

'*************************************************************
'** isNeedRequestMutiliveAtOnce
'** @brief description
'** @param param as playTimeinMills:last playTime
'** @return true:AtOnce
'*************************************************************
function isNeedRequestMutiliveAtOnce(playTimeinMills as String) as Boolean
    curSencond = getPlayTimeinMillsSeconds(playTimeinMills)
    if playTimeinMills.Len()>3 and curSencond>0
        subPlayTimeinMillsStr = left(playTimeinMills, playTimeinMills.Len()-3)
        subTime = subPlayTimeinMillsStr.toInt()
        if curSencond < subTime
            return true
        else
            return false
        end if
    end if
    return false
end function