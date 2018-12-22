'*************************************************************
'** Roku Live - https://github.com/h4091
'** @Application: Live
'** @File: SetTask.brs
'** @Author: h4091
'** @Brief description
'** @uses modules
'*************************************************************
sub init()
    m.top.functionName = "go"
end sub

function go()
    if m.top.readType = m.global.setting_privacy
        file = "pkg:/doc/PrivacyPolicyUS.txt"
    else if m.top.readType = m.global.setting_use
        file = "pkg:/doc/TermsOfServiceUS.txt"
    end if
    m.readstring = ReadAsciiFile(file)
    m.top.contentString = m.readstring
end function

function hasFile(filePath as Object)
     fileSystem = CreateObject("roFileSystem")
    if fileSystem.Exists(file)
        info("SetTask.brs","- [has file###########]")
    else
        info("SetTask.brs","- [no file -----------]")
    end if
end function