'*************************************************************
'** Roku Live - https://github.com/h4091
'** @Application: Live
'** @File: SettingScreen.brs
'** @Author: h4091
'** @Brief description
'** @uses modules
'*************************************************************
sub init()
    m.settingLabel = m.top.findNode("settingLabel")
    m.settingRectangle = m.top.findNode("settingRectangle")
    m.top.observeField("settingType", "settingTypeChanged")
    m.top.observeField("visible", "onVisibleChanged")
    m.top.observeField("SettingScreenContentString", "onSettingScreenContentStringChanged")

    m.mfont = CreateObject("roSGNode", "Font")
    m.mfont.size = 36
    m.mfont.uri = "pkg:/fonts/Roboto-Regular.ttf"
end sub

function onSettingScreenContentStringChanged(event as Object)
    m.contentString = event.getData()
    if m.contentString.Len() >0
        m.privacyScrollableText = m.top.createChild("ScrollableText")
        m.privacyScrollableText.id = "settingPrivacyScrollableText"
        m.privacyScrollableText.opacity= "0.4"
        m.privacyScrollableText.translation = "[255,234]"
        m.privacyScrollableText.width = 1383
        m.privacyScrollableText.height = 718
        m.privacyScrollableText.horizAlign = "left"
        m.privacyScrollableText.vertAlign = "top"
        m.privacyScrollableText.lineSpacing = 6
        m.privacyScrollableText.scrollbarThumbBitmapUri="pkg:/images/Setting_scroll_thumb.png"
        m.privacyScrollableText.scrollbarTrackBitmapUri="pkg:/images/Setting_scroll_track.png"
        m.privacyScrollableText.font =  m.mfont

        m.privacyScrollableText.text = m.contentString
        m.privacyScrollableText.setFocus(true)
    end if
end function

function settingTypeChanged(event as Object)
    m.settingType = event.getData()
    if m.settingType = m.global.setting_privacy
        m.settingLabel.text = "Privacy Policy"
    else if m.settingType = m.global.setting_use
        m.settingLabel.text = "Terms of Use"
    else
    end if
end function

function onVisibleChanged(event as Object)
    visible = event.getData()
    if visible = false
        if m.privacyScrollableText <> invalid
            m.top.removeChild(m.privacyScrollableText)
        end if
    end if
end function
