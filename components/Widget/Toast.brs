'*************************************************************
'** Roku Live - https://github.com/h4091
'** @Application: Live
'** @File: Toast.brs
'** @Author: h4091
'** @Brief Toast
'** @uses modules
'*************************************************************
sub init ()
    m.toastLable = m.top.findNode("toastLable")

    m.toastTimer = m.top.findNode("toastTimer")
    m.toastTimer.observeField("fire", "setLabelUnVisibilty")

    m.top.observeField("showTime", "showTimeChanged")
    m.top.observeField("showText", "showTextChanged")
end sub

function showTimeChanged(event as Object)
    m.showTime = event.getData()
    m.toastTimer.duration = m.showTime.ToFloat()
    if m.toastTimer.control <> "start"
        m.toastTimer.control = "start"
    end if
end function

function showTextChanged(event as Object)
    m.showText = event.getData()

    if not m.top.visible
        m.top.visible = true
    end if

    if m.showText <> invalid
        m.toastLable.text = m.showText
    else
        m.toastLable.text = ""
    end if
end function

function setLabelUnVisibilty(event as Object)
    if m.top.visible
        m.top.visible = false
    end if
end function

