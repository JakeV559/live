'*************************************************************
'** Roku Live - https://github.com/h4091
'** @Application: Live
'** @File: HomeScreen.brs
'** @Author: h4091
'** @Brief description
'** @uses modules
'*************************************************************
function init()
    info("HomeScreen.brs","- [init]")
    'Initialize the product logo.
    m.productLogo = m.top.findNode("ProductLogo")

    'Initialize the category list and populate the category data.
    m.categoryList = m.top.findNode("CategoryList")

    'Initialize the channel grid and populate the channel data.
    m.channelGrid = m.top.FindNode("ChannelGrid")
    m.channelRecomendWidth = m.channelGrid.getField("itemSize")[0] * 2 + m.channelGrid.getField("itemSpacing")[0]
    m.channelRecomendHeight = m.channelGrid.getField("itemSize")[1] * 2 + m.channelGrid.getField("itemSpacing")[1]
    m.channelCommonWidth = m.channelGrid.getField("itemSize")[0]
    m.channelCommonHeight = m.channelGrid.getField("itemSize")[1]
    m.channelNumColumns = m.channelGrid.getField("numColumns")

    m.setGrid = m.top.FindNode("SetGrid")

    'Add observers to the fileds.
    m.top.observeField("visible", "onVisibleChanged")
    m.top.observeField("content", "onContentChanged")
    m.top.ObserveField("settingShowFlag", "onsettingShowFlagChanged")
    m.categoryList.ObserveField("itemFocused", "onCategoryFocused")
    m.categoryList.ObserveField("itemUnfocused", "onCategoryUnfocused")
    m.channelGrid.ObserveField("itemFocused", "onChannelFocused")
    m.channelGrid.ObserveField("itemUnfocused", "onChannelUnfocused")
    m.channelGrid.ObserveField("itemSelected", "onChannelItemSelected")
    m.setGrid.ObserveField("itemSelected", "onSettingItemSelected")
    m.setGrid.ObserveField("itemFocused", "onSettingItemFocused")
    m.setGrid.ObserveField("itemUnfocused", "onSettingItemUnfocused")
end function

function onsettingShowFlagChanged(event as Object)
    s = event.getData()
    m.settingShowFlag = s
    m.top.settingShowFlag = s
end function

function isSetGridSelected() as Boolean
    if m.categoryList.itemFocused >0
        itemFocused = m.categoryList.content.getChild(m.categoryList.itemFocused)
        if itemFocused.categoryId = m.global.leeco_roku_setting
            return true
        else
            return false
        end if
    end if
end function

function showHomeView()
    m.setGrid.visible = false
    m.channelGrid.visible = true
    m.channelGrid.setFocus(true)
    refreshChannelData()
    setCateLivingStatus()
    setFocusPosition()
end function

'Set the living status of the category item according to whether it contains the playing channel or not.
function setCateLivingStatus() as void
    'Reset the status of the category item that contains the previous playing channel.
    if (m.categoryList.content <> invalid) and (m.top.preChannelPlaying <> invalid) and (m.top.preChannelPlaying.categoryIndex > -1)
        categoryItemPrePlaying = m.categoryList.content.getChild(m.top.preChannelPlaying.categoryIndex)
        if (categoryItemPrePlaying.categoryLiving)
            categoryItemPrePlaying.categoryLiving = false
        end if
    end if

    'Set the status of the category item that contains the playing channel.
    if (m.categoryList.content <> invalid) and (m.top.curChannelPlaying <> invalid) and (m.top.curChannelPlaying.categoryIndex > -1)
        categoryItemPlaying = m.categoryList.content.getChild(m.top.curChannelPlaying.categoryIndex)
        if (not categoryItemPlaying.categoryLiving)
            categoryItemPlaying.categoryLiving = true
            m.top.preChannelPlaying = m.top.curChannelPlaying
        end if
    end if
end function

'Set the category focus and grid focus that contains the playing channel.
function setFocusPosition() as void
    channelPostionArray = getPlayingChannelPosition()
    if (channelPostionArray <> invalid)
        m.categoryList.jumpToItem = channelPostionArray[0] '0 category position
        m.channelGrid.jumpToItem = channelPostionArray[1] '1 channel position
    end if
end function

'Refresh the channel data.
function refreshChannelData() as void
    if (m.top.curChannelPlaying <> invalid)
        categoryIndex = m.top.curChannelPlaying.categoryIndex
    else if (m.channelGrid.content <> invalid)
        categoryIndex = m.channelGrid.content.categoryIndex
    else
        categoryIndex = 0 '0 the first category index.
    end if
    changeChannelContent(categoryIndex)
end function

'Get the channel position that is playing in the player screen.
function getPlayingChannelPosition() as Object
    channelPostionArray = CreateObject("roArray", 2, false)
    cateIndex = 0
    gridIndex = 0

    if (m.top.curChannelPlaying <> invalid)
        if (m.channelGrid.content <> invalid)
            for channelIndex = 0 to m.channelGrid.content.getChildCount()
                channel = m.channelGrid.content.getChild(channelIndex)
                if (channel <> invalid) and (channel.channelId = m.top.curChannelPlaying.channelId)
                    cateIndex = channel.categoryIndex
                    gridIndex = channelIndex
                    exit for
                end if
            end for
        end if
    end if

    channelPostionArray.push(cateIndex)
    channelPostionArray.push(gridIndex)
    return channelPostionArray
end function

function onVisibleChanged(event as Object)
    visible = event.getData()
    if visible
        if m.top.settingShowFlag = "2"  'back from home view
            showHomeView()
        else if isSetGridSelected()
            m.setGrid.setFocus(true)
        else
            showHomeView()
        end if
    end if
end function

function onContentChanged(event as Object)
    contentData = event.getData()
    m.categoryList.content = contentData

    if m.top.visible
        refreshChannelData()
        setCateLivingStatus()
        setFocusPosition()
    end if
end function

'Get the channel grid data.
function getChannelGridData(categoryIndex as Integer, channelList as Object) as object
    channelGridData = CreateObject("roSGNode", "ContentNode")
    channelGridData.addFields({ categoryIndex: categoryIndex })
    if channelList <> invalid and channelList.Count() > 0
        i = 0
        for each channel in channelList
            channelContent = channelGridData.CreateChild("ChannelGridItemData")

            if channelList.Count() = 1 'The item can't show if there is only one item in the grid in fixed layout mode.
                m.channelGrid.fixedLayout = false
                m.channelGrid.itemSize = [m.channelRecomendWidth, m.channelRecomendHeight]
                channelContent.channelRecommend = true
                channelContent.channelPosterWidth = m.channelRecomendWidth
                channelContent.channelPosterHeight = m.channelRecomendHeight
            else
                m.channelGrid.fixedLayout = true
                m.channelGrid.itemSize = [m.channelCommonWidth, m.channelCommonHeight]
                if i = 0 '0 : the recommend channel.
                    channelContent.channelRecommend = true
                    channelContent.X = 0 'X : starting column index.
                    channelContent.Y = 0 'Y : starting row index.
                    channelContent.W = 2 'W : numbers of rows that the item occupies.
                    channelContent.H = 2 'H : number of columns that the item occupies.
                    channelContent.channelPosterWidth = m.channelRecomendWidth
                    channelContent.channelPosterHeight = m.channelRecomendHeight
                else if i = 1 'The position of the second channel move back 1 becauseof first big.
                    channelContent.channelRecommend = false
                    channelContent.X = (i + 1) MOD m.channelNumColumns
                    channelContent.Y = (i + 1) \ m.channelNumColumns
                    channelContent.W = 1
                    channelContent.H = 1
                    channelContent.channelPosterWidth = m.channelCommonWidth
                    channelContent.channelPosterHeight = m.channelCommonHeight
                else 'The position of the third and later channels move back 3 becauseof first big.
                    channelContent.channelRecommend = false
                    channelContent.X = (i + 3) MOD m.channelNumColumns
                    channelContent.Y = (i + 3) \ m.channelNumColumns
                    channelContent.W = 1
                    channelContent.H = 1
                    channelContent.channelPosterWidth = m.channelCommonWidth
                    channelContent.channelPosterHeight = m.channelCommonHeight
                end if
            end if

            channelContent.channelFocused = false
            channelContent.categoryIndex = channel.categoryIndex
            channelContent.categoryId = channel.categoryId
            channelContent.channelId = channel.channelId
            channelContent.channelName = channel.channelName
            channelContent.channelPic = channel.channelPic
            channelContent.isPay = channel.isPay
            channelContent.channelType = channel.channelType
            channelContent.splatId = channel.splatId
            channelContent.curProgram = channel.curProgram
            channelContent.nextProgram = channel.nextProgram
            channelContent.channelStreams = channel.channelStreams
            channelContent.channelEname = channel.channelEname
            channelContent.signal = channel.signal
            channelContent.channelClass = channel.channelClass
            channelContent.numericKeys = channel.numericKeys
            channelContent.selfCopyRight = channel.selfCopyRight
            channelContent.isArtificialRecommend = channel.isArtificialRecommend
            channelContent.orderNo = channel.orderNo
            channelContent.haveProducts = channel.haveProducts
            channelContent.is3D = channel.is3D
            channelContent.is4K = channel.is4K
            channelContent.childLock = channel.childLock
            channelContent.isTimeShiftingDisabled = channel.isTimeShiftingDisabled
            channelContent.isSupportPushVideo = channel.isSupportPushVideo
            channelContent.isAnchor = channel.isAnchor
            i++
        end for
    end if
    return channelGridData
end function

'Show ChannelGrid.
sub showChannelGrid(show as Boolean)
    if show
        m.channelGrid.visible = true
    else
        m.channelGrid.visible = false
    end if
end sub

'Show SetGrid.
sub showSetGrid(show as Boolean)
    if show
         m.setGrid.visible = true
    else
         m.setGrid.visible = false
    end if
end sub

'Switch to SetGrid.
sub switchToSetGrid()
    showChannelGrid(false)
    showSetGrid(true)
    m.setGrid.content = getSettingGridContent()
end sub

'Switch to ChannelGrid.
sub switchToChannelGrid(categoryIndex as Integer)
    showSetGrid(false)
    showChannelGrid(true)
    changeChannelContent(categoryIndex)
end sub

'Corresponding to the focus obtain of the category.
sub onCategoryFocused() as void
    if (m.categoryList.content <> invalid) and (m.categoryList.itemFocused > -1) 'defalut value -1
        itemFocused = m.categoryList.content.getChild(m.categoryList.itemFocused)

        'Switch to SetGrid or ChannelGrid.
        if (itemFocused.categoryId = m.global.leeco_roku_setting)
            switchToSetGrid()
        else
            switchToChannelGrid(m.categoryList.itemFocused)
        end if

        if (m.top.curChannelPlaying <> invalid)
            if (m.categoryList.itemFocused = m.top.curChannelPlaying.categoryIndex)
                itemFocused.categoryLiving = true
            else
                itemFocused.categoryLiving = false
            end if
        end if
    end if
end sub

'Corresponding to the focus lost of the category.
function onCategoryUnfocused() as void
    if (m.categoryList.content <> invalid) and (m.top.curChannelPlaying <> invalid) and (m.categoryList.itemUnfocused > -1)
        itemUnfocused = m.categoryList.content.getChild(m.categoryList.itemUnfocused)
        if (m.categoryList.itemUnfocused = m.top.curChannelPlaying.categoryIndex)
            itemUnfocused.categoryLiving = true
        else
            itemUnfocused.categoryLiving = false
        end if
    end if
end function

'Corresponding to the focus obtain of the channel.
function onChannelFocused() as void
    if (m.channelGrid.content <> invalid) and (m.channelGrid.itemFocused > -1)
        itemFocused = m.channelGrid.content.getChild(m.channelGrid.itemFocused)
        itemFocused.channelFocused = true
    end if
end function

'Corresponding to the focus lost of the channel.
function onChannelUnfocused() as void
    if (m.channelGrid.content <> invalid) and (m.channelGrid.itemUnfocused > -1)
        itemUnfocused = m.channelGrid.content.getChild(m.channelGrid.itemUnfocused)
        itemUnfocused.channelFocused = false
    end if
end function

function onChannelItemSelected() as void
    itemSelected = m.channelGrid.itemSelected
    cateIndex = m.channelGrid.content.categoryIndex
    channel = m.top.content.getChild(cateIndex).channelList[itemSelected]
    'Create a new object insteadof using the channel content existed which may be changed.
    m.top.channelSelected = getChannelData(channel)
    m.handleOK = true 'handle OK to prevent PlayerScreen handling it and show HomeScreen again.
end function

'Corresponding to the switch of channel.
function changeChannelContent(categoryIndex as Integer) as void
    if categoryIndex < 0 or m.categoryList.content = invalid
        err("HomeScreen.brs","- [changeChannelContent: error]")
        return
    end if

    curCateContent = m.categoryList.content.getChild(categoryIndex)
    channelList = curCateContent.channelList
    m.channelGrid.content = getChannelGridData(categoryIndex, channelList)
end function

'Return System Time. eg 09:09
function getSystemTime() as String
    currentDate = CreateObject("roDateTime")
    currentDate.toLocalTime()

    currentHour = (stri(currentDate.getHours())).trim()
    if (len(currentHour) = 1)
        currentHour = "0" + currentHour
    end if

    currentMinute = (stri(currentDate.getMinutes())).trim()
    if (len(currentMinute) = 1)
        currentMinute = "0" + currentMinute
    end if

    return currentHour + ":" + currentMinute
end function

'Corresponding to the remote control.
function onKeyEvent(key as String, press as Boolean) as Boolean
    if (key = "OK") and (m.handleOK = true)
        m.handleOK = false
        return true
    end if

    if m.top.visible = false or m.top.content = invalid
        return false
    end if

    handled = false
    if (press)
        if (key = m.global.REMOTE_KEY_UP)
            if (m.channelGrid.hasFocus())
                chanRowFocus = m.channelGrid.content.getChild(m.channelGrid.itemFocused).Y 'row number of the focused channel item
                if (chanRowFocus = 0) and (m.channelGrid.content.categoryIndex > 0)
                    m.categoryList.jumpToItem = m.channelGrid.content.categoryIndex - 1
                    changeChannelContent(m.channelGrid.content.categoryIndex - 1)
                    handled = true
                else if  (chanRowFocus = 0) and (m.channelGrid.content.categoryIndex = 0) 'scroll to the first row of the first category
                    m.categoryList.jumpToItem = m.categoryList.content.getChildCount() - 1
                    switchToSetGrid()
                    m.channelGrid.setFocus(false)
                    m.setGrid.setFocus(true)
                end if
            else if (m.setGrid.hasFocus())
                'switch to ChannelGrid.
                lastCateIndex = m.categoryList.content.getChildCount() - 2 'm.categoryList.content.getChildCount() - 2 : last category index contains channels.
                if (lastCateIndex > -1) '-1 : default value
                    m.categoryList.jumpToItem = lastCateIndex
                    switchToChannelGrid(lastCateIndex)
                    m.setGrid.setFocus(false)
                    m.channelGrid.setFocus(true)
                end if
                handled = true
            end if
        else if (key = m.global.REMOTE_KEY_DOWN)
            if (m.channelGrid.hasFocus())
                cateCount = m.categoryList.content.getChildCount() 'category count
                chanCount = m.channelGrid.content.getChildCount() 'channel count of the category
                chanRowLast = m.channelGrid.content.getChild(chanCount - 1).Y 'row number of the last channel item
                chanRowFocus = m.channelGrid.content.getChild(m.channelGrid.itemFocused).Y 'row number of the focused channel item

                ' switch to the last channel in the grid
                if (chanRowFocus > 0) and (chanRowFocus = chanRowLast - 1)
                    m.channelGrid.jumpToItem = chanCount - 1
                    handled = true
                ' switch to the next category
                else if (chanRowFocus = chanRowLast) or (chanRowFocus = 0 and chanRowLast = 1) '1 all the channels occupy one row
                    if m.channelGrid.content.categoryIndex < cateCount - 1
                        animatedCategoryIndex = m.channelGrid.content.categoryIndex + 1
                        m.categoryList.jumpToItem = animatedCategoryIndex

                        'switch to SetGrid or ChannelGrid.
                        if (animatedCategoryIndex = cateCount - 1)
                            switchToSetGrid()
                            m.channelGrid.setFocus(false)
                            m.setGrid.setFocus(true)
                        else
                            switchToChannelGrid(animatedCategoryIndex)
                            m.setGrid.setFocus(false)
                            m.channelGrid.setFocus(true)
                        end if

                        handled = true
                    end if
                end if
            else if (m.setGrid.hasFocus())
                m.categoryList.jumpToItem = 0 '0 : the first category index.
                switchToChannelGrid(0) '0 : the first category index.
                m.setGrid.setFocus(false)
                m.channelGrid.setFocus(true)
            end if
        else if (key = m.global.REMOTE_KEY_LEFT)
            if (m.channelGrid.hasFocus())
                m.channelGrid.setFocus(false)
                m.categoryList.setFocus(true)
                handled = true
            else if (m.setGrid.hasFocus())
                if m.categoryList.itemFocused = m.categoryList.content.getChildCount() - 1
                    m.setGrid.setFocus(false)
                else
                    m.channelGrid.setFocus(false)
                end if
                m.categoryList.setFocus(true)
                handled = true
            end if
        else if (key = m.global.REMOTE_KEY_RIGHT)
            if (m.categoryList.hasFocus())
                if m.categoryList.itemFocused = m.categoryList.content.getChildCount() - 1
                    m.categoryList.setFocus(false)
                    m.channelGrid.visible = false
                    m.setGrid.setFocus(true)
                else
                    m.channelGrid.visible = true
                    m.channelGrid.setFocus(true)
                    m.categoryList.setFocus(false)
                end if
                handled = true
            end if
        else if (key = m.global.REMOTE_KEY_OK)
        else if (key = m.global.REMOTE_KEY_BACK)
        end if
    end if

    return handled
end function

function onSettingItemSelected(event as Object)
    s = event.getData()
    m.top.settingItemSelected = s.toStr()
    m.top.settingItemSelected = "-1"  'ready for next change
end function

function onSettingItemFocused()
    if (m.setGrid.content <> invalid) and (m.setGrid.itemFocused > -1)
        itemFocused = m.setGrid.content.getChild(m.setGrid.itemFocused)
        itemFocused.focusFlag = true
    end if
end function

function onSettingItemUnfocused()
    if (m.setGrid.content <> invalid) and (m.setGrid.itemFocused > -1)
        itemUnFocused = m.setGrid.content.getChild(m.setGrid.itemFocused)
        itemUnFocused.focusFlag = false
    end if
end function