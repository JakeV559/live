'*************************************************************
'** Roku Live - https://github.com/h4091
'** @Application: Live
'** @File: ErrorTips.brs
'** @Author: h4091
'** @Brief description
'** @date 2016-12-14
'** @uses modules
'*************************************************************
sub init()
    initNodes()
    initFields()
    initObserveField()
end sub

function buttonSelected()

end function

function buttonGroup()
    'Change the buttons
end function

function initFields()
    m.btnSelectImage = "pkg:/images/Error_Button_Select.png"
    m.btnUnSelectImage = "pkg:/images/Error_Button_UnSelect.png"

    m.errorContent = {
                   retryAndNextChannel:"The channel is unavailable now, please refresh or go to next channel.",
                   netError:"Network not connected, please check your network settings and try again.",
                   }
    m.labelWidth = (m.global.ui_resolution_fhd_x - m.errorLabel.width)*0.5
end function

function initNodes()
    m.errorLabel = m.top.findNode("errorLabel")
    m.errorButtonGroup = m.top.findNode("errorButtonGroup")
    m.errorRetryPoster = m.top.findNode("errorRetryPoster")
    m.nextChannelPoster = m.top.findNode("nextChannelPoster")
end function

function initObserveField()
    m.top.observeField("errorType", "errorTypeChanged")
    m.top.observeField("errorContent", "errorContentChanged")
    m.top.observeField("visible", "visibleContentChanged")
end function

function errorTypeChanged(event as Object)
    m.errorType = event.getData()
    showWithType()
end function

function errorContentChanged()
    info("ErrorTips.brs","- [errorContentChanged]")
end function

function visibleContentChanged(event as Object)
    if m.top.visible = true
        showWithType()
    end if
end function

function showWithType()
    if m.errorType <>invalid
        if m.errorType = m.global.error.playerror_retry_nextchannel
            retryTranslationAndNextchannel()
        else if m.errorType = m.global.error.neterror_retry
            netTranslationAndContent()
        else

        end if
    end if
end function

function retryTranslationAndNextchannel()
    if m.errorLabel.visible = false
        m.errorLabel.visible = true
    end if

    if m.nextChannelPoster.visible = true
        m.nextChannelPoster.visible = false
    end if

    m.errorLabel.text = m.errorContent.retryAndNextChannel
    m.errorLabel.translation = [m.labelWidth,363]
    m.errorRetryPoster.visible = true
    m.nextChannelPoster.visible = true

    m.errorRetryPoster.translation = [608,521]
    m.errorRetryPoster.uri = m.btnSelectImage
    m.nextChannelPoster.translation = [1014,521]
    m.nextChannelPoster.uri = m.btnUnSelectImage

    m.errorRetryPoster.setFocus(true)
end function

function netTranslationAndContent()
    if m.errorLabel.visible = false
        m.errorLabel.visible = true
    end if

    if m.nextChannelPoster.visible = true
        m.nextChannelPoster.visible = false
    end if

    m.errorLabel.text = m.errorContent.netError
    m.errorLabel.translation = [m.labelWidth,m.global.ui_resolution_fhd_y/3]

    m.errorRetryPoster.uri = m.btnSelectImage
    m.errorRetryPoster.setFocus(true)
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
'    print "in ErrorTips.xml onKeyEvent ";key;" "; press;" m.errorType ==";m.errorType
    result = false
    if m.top.visible and press
        if key = "OK"
            if m.errorType = m.global.error.playerror_retry_nextchannel
                if m.errorRetryPoster.hasFocus()
                    m.top.retryPlayRequestType = true
                else
                    m.top.nextChannelRequestType = true
                end if
                result = true
            else if m.errorType = m.global.error.neterror_retry
                m.top.retryHomeRequestType = true
                result = true
            end if
            resetRequestType()
        else if key = "right" OR key = "left"
            if m.errorType = m.global.error.playerror_retry_nextchannel
                buttonSeletedChanged()
                result = true
            else if m.errorType = m.global.error.neterror_retry
                result = true
            end if
        else if key = "back"
            if m.errorType = m.global.error.playerror_retry_nextchannel
                m.top.retryPlayRequestType = true
                result = true
            else if m.errorType = m.global.error.neterror_retry
                m.top.retryHomeRequestType = true
                result = true
            end if
            resetRequestType()
        end if
    end if
    return result
end function

'buttonSeleted type Changed
function buttonSeletedChanged()
    if m.errorRetryPoster.hasFocus()
        m.nextChannelPoster.setFocus(true)
        m.nextChannelPoster.uri = m.btnSelectImage
        m.errorRetryPoster.uri = m.btnUnSelectImage
    else
        m.errorRetryPoster.setFocus(true)
        m.nextChannelPoster.uri = m.btnUnSelectImage
        m.errorRetryPoster.uri = m.btnSelectImage
    end if
end function

'reset RequestType
function resetRequestType()
    if m.errorType = m.global.error.playerror_retry_nextchannel
        m.top.retryPlayRequestType = false
        m.top.nextChannelRequestType=false
    else if m.errorType = m.global.error.neterror_retry
        m.top.retryHomeRequestType = false
    end if
end function
