'*************************************************************
'** Roku Live - https://github.com/h4091
'** @Application: Live
'** @File: LogoutScreen.brs
'** @Author: h4091
'** @Brief description
'** @uses modules
'*************************************************************

sub init()
    info("Logout.brs","- [init]")
    initConstans()
    initComponents()
    initObservers()
end sub

sub initConstans()
    m.shownLikeChannelNum = 3
    m.exitBtnFocusedBg = "pkg:/images/exit_bg_focused.png" 'The backgroud image when the exit button gains the focus.
    m.exitBtnUnFocusedBg = "pkg:/images/exit_bg_unfocused.png" 'The backgroud image when the exit button loses the focus.
end sub

sub initComponents()
    m.likeCont = m.top.findNode("likeCont")
    m.likeList = m.top.findNode("likeList")
    m.exitBtn = m.top.findNode("exitBtn")
end sub

sub centerLogoutScreen()
    centerx = (m.global.ui_resolution_fhd_x - m.likeCont.width) / 2
    centery = (m.global.ui_resolution_fhd_y - m.likeCont.height) / 2
    m.likeCont.translation = [centerx, centery]
end sub

sub initObservers()
    m.top.observeField("visible", "onVisibleChanged")
    m.likeList.observeField("itemFocused", "onChannelFocused")
    m.likeList.observeField("itemUnfocused", "onChannelUnfocused")
end sub

function onVisibleChanged(event as Object)
    visible = event.getData()
    if visible
        m.exitBtn.setFocus(true)
        m.exitBtn.uri = m.exitBtnFocusedBg
        if (m.top.likeChannelContent <> invalid)
            likeListContent = getLikeListContent(m.top.likeChannelContent.channelList)
            if (likeListContent <> invalid)
                m.likeList.content = likeListContent
            end if
        end if
    end if
end function

function onChannelItemSelected() as void
    itemSelected = m.likeList.itemSelected
    if (m.top.likeChannelContent <> invalid) and (m.top.likeChannelContent.channelList <> invalid) and (itemSelected > -1)
        channelSelected = m.top.likeChannelContent.channelList[itemSelected]
        m.top.channelSelected = getChannelContent(channelSelected, CreateObject("roSGNode", "LikeListItemData"))
    end if
end function

sub onChannelFocused()
    if (m.likeList.content <> invalid) and (m.likeList.itemFocused > -1)
        itemFocused = m.likeList.content.getChild(m.likeList.itemFocused)
        itemFocused.channelFocused = true
        m.top.preChannelFocused = itemFocused
    end if
end sub

sub onChannelUnfocused()
    if (m.likeList.content <> invalid) and (m.likeList.itemUnfocused > -1)
        itemUnfocused = m.likeList.content.getChild(m.likeList.itemUnfocused)
        itemUnfocused.channelFocused = false
    end if
end sub

sub resetPreFocusedChannel()
    if (m.top.preChannelFocused <> invalid)
            m.top.preChannelFocused.channelFocused = false
    end if
end sub

function getLikeListContent(channelList as Object) as object
    if (channelList = invalid) or (channelList.count() <= 0)
        return invalid
    end if

    likeListData = CreateObject("roSGNode", "ContentNode")

    index = 0
    for each channel in channelList
        getChannelContent(channel, likeListData.CreateChild("LikeListItemData"))
        index++
        if (index = m.shownLikeChannelNum)
            return likeListData
        end if
    end for

    return likeListData
end function

function getChannelContent(channelOrigin as Object, channelTarget as Object) as Object
    if (channelOrigin = invalid) or (channelTarget = invalid)
        return invalid
    end if

    channelTarget.channelFocused = false
    channelTarget.categoryIndex = channelOrigin.categoryIndex
    channelTarget.categoryId = channelOrigin.categoryId
    channelTarget.channelId = channelOrigin.channelId
    channelTarget.channelName = channelOrigin.channelName
    channelTarget.channelPic = channelOrigin.channelPic
    channelTarget.isPay = channelOrigin.isPay
    channelTarget.channelType = channelOrigin.channelType
    channelTarget.splatId = channelOrigin.splatId
    channelTarget.curProgram = channelOrigin.curProgram
    channelTarget.nextProgram = channelOrigin.nextProgram
    channelTarget.channelStreams = channelOrigin.channelStreams
    channelTarget.channelEname = channelOrigin.channelEname
    channelTarget.signal = channelOrigin.signal
    channelTarget.channelClass = channelOrigin.channelClass
    channelTarget.numericKeys = channelOrigin.numericKeys
    channelTarget.selfCopyRight = channelOrigin.selfCopyRight
    channelTarget.isArtificialRecommend = channelOrigin.isArtificialRecommend
    channelTarget.orderNo = channelOrigin.orderNo
    channelTarget.haveProducts = channelOrigin.haveProducts
    channelTarget.is3D = channelOrigin.is3D
    channelTarget.is4K = channelOrigin.is4K
    channelTarget.childLock = channelOrigin.childLock
    channelTarget.isTimeShiftingDisabled = channelOrigin.isTimeShiftingDisabled
    channelTarget.isSupportPushVideo = channelOrigin.isSupportPushVideo
    channelTarget.isAnchor = channelOrigin.isAnchor

    return channelTarget
end function

function onKeyEvent(key as string,  press as boolean) as Boolean
    if (m.top.visible = false)
        return false
    end if

    handled = false
    if (press)
        if (key = m.global.REMOTE_KEY_UP)
            if (m.exitBtn.hasFocus())
                m.exitBtn.setFocus(false)
                m.exitBtn.uri = m.exitBtnUnFocusedBg
                m.likeList.setFocus(true)
            end if
            handled = true
        else if(key = m.global.REMOTE_KEY_DOWN)
            if (m.likeList.hasFocus())
                m.likeList.setFocus(false)
                m.exitBtn.setFocus(true)
                m.exitBtn.uri = m.exitBtnFocusedBg
                resetPreFocusedChannel()
            end if
            handled = true
        else if(key = m.global.REMOTE_KEY_LEFT)
            handled = true
        else if(key = m.global.REMOTE_KEY_RIGHT)
            handled = true
        else if(key = m.global.REMOTE_KEY_OK)
            if (m.exitBtn.hasFocus())
                handled = false
            else if (m.likeList.hasFocus())
                onChannelItemSelected()
                handled = true
            end if
        else if(key = m.global.REMOTE_KEY_BACK)
            handled = false
        else
            handled = true
        end if
    end if

    return handled
end function