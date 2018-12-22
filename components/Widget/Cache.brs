'*************************************************************
'** Roku Live - https://github.com/h4091
'** @Application: Live
'** @File: Cached.brs
'** @Author: h4091
'** @Brief RegistrySection'name is the same with field's id attribute
'** @date 2017-1-11
'** @uses modules
'*************************************************************
sub init()
    initCacheData()
    m.top.functionName = "go"
    m.top.control = "RUN"
end sub

sub initCacheData()
    m.fields = m.top.getFields()

'    Get cache data
    m.registry = CreateObject("roRegistry")
    secList = m.registry.GetSectionList()

'   Delete useless fields in cache
    for each sec in secList
        if m.fields.DoesExist(sec)
        else
            m.registry.delete(sec)
        end if
    end for

'    Init fields
    for i = secList.Count()-1 to 0 step -1
        sec = CreateObject("roRegistrySection",secList[i])
        data = sec.read(secList[i])
        if data <> invalid
            m.top.setField(secList[i], data)
        end if
    end for

'   Save version
    if m.fields["Cached_version"] <> invalid
        roAppInfo = CreateObject("roAppInfo")
        appVersion = roAppInfo.GetVersion()
        if appVersion <> m.fields["Cached_version"]
            m.top.Cached_version = appVersion
        end if
    end if

'   Observe fields
    m.port = createObject("roMessagePort")
    m.CachedFields = []
    prefixLen = "Cached_".len()
    for each key in m.fields
        if key.len() > prefixLen AND key.left(prefixLen) = "Cached_"
            m.CachedFields.push(key)
            m.top.observeField(key,m.port)
        end if
    end for
end sub

sub go()
    while true
        msg = wait(0,m.port)
        if type(msg) = "roSGNodeEvent"
            for each cachedField in m.CachedFields
                if msg.getField() = cachedField
                    if msg.getData() = "" OR msg.getData() = invalid
                        RegDelete(msg.getField())
                    else
                        RegWrite(msg.getField(),msg.getData(),msg.getField())
                    end if
                    exit for
                end if
            end for
        end if
    end while
end sub

'Registry Helper Functions
Function RegRead(key, section=invalid)
    if section = invalid then section = "Default"
    sec = CreateObject("roRegistrySection", section)
    if sec.Exists(key) then return sec.Read(key)
    return invalid
End Function

Function RegWrite(key, val, section=invalid)
    if section = invalid then section = "Default"
    sec = CreateObject("roRegistrySection", section)
    sec.Write(key, val)
    sec.Flush() 'commit it
End Function

Function RegDelete(section)
    m.registry.Delete(section)
End Function

function currentDate() as String
    date = CreateObject("roDateTime")
    second = date.getSeconds()
    milliseconds = date.GetMilliseconds()
    dateString = "second====="+StrI(second)+",milliseconds====="+StrI(milliseconds)
    return dateString
end function

