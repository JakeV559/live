'******************************************************
'Get device version
'******************************************************
Function GetDeviceVersion()
    if m.softwareVersion = invalid OR m.softwareVersion = "" then
        m.softwareVersion = CreateObject("roDeviceInfo").GetVersion()
    end if
    return m.softwareVersion
End Function


'******************************************************
'Get serial number
'******************************************************
Function GetDeviceESN()
    if m.serialNumber = invalid OR m.serialNumber = "" then
        m.serialNumber = CreateObject("roDeviceInfo").GetDeviceUniqueId()
    end if
    return m.serialNumber
End Function

Function GetModel()
    if m.model = invalid OR m.model = "" then
        m.model = CreateObject("roDeviceInfo").GetModel()
    end if
    return m.model
End Function

Function GetModelDetails()
    if m.modelDetails = invalid then
        m.modelDetails = CreateObject("roDeviceInfo").GetModelDetails()
    end if
    return m.modelDetails
End Function

'******************************************************
'Determine if the UI is displayed in SD or HD mode
'******************************************************
Function IsHD()
    di = CreateObject("roDeviceInfo")
    if di.GetDisplayMode() = "720p" then return true
    return false
End Function

' on Roku3 this method return error value
Function getScreenSize()
    return CreateObject("roDeviceInfo").getDisplaySize()
end Function

'return width_height,such as 1920_1080
Function getResolution()
    return getScreenSize().w.toStr() + "_" + getScreenSize().h.toStr()
end Function

Function getConnectionInfo()
    return CreateObject("roDeviceInfo").getConnectionInfo()
end Function

Function getNetworkType() as String
    if getConnectionInfo().type <> invalid
        if getConnectionInfo().type.len() > 0
            if getConnectionInfo().type = "WiFiConnection" 'wifi
                return "wifi"
            else if getConnectionInfo().type = "WiredConnection" 'wired
                return "wired"
            else 'unknown
                return "none"
            end if
        else 'offline
            return "nont"
        end if
    else 'error
        return "none"
    end if
end Function

Function isWifi() as Boolean
    if getNetworkType() = "wifi" then return true
    return false
end Function

Function isWired() as Boolean
    if getNetworkType() = "wired" then return true
    return false
end Function

Function getMac() as String
    return getConnectionInfo().mac
end Function

Function getRandomUUID()
    return CreateObject("roDeviceInfo").getRandomUUID()
end Function

'*************************************************************
'** getRandom
'** @brief generate a random number
'** @param length as Integer
'** @return random
'*************************************************************
Function getRandom(length as Integer) as String
    random = ""
    for i = 0 to length - 1
        random += cint(rnd(0) * 10).toStr()
    end for
    if random.len() > length
        random = left(random,length)
    end if
    return random
end Function

Function getTimeSinceLastKeypress() as Integer
    return CreateObject("roDeviceInfo").TimeSinceLastKeypress()
end Function

Function getMutiliveHiddenKeypress() as Boolean
    time = getTimeSinceLastKeypress()
    if (time >= 15)
        return true
    else
        return false
    end if
end Function
