'*************************************************************
'** @Application: Live
'** @File: AppInfo.brs
'** @Author: h4091
'** @Brief description
'** @uses modules
'*************************************************************
'Returns the title value from the manifest
function getTitle() as String
    return CreateObject("roAppInfo").GetTitle()
end function

'Returns the subtitle value from the manifest
function getSubtitle() as String
    return CreateObject("roAppInfo").getSubtitle()
end function

'Returns the app's channel ID
function getID() as String
    return CreateObject("roAppInfo").getID()
end function

'Returns true if the application is side-loaded
function isDev() as Boolean
    return CreateObject("roAppInfo").isDev()
end function

'Returns the conglomerate version number from the manifest
function getAppVersion() As String
    return CreateObject("roAppInfo").getVersion()
end function

function getCustomAppVersion() As String
    return getValue("major_version") + "." + getValue("minor_version") + "." + getValue("build_version") 
end function

'Returns the app's developer ID, or the keyed developer ID, if the application is side-loaded
function getDevID() As String
    return CreateObject("roAppInfo").getDevID()
end function

'Returns the named manifest value, or an empty string if the entry is does not exist
function getValue(key As String) As String
    return CreateObject("roAppInfo").getValue(key)
end function