'*************************************************************
'** Roku Live - https://github.com/h4091
'** @Application: Live
'** @File: PlayerScreen.brs
'** @Author: h4091
'** @Brief Player screen
'** @date 2016-12-19
'** @uses modules
'*************************************************************
sub init()
    info("PlayerScreen.brs","- [init]")
    initFields()
    initUriHandler()
    initViews()
    showRetrievingBar()
    showController()
    requestHomePage()
end sub

function requestMutiLiveData() as Void
    handle = false
    if m.mutiLiveMainView.curProgram <> invalid
        if m.mutiLiveMainView.channelID = m.channelSelected.channelId
            if m.mutiliveContentNode <> invalid
                flag =  isNeedRequestMutiliveAtOnce(getLastMutiliveProgramItemPlayTimeMili(m.mutiliveContentNode))
                if flag = false
                    if m.mutiLiveMainView.inTenMinsFlag
                        m.mutiLiveMainView.mutiliveContentNode = m.mutiliveContentNode
                        handle = true
                    end if
                end if
            end if
        end if
    end if

    if handle = false
        requestMutiLiveDataAndSetParam()
    end if
end function

function requestMutiLiveDataAndSetParam()
    if m.channelSelected <>invalid and m.channelSelected.curProgram <>invalid and m.channelSelected.channelId <>invalid
        m.mutiLiveMainView.curProgram = m.channelSelected.curProgram
        m.mutiLiveMainView.channelID = m.channelSelected.channelId
        if m.channelSelected.channelId <> invalid
            channelIds = m.channelSelected.channelId
            makeRequest(m.uriHandler, {}, m.mutiListURL + channelIds, m.global.get, m.global.muti_list_num)
        end if
    end if
end function

sub requestVideoScheduleURL(streamId as String)
    makeRequest(m.uriHandler,{}, prepareScheduleUrl(streamId), m.global.get, m.global.video_schedule_job_num)
end sub

Function prepareScheduleUrl(streamId as String) as String
    dateT = CreateObject("roDateTime")
    dateT.mark()
    tm = dateT.asSeconds().toStr()
    result = m.videoURL + "&stream_id=" + streamId + "&tm=" + tm + "&key=" + getKeyDigest(streamId, tm, m.global.gls_key)
    return result
End Function

function getKeyDigest(streamId as String, tm as String, key as String) as String
    ba1 = CreateObject("roByteArray")
    ba1.FromAsciiString(streamId + "," + tm +"," + key )
    digest = CreateObject("roEVPDigest")
    digest.Setup("md5")
    digest.Update(ba1)
    result = digest.Final()
    return result
end function

sub requestHomePage()
    makeRequest(m.uriHandler, {}, m.global.home_page_url, m.global.get, m.global.home_job_num)
end sub

function onChannelSelected(event as Object)
    if (event <> invalid) and (event.getData() <> invalid) and (m.channelSelected <> invalid)
        if (event.getData().channelId <> m.channelSelected.channelId)
            changeChannel(event.getData())
        end if
    end if

    if (m.homeScreen.visible)
        showHomeScreen(false)
    else if (m.logoutScreen.visible)
        showLogoutScreen(false)
    end if

    if (m.channelSelected <> invalid)
        m.channelIndex = getChannelIndex(m.channelSelected.channelId)
    end if
end function

function onSettingItemSelected(event as Object)
    m.settingItemSelectedIndex = event.getData().ToInt()
    if m.settingItemSelectedIndex >=0
        m.top.settingFlag = true
        if m.settingNode.visible = false
            m.settingNode.visible = true
            readFileAndsetText()
        end if
    end if
end function

' Todo:delete
function readFileAndsetText()
    readfile(m.settingItemSelectedIndex)
end function

function readfile(index as Integer)
    if index = 0
        m.setTask.readType = m.global.setting_privacy
        m.settingNode.settingType = m.global.setting_privacy
    else if index = 1
        m.setTask.readType = m.global.setting_use
        m.settingNode.settingType = m.global.setting_use
    end if

    m.setTask.control = "RUN"
end function

function onMutiLiveSelected(event as Object)
    mutiLiveSelectedData = event.getData()
    changeChannel(m.channelSelected)
end function

' media player state change callback
sub onPlayerStateChange()
    if m.player.state = "none"              ' No current play state
        info("PlayerScreen.brs","- [none]")
    else if m.player.state = "buffering"    ' Video stream is currently buffering
        onMediaBuffering()
    else if m.player.state = "playing"      ' Video is currently playing
        onMediaPlaying()
    else if m.player.state = "paused"       ' Video is currently paused
    else if m.player.state = "stopped"      ' Video is currently stopped
    else if m.player.state = "finished"     ' Video has completed play
        onMediaFinish()
    else if m.player.state = "error"        ' An error has occurred in the video play
        onMediaError(m.player.errorCode, m.player.errorMsg)
    end if
end sub

sub onMediaBuffering()
    info("PlayerScreen.brs","- [buffering]")
    if m.currentState = m.STATE_PLAY
        m.currentState = m.STATE_BLOCK
        reportBlock()
    end if
    stopHideTimer()
    if isDelayShowLoading() = false
        showRetrievingBar()
    end if
    showController()
end sub

sub reportEnd()
    stopHeartTimer()
    if m.currentState = m.STATE_PLAY
        reportHeart()
    end if
    setHeartTimes(true)
        makePlayReport(getPlayReportParams(m.global.action.end))
end sub

sub reportBlock()
    stopHeartTimer()
    reportHeart()
    setHeartTimes(false)
    makePlayReport(getPlayReportParams(m.global.action.block))
end sub

sub reportError(errorCode as String)
    if errorCode = m.global.NETWORK_ERROR   'Network error : server down or unresponsive, server is unreachable, network setup problem on the client
        makeErrorReport(getErrorParams(true, m.global.PLAYER_ERROR.CANNOT_CONNECT_SERVER, m.global.uuid))
    else if errorCode = m.global.HTTP_ERROR 'HTTP error: malformed headers or HTTP error result
        makeErrorReport(getErrorParams(true, m.global.PLAYER_ERROR.DATA_CANNOT_PARSED, m.global.uuid))
    else if errorCode = m.global.TIME_OUT 'Connection timed out
        makeErrorReport(getErrorParams(true, m.global.PLAYER_ERROR.MEDIA_PLAY_TIMEOUT, m.global.uuid))
    else if errorCode = m.global.UNKNOWN_ERROR  'Unknown error
        makeErrorReport(getErrorParams(true, m.global.PLAYER_ERROR.UNKNOWN_ERROR, m.global.uuid))
    else if errorCode = m.global.NO_STREAMS  'Empty list; no streams were specified to play
        makeErrorReport(getErrorParams(true, m.global.PLAYER_ERROR.CANNOT_GET_MEDIA, m.global.uuid))
    else if errorCode = m.global.UNSUPPORTED_FORMAT    'Media error; the media format is unknown or unsupported
        makeErrorReport(getErrorParams(true, m.global.PLAYER_ERROR.UNSUPPORTED_MEDIA_FORMAT, m.global.uuid))
    else
        makeErrorReport(getErrorParams(true, m.global.PLAYER_ERROR.UNKNOWN_ERROR, m.global.uuid))
    end if
end sub

sub reportHeart()
    m.playStopTime = now().asSeconds()
    m.playTime = m.playStopTime - m.playStartTime
'    if m.playTime > 1
        makePlayReport(getPlayReportParams(m.global.action.time))
'    end if
    m.playStartTime = now().asSeconds()
end sub

sub setHeartTimes(isReset as Boolean)
    if isReset
        m.reportHeartTimes = 1
    else
        if m.reportHeartTimes < 3
            m.reportHeartTimes += 1
        end if
    end if
    if m.reportHeartTimes = 1
        m.heartTimer.duration = 15
    else if m.reportHeartTimes = 2
        m.heartTimer.duration = 60
    else if m.reportHeartTimes > 2
        m.heartTimer.duration = 180
    end if
end sub

sub onMediaPlaying()
    info("PlayerScreen.brs","- [playing]")
    m.playStartTime = now().asSeconds()
    stopLoadingDelayTimer()
    if m.currentState = m.STATE_INIT
        changeState(m.STATE_PLAY)
    else if m.currentState = m.STATE_BLOCK
        changeState(m.STATE_EBLOCK)
    end if
    'TODO feature
'    if m.currentChannelType <> m.global.TYPE_LIVE AND m.isUpdateSeekBar <> true
'        m.controller.duration = m.player.duration ' Becomes valid when playback begins and may change if the video is dynamic content, such as a live event
'        m.seekBarUpdateTimer.duration = getRemaining(m.player.position * 1000)
'        m.seekBarUpdateTimer.control = "start"
'        m.isUpdateSeekBar = true
'    end if
    hideRetrievingBar()
    startHideTimer()
    m.hadPlayed = true
    showUserGuidelines()
    hideErrorTips()
end sub

sub onMediaFinish()
    info("PlayerScreen.brs","- [finished]")
    if m.initPlay <> true
        m.currentState = m.STATE_END
        reportEnd()
    end if
end sub

sub onMediaError(errorCode as Integer, errorMsg as String)
    err("PlayerScreen.brs","- [Media play error (error code: " + errorCode.toStr() + ", error msg:" + errorMsg +")]")
    if m.initPlay <> true
        changeState(m.STATE_ERROR)
        reportError(errorCode.toStr())
        stopHideTimer()
        showRetrievingBar()
        showController()
        if screenHasNoMainViews()
            showErrorTips(m.global.error.playerror_retry_nextchannel)
        end if
    end if
end sub

sub startUpdateSeekBar()
    position = m.player.position
    m.seekBarUpdateTimer.duration = getRemaining(position * 1000)
    m.controller.position = position
    m.seekBarUpdateTimer.control = "start"
end sub

function getRemaining(p as Integer) as Float
    remaining = csng(1000 - (p MOD 1000)) / 1000
    return remaining
end function

sub startHideTimer()
    if m.controller.visible
        if m.controllerTimer.control <> "start"
            m.controllerTimer.control = "start"
        end if
    end if
end sub

sub stopHideTimer()
    if m.controller.visible
        if m.controllerTimer.control = "start"
            m.controllerTimer.control = "stop"
        end if
    end if
end sub

sub startLoadingDelayTimer()
    if m.retrievingBar.visible = false
        if m.loadingDelayTimer.control <> "start"
            m.loadingDelayTimer.control = "start"
        end if
    end if
end sub

sub stopLoadingDelayTimer()
    if m.retrievingBar.visible = false
        if m.loadingDelayTimer.control = "start"
            m.loadingDelayTimer.control = "stop"
        end if
    end if
end sub

'Make sure if need to delay the display of loading indicator.
'It is true when user changes the channel by press left or right remote key.
function isDelayShowLoading() as Boolean
    return m.loadingDelayTimer.control = "start"
end function

sub onContentChanged(event as Object)
    m.homeContent = event.getData()
    setChannelList(m.homeContent)
    if m.channels.isEmpty() <> true
        if m.global.ECPContentId <> invalid 'Launched from deep linking.
            channelId = m.global.ECPContentId
        else
            channelId = getLastWatchedChannelId()
        end if
        m.channelIndex = getChannelIndex(channelId)
        m.homeScreen.curChannelPlaying = getChannelData(m.channels[m.channelIndex])
        changeChannel(getChannelData(m.channels[m.channelIndex]))
    end if
    m.homeScreen.content = m.homeContent
    m.categoryContent = m.homeContent.getChild(m.defaultCategoryIndex)
end sub

'*************************************************************
'** setChannelList
'** Clear old channel cache, add new channels and sort
'** @param homeContent as Dynamic
'*************************************************************
sub setChannelList(homeContent as Dynamic)
    if homeContent <> invalid
        'clear cache data
        m.channels.clear()
        for index = 0 to homeContent.getChildCount()
            category = homeContent.getChild(index)
            if category <> invalid
                if category.categoryName <> "Featured"
                    channelList = category.channelList
                    if channelList <> invalid
                        m.channels.append(channelList)
                    end if
                end if
            end if
        end for
        QuickSort(m.channels,sortByNumericKeys)
    end if
end sub

'**************************************************************************
'** getChannelIndex
'** Get channel index according to the specified channel id.
'** @param channelId as String
'**************************************************************************
function getChannelIndex(channelId as String) as Integer
    channelIndex = m.channelIndex

    if (channelId = invalid) or (channelId = "")
        return channelIndex
    end if

    if (m.channels <> invalid)
        for index = 0 to m.channels.count()
            channel = m.channels[index]
            if (channel <> invalid) and (channel.channelId <> invalid) and (channel.channelId = channelId)
                channelIndex = index
                exit for
             end if
        end for
    end if

    return channelIndex
end function

'*************************************************************
'** sortByNumericKeys
'** sort by "numericKeys"
'** @param channel as Dynamic
'** @return numericKeys as Integer
'*************************************************************
function sortByNumericKeys(channel as Dynamic) as Integer
    return channel["numericKeys"].toInt()
end function

sub homeScreenVisibleChange()
    if m.homeScreen.visible = true
        m.changeChannelTipPoster.visible = false
        m.downKeyTipPoster.visible = false
    else
        showUserGuidelines()
    end if
end sub

sub logoutScreenVisibleChange()
    if m.logoutScreen.visible = true
        m.changeChannelTipPoster.visible = false
        m.downKeyTipPoster.visible = false
    else
        showUserGuidelines()
    end if
end sub

sub onErrorTipsVisibleChanged()
    if m.errorTips.visible = true
        m.changeChannelTipPoster.visible = false
        m.downKeyTipPoster.visible = false
    else
        showUserGuidelines()
    end if
end sub

sub mutiLiveMainViewTranslationChange(event as object)
    if m.mutiLiveViewShowState = true 'show mutiLiveMainView
        m.changeChannelTipPoster.visible = false
        m.downKeyTipPoster.visible = false
    else if m.mutiLiveViewShowState = false 'hide mutiLiveMainView
        showUserGuidelines()
    end if
end sub

sub showUserGuidelines()
    if m.hadPlayed = true
        if m.cache.Cached_userNeedChangeChannelGuidelines <> m.CacheFalse
            setUserChangeChannelGuidelinesTimer()
        else if m.cache.Cached_userNeedDownKeyGuidelines <> m.CacheFalse
            userNeedDownKeyGuidelinesTimerStart()
        end if
    end if
end sub

sub setUserChangeChannelGuidelinesTimer()
    if m.hadShowedChannelTipPosterFirst <> true
        userChangeChannelGuidelinesTimerStart()
    else
        if m.cache.Cached_userNeedDownKeyGuidelines <> m.CacheFalse
            userNeedDownKeyGuidelinesTimerStart()
        end if
        if m.hadShowedChannelTipPosterSecond <> true
            userChangeChannelGuidelinesSecondTimerStart()
        end if
    end if
end sub

sub userChangeChannelGuidelinesTimerStart()
    if m.userChangeChannelGuidelinesTimer.control <> m.TimerControlStart
        m.userChangeChannelGuidelinesTimer.control = m.TimerControlStart
    end if
end sub

sub userChangeChannelGuidelinesSecondTimerStart()
    if m.userChangeChannelGuidelinesSecondTimer.control <> m.TimerControlStart
        m.userChangeChannelGuidelinesSecondTimer.control = m.TimerControlStart
    end if
end sub

sub userNeedDownKeyGuidelinesTimerStart()
    if m.userNeedDownKeyGuidelinesTimer.control <> m.TimerControlStart
        m.userNeedDownKeyGuidelinesTimer.control = m.TimerControlStart
    end if
end sub

sub fireUserChangeChannelGuidelinesTimer()
    if screenIsClean() = true AND m.cache.Cached_userNeedChangeChannelGuidelines <> m.CacheFalse
        m.changeChannelTipPoster.visible = true
        m.hadShowedChannelTipPosterFirst = true
        m.userChangeChannelGuidelinesDisappearTimer.control = m.TimerControlStart
        userNeedDownKeyGuidelinesTimerStart()
        userChangeChannelGuidelinesSecondTimerStart()
    end if
end sub

sub fireUserChangeChannelGuidelinesSecondTimer()
    if screenIsClean() = true AND m.cache.Cached_userNeedChangeChannelGuidelines <> m.CacheFalse
        m.changeChannelTipPoster.visible = true
        m.hadShowedChannelTipPosterSecond = true
        m.userChangeChannelGuidelinesDisappearTimer.control = m.TimerControlStart
    end if
end sub

sub fireUserUseDownKeyGuidelinesTimer()
    if screenIsClean() = true AND m.cache.Cached_userNeedDownKeyGuidelines <> m.CacheFalse
        m.downKeyTipPoster.visible = true
        m.cache.Cached_userNeedDownKeyGuidelines = m.CacheFalse
        m.userNeedDownKeyGuidelinesDisappearTimer.control = m.TimerControlStart
    end if
end sub

sub fireUserChangeChannelGuidelinesDisappearTimer()
    m.changeChannelTipPoster.visible = false
end sub

sub fireUserNeedDownKeyGuidelinesDisappearTimer()
    m.downKeyTipPoster.visible = false
end sub

function screenIsClean() as Boolean
    return m.homeScreen.visible = false AND m.mutiLiveMainView.translation[1] > m.mutiTranslation["midY"] AND m.logoutScreen.visible = false AND m.controller.visible = false AND m.errorTips.visible = false
end function

function screenHasNoMainViews() as Boolean
    return m.homeScreen.visible = false AND m.mutiLiveViewShowState = false AND m.logoutScreen.visible = false
end function

sub updateOKTip()
    if m.cache.Cached_userNeedOKTip = m.CacheFalse
        okTip = m.controller.findNode("OKTip")
        okTip.visible = false
    end if
end sub

' Called when a key on the remote is pressed
function onKeyEvent(key as String, press as Boolean) as Boolean
    handled = false
    if press then
        if key = "back"
            if m.errorTips.visible = false
                if m.top.settingFlag
                    m.homeScreen.settingShowFlag ="1"   'back from setting
                    m.homeScreen.visible = true
                    m.settingNode.visible = false
                    m.top.settingFlag = false
                    m.setTask.contentString = ""
                    m.homeScreen.setFocus(true)
                    m.setGrid = m.top.FindNode("SetGrid")
                    m.setGrid.setFocus(true)
                    handled = true
                else if m.homeScreen.visible = true
                    m.homeScreen.settingShowFlag ="2"   'back from home view
                    showHomeScreen(false)
                    handled = true
                else if m.mutiLiveViewShowState = true
                    showMutilive(false)
                    handled = true
                else if m.logoutScreen.visible = true
                    showLogoutScreen(false)
                    handled = true
                else if m.homeContent <> invalid
                    showLogoutScreen(true)
                    handled = true
                end if
            else
            end if
        else if key = "OK"
            if m.errorTips.visible = false
                if m.logoutScreen.visible = true
                    showLogoutScreen(false)
                    handled = true
                    m.isReport = true
                    stopHeartTimer()
                    if m.currentState = m.STATE_PLAY
                        reportHeart()
                    else
                        m.isExit = true
                        makePlayReport(getPlayReportParams(m.global.action.end))
                    end if
                else if m.homeScreen.visible = false
                    hideController()
                    showHomeScreen(true)
                    handled = true
                    m.cache.Cached_userNeedOKTip = m.CacheFalse
                    updateOKTip()
                end if
            end if
        else if key = "options"
        else if key = "left"
            if m.errorTips.visible = false
                if m.homeScreen.visible = false and m.mutiLiveViewShowState = false
                ' previous channel
                    previousChannel()
                    m.cache.Cached_userNeedChangeChannelGuidelines = m.CacheFalse
                    handled = true
                end if
            end if
        else if key = "right"
            if m.errorTips.visible = false
                if m.homeScreen.visible = false and m.mutiLiveViewShowState = false
                    ' next channel
                    nextChannel()
                    m.cache.Cached_userNeedChangeChannelGuidelines = m.CacheFalse
                    handled = true
                end if
            end if
        else if key = "down"
            if m.errorTips.visible = false
                if m.homeScreen.visible = false
                m.cache.Cached_userNeedDownKeyGuidelines = m.CacheFalse
                if m.channelSelected <> invalid
                    if m.channelSelected.channelType <> invalid
                        if m.channelSelected.channelType = "3"  'Loop program
                            if m.mutiLiveViewShowState = false
                                showMutilive(true)
                            else
                                showMutilive(false)
                            end if
                        else
                            ?"Not Loop program has no program items"
                        end if
                    end if
                end if
            end if
            result = true
            end if
        end if
    end if
    return handled
end function

sub showHomeScreen(show as Boolean)
    if show
        m.homeScreen.curChannelPlaying = m.channelSelected
        m.homeScreen.visible = true
        m.homeScreen.setFocus(true)
    else
        m.homeScreen.visible = false
        m.homeScreen.setFocus(false)
        m.top.setFocus(true)
    end if
end sub

sub showLogoutScreen(show as Boolean)
    if show
        if (m.homeContent <> invalid) and (m.homeContent.getChildCount() > 0)
            categoryContent = m.homeContent.getChild(0) '0 : feature category index.
            m.logoutScreen.likeChannelContent = m.categoryContent
        end if
        m.top.setFocus(false)
        m.logoutScreen.visible = true
        m.logoutScreen.setFocus(true)
    else
        m.logoutScreen.visible = false
        m.logoutScreen.setFocus(false)
        m.top.setFocus(true)
    end if
end sub

function onVideoSchedule(event as Object)
    uri = event.getData()
    setVideo(uri)
    playVideo()
end function

function changeState(targetState as Integer)
    m.currentState = targetState
    if m.currentState = m.STATE_INIT
        makePlayReport(getPlayReportParams(m.global.action.init))
    else if m.currentState = m.STATE_PLAY
        makePlayReport(getPlayReportParams(m.global.action.play))
        startHeartTimer()
    else if m.currentState = m.STATE_EBLOCK
        m.currentState = m.STATE_PLAY
        makePlayReport(getPlayReportParams(m.global.action.eblock))
        startHeartTimer()
    end if
end function

sub startHeartTimer()
    m.heartTimer.control = "start"
end sub

sub stopHeartTimer()
    m.heartTimer.control = "stop"
end sub

sub setVideo(uri as String)
    m.videoContent = createObject("RoSGNode", "ContentNode")
    m.videoContent.url = uri
    m.videoContent.streamformat = "hls"
    m.initPlay = false
end sub

sub playVideo()
    m.player.content = m.videoContent
    m.player.control = "play"
end sub

sub replayVideo()
    initUUID()
    changeState(m.STATE_INIT)
    playVideo()
end sub

sub retry()
    setSuffix()
    changeState(m.STATE_INIT)
    if m.channelStreams <> invalid AND m.channelStreams[m.defStreamPos] <> invalid
        requestVideoScheduleURL(m.channelStreams[m.defStreamPos]["streamName"])
    else
        if screenHasNoMainViews()
            showErrorTips(m.global.error.playerror_retry_nextchannel)
        end if
    end if
end sub

function onNetworkErrorChanged(event as Object)
    netStates = event.getData()
    if netStates = m.global.netStatus.netRight
        if m.errorTips.visible
            hideErrorTips()
        end if
    else
        showErrorTips(netStates)
    end if
end function

function showErrorTips(errorType as Object)
    hideRetrievingBar()
    hideController()

    stopLoadingDelayTimer()
    if errorType = m.global.error.playerror_retry_nextchannel
        m.errorTips.errorType = m.global.error.playerror_retry_nextchannel
        m.errorTips.visible = true
    else if errorType = m.global.error.neterror_retry
        m.errorTips.errorType = m.global.error.neterror_retry
        m.errorTips.visible = true
    else if errorType = m.global.error.neterror_toast
        m.mutiliveToast.visible = true
        m.mutiliveToast.showText = "Networking connetion fails, please try again"
        m.mutiliveToast.showTime = "3"
    else
        'reset flag
    end if
end function

function hideErrorTips()
    if m.errorTips.visible = true
        m.errorTips.visible =false
    end if
end function

function onMutiLiveContentChanged(event as Object)
     m.mutiliveContentNode = event.getData()
     m.mutiLiveMainView.inTenMinsFlag = true
     reloadMutiLiveViewShowStateData()
end function

function reloadMutiLiveViewShowStateData()
    if m.mutiLiveViewShowState
        m.mutiLiveMainView.mutiliveContentNode = m.mutiliveContentNode
    end if
end function

sub nextChannel()
    if m.channels.isEmpty() <> true
        if m.channelIndex < m.channels.count() - 1
            m.channelIndex++ 'move to next
        else
            m.channelIndex = 0 'move to first
        end if
        changeChannel(getChannelData(m.channels[m.channelIndex]))
    end if
end sub

sub previousChannel()
    if m.channels.isEmpty() <> true
        if m.channelIndex > 0
            m.channelIndex--
        else
            m.channelIndex = m.channels.count() - 1
        end if
        changeChannel(getChannelData(m.channels[m.channelIndex]))
    end if
end sub

sub changeChannel(selectedChannel as Object)
    stopHideTimer()
    startLoadingDelayTimer()
    'showRetrievingBar()
    showController()
    hideErrorTips()
    if m.currentState <> m.STATE_IDLE AND m.currentState <> m.STATE_END
        reportEnd()
    end if
    m.channelSelected = selectedChannel
    if m.channelSelected <> invalid
        m.currentChannelType = m.channelSelected.channelType
        if m.currentChannelType = m.global.channel_type.lunbo
            setLastWatchedChannelId(m.channelSelected.channelId)
        end if
        updateController()
        m.channelStreams = m.channelSelected.channelStreams
        initUUID()
        changeState(m.STATE_INIT)
        if m.channelStreams <> invalid AND m.channelStreams[m.defStreamPos] <> invalid
            if m.channelStreams[m.defStreamPos]["streamName"] <> invalid
                requestVideoScheduleURL(m.channelStreams[m.defStreamPos]["streamName"])
            end if
        end if
        initProgress()

        m.mutiLiveMainView.mutiliveContentNode = getMutiEmptyContent(m.mutiliveContentNode,m.mutiEmptyContent)

    end if
end sub

function getLastWatchedChannelId() as String
    if m.cache <> invalid
        return m.cache.Cached_lastWatchedChannelId
    end if
    return ""
end function

sub setLastWatchedChannelId(channelId as String)
    if m.cache <> invalid
        m.cache.Cached_lastWatchedChannelId = channelId
    end if
end sub

sub initProgress()
    m.controller.position = 0
    m.controller.duration = m.duration
    if m.currentChannelType = m.global.TYPE_LIVE
        setSeekBarWidth(m.SEEKBAR_WIDTH_LIVE)
    else
        setSeekBarWidth(m.SEEKBAR_WIDTH_POLLING)
    end if
    m.isUpdateSeekBar = false
end sub

' init views
sub initViews()
    m.player = m.top.findNode("Video")
    m.player.observeField("state","onPlayerStateChange")
    m.player.control = "play"
    m.controller = m.top.findNode("PlayerController")
    m.controller.observeField("visible","onControllerVisibiltyChange")
    m.homeScreen = m.top.findNode("HomeScreen")
    m.homeScreen.observeField("channelSelected", "onChannelSelected")
    m.homeScreen.observeField("settingItemSelected", "onSettingItemSelected")
    m.homeScreen.observeField("visible","homeScreenVisibleChange")

    m.controllerTimer = m.top.findNode("ControllerTimer")
    m.controllerTimer.observeField("fire", "hideController")
    m.retrievingBar = m.top.findNode("RetrievingBar")
    m.seekBarUpdateTimer = m.top.findNode("SeekBarUpdateTimer")
    m.seekBarUpdateTimer.observeField("fire", "startUpdateSeekBar")
    m.seekBarUpdateTimer.duration = getRemaining(m.player.position * 1000)

    m.heartTimer = m.top.findNode("HeartTimer")
    m.heartTimer.duration = 15
    m.heartTimer.observeField("fire", "startHeartReport")

    m.loadingDelayTimer = m.top.findNode("loadingDelayTimer")
    m.loadingDelayTimer.observeField("fire", "showRetrievingBar")

    m.ShowBar = m.top.findNode("ShowBar")
    m.HideBar = m.top.findNode("HideBar")
    m.mutiLiveMainView = m.top.findNode("MLMutiLiveMainView")
    m.mutiLiveMainView.observeField("mutiLiveSelectedNode", "onMutiLiveSelected")
    m.mutiLiveMainView.observeField("translation","mutiLiveMainViewTranslationChange")
    m.LiveRowList = m.top.findNode("MLProgramRowList")
    m.mutiLiveOprationTimer = m.top.findNode("MutiLiveOprationTimer")
    m.mutiLiveOprationTimer.observeField("fire", "mutiLiveOprationTimerFired")

    m.logoutScreen = m.top.findNode("LogoutScreen")
    m.logoutScreen.observeField("channelSelected", "onChannelSelected")
    m.logoutScreen.observeField("visible","logoutScreenVisibleChange")

    m.settingNode = m.top.findNode("SettingScreen")
    m.setTask = CreateObject("roSGNode","SetTask")
    m.setTask.observeField("contentString","contentStringChange")

    m.changeChannelTipPoster = m.top.findNode("changeChannelTipPoster")
    m.downKeyTipPoster = m.top.findNode("downKeyTipPoster")
    m.hadShowedChannelTipPosterFirst = false
    m.hadShowedChannelTipPosterSecond = false
    m.hadPlayed = false
    m.TimerControlStart = "start"
    m.CacheFalse = "false"
    m.userChangeChannelGuidelinesTimer = m.top.findNode("userChangeChannelGuidelinesTimer")
    m.userNeedDownKeyGuidelinesTimer = m.top.findNode("userNeedDownKeyGuidelinesTimer")
    m.userChangeChannelGuidelinesSecondTimer = m.top.findNode("userChangeChannelGuidelinesSecondTimer")
    m.userChangeChannelGuidelinesDisappearTimer = m.top.findNode("changeChannelTipPosterDisappearTimer")
    m.userNeedDownKeyGuidelinesDisappearTimer = m.top.findNode("downKeyTipPosterDisappearTimer")
    m.userChangeChannelGuidelinesTimer.observeField("fire","fireUserChangeChannelGuidelinesTimer")
    m.userNeedDownKeyGuidelinesTimer.observeField("fire","fireUserUseDownKeyGuidelinesTimer")
    m.userChangeChannelGuidelinesDisappearTimer.observeField("fire","fireUserChangeChannelGuidelinesDisappearTimer")
    m.userNeedDownKeyGuidelinesDisappearTimer.observeField("fire","fireUserNeedDownKeyGuidelinesDisappearTimer")
    m.userChangeChannelGuidelinesSecondTimer.observeField("fire","fireUserChangeChannelGuidelinesSecondTimer")
    m.mutiTranslation = {"minY":608,
                         "maxY":1080,
                         "midY":800}
    updateOKTip()

    m.errorTips = m.top.findNode("ErrorTips")
    m.errorTips.observeField("visible", "onErrorTipsVisibleChanged")
    m.errorTips.observeField("retryHomeRequestType", "retryHomeRequestTypeChange")
    m.errorTips.observeField("retryPlayRequestType", "retryPlayRequestTypeChange")
    m.errorTips.observeField("nextChannelRequestType", "nextChannelRequestTypeChange")

    m.toastWidth = 860
    m.toastHeight = 100
    m.mutiliveToast = m.top.findNode("mutiliveToast")
    m.mutiliveToast.translation=[530,808.0]
    m.toastPoster = m.top.findNode("toastPoster")
    m.toastPoster.width = m.toastWidth
    m.toastPoster.height = m.toastHeight
    m.toastLable = m.top.findNode("toastLable")
    m.toastLable.width = m.toastWidth
    m.toastLable.height = m.toastHeight
end sub

sub startHeartReport()
    reportHeart()
    setHeartTimes(false)
    startHeartTimer()
end sub

function retryHomeRequestTypeChange(event as Object)
    retryType = event.getData()
    if retryType
        hideErrorTips()
        requestHomePage()
    end if
end function

function retryPlayRequestTypeChange(event as Object)
    retryType = event.getData()
    if retryType
        hideErrorTips()
        retry()
    end if
end function

function nextChannelRequestTypeChange(event as Object)
    nextChannelType = event.getData()
    if nextChannelType
        hideErrorTips()
        nextChannel()
    end if
end function

function contentStringChange(event as Object)
    m.contentString = event.getData()
    m.settingNode.SettingScreenContentString = m.contentString
    m.settingNode.SettingScreenContentString = ""  'reSet for next change
end function

sub initUriHandler()
    m.UriHandler = CreateObject("roSGNode", "UriHandler")
    m.UriHandler.observeField("homeContent","onContentChanged")
    m.UriHandler.observeField("videoSchedule","onVideoSchedule")
    m.UriHandler.observeField("mutiLiveContent","onMutiLiveContentChanged")
    m.UriHandler.observeField("networkError","onNetworkErrorChanged")
end sub

sub initFields()
    m.STATE_IDLE = 0
    m.STATE_INIT = 1
    m.STATE_PLAY = 2
    m.STATE_BLOCK = 3
    m.STATE_EBLOCK = 4
    m.STATE_END = 5
    m.STATE_ERROR = 6
    m.currentState = m.STATE_IDLE
    m.suffix = 0
    m.SEEKBAR_WIDTH_LIVE = 1734
    m.SEEKBAR_WIDTH_POLLING = 1200
    m.cache = CreateObject("roSGNode","Cache")
'    m.cache.Cached_userNeedChangeChannelGuidelines = "true"
'    m.cache.Cached_userNeedDownKeyGuidelines = "true"
    m.videoURL = m.global.video_schedule_url
    m.mutiListURL = m.global.muti_list_url + "&channelIds="
    m.isUpdateSeekBar = false
    m.mutiLiveViewShowState = false
    m.defaultCategoryIndex = 0 'the default category index of the roku live play in the first time.
    m.channelIndex = 0
    m.duration = 0
    m.playStartTime = 0
    m.playStopTime = 0
    m.playTime = 0
    m.channels = CreateObject("roArray", 0, true)
    m.channelStreams = invalid
    m.currentChannelType = invalid
    m.defStreamPos = 2
    m.reportHeartTimes = 1
    m.isExit = false
    m.isReport = false
    'fix screen re-refresh bug
    m.initPlay = true
    m.reportCallback = function(event as Object)
        jobNum = event.getData()
            if m.isReport
                m.isReport = false
                m.isExit = true
                makePlayReport(getPlayReportParams(m.global.action.end))
            else
                if m.isExit = true
                    m.isExit = false
                    m.global.EXIT_ROKU_LIVE = true
                end if
            end if
    end function
    setAfterUriRequestCallback(m.reportCallback)
    m.mutiEmptyContent = CreateObject("roSGNode", "RowListContent")
    initUUID()
    setAppRunID()
    setInstallID()
    makeEnvReport(getEnvironmentParams(m.global.uuid))
end sub

sub onControllerVisibiltyChange()
        showUserGuidelines()
        if m.controller.visible = true
            m.changeChannelTipPoster.visible = false
            m.downKeyTipPoster.visible = false
        end if
'    if m.controller.visible
'        if m.controllerTimer.control <> "start"
'            m.controllerTimer.control = "start"
'        end if
'    else
'        if m.controllerTimer.control = "start"
'            m.controllerTimer.control = "stop"
'        end if
'    end if
end sub

sub updateController()
    if m.currentChannelType = m.global.TYPE_LIVE
        hideChannelNextView()
        hideChannelCurrentDuration()
        setChannelNumber(m.global.NUMERIC_KEY_LIVE)
    else
        showChannelNextView()
        showChannelCurrentDuration()
        if m.channelSelected.numericKeys <> invalid
            setChannelNumber(m.channelSelected.numericKeys)
        end if
    end if
    if m.channelSelected.channelName <> invalid
        setChannelName(m.channelSelected.channelName)
    end if
    if m.channelSelected.curProgram <> invalid
        if m.channelSelected.curProgram["playTimeinMills"] <> invalid
            currentPlayTime = getPlayTime(m.channelSelected.curProgram["playTimeinMills"])
            setChannelCurrentStartTime(currentPlayTime)
        end if
        if m.channelSelected.curProgram["title"] <> invalid
            setChannelCurrentTitle(m.channelSelected.curProgram["title"].trim())
        end if
        if m.channelSelected.curProgram["duration"] <> invalid
            durationStr = m.channelSelected.curProgram["duration"]
            m.duration = val(durationStr, 10)
            durationStr = getHours(durationStr)
            'TODO change
            if durationStr = " 0.0hrs"
                durationStr = " 0.1hrs"
            end if
            setChannelCurrentDuration(durationStr)
        end if
        channelRating = m.channelSelected.curProgram["contentRating"]
        if type(channelRating) = "Invalid"
            setChannelCurrentRating(" ")
        else
            setChannelCurrentRating(channelRating.trim())
        end if
        playTimeinMills = m.channelSelected.curProgram.playTimeinMills
        endTimeinMills  = m.channelSelected.curProgram["endTimeinMills"]
    end if
    if m.channelSelected.nextProgram <> invalid
        if m.channelSelected.nextProgram["playTimeinMills"] <> invalid
            nextPlayTime = getPlayTime(m.channelSelected.nextProgram["playTimeinMills"])
            setChannelNextStartTime(nextPlayTime)
        end if
        if m.channelSelected.nextProgram["title"] <> invalid
            setChannelNextTitle(m.channelSelected.nextProgram["title"])
        end if
    end if
end sub

function getErrorParams(isPlayerError as Boolean, errorCode as String, uuid as String) as Object
    params = getBaseParams(uuid)
    if isPlayerError
        params.addReplace("et", "pl")
    end if
    params.addReplace("err", errorCode)
    return params
end function

function getEnvironmentParams(uuid as String) as Object
    params = getBaseParams(uuid)
    if isWifi() 'wifi network
        if getConnectionInfo().ssid <> invalid then params.addReplace("ssid", getConnectionInfo().ssid)
    end if
    return params
end function

function getBaseParams(uuid as String) as Object
    baseParams = {
        ctime : nowAsMilliseconds(),
        uuid : uuid,
        os : m.global.os,
        model : GetModel(),
        osv : GetDeviceVersion(),
        ro : getResolution()
        xh : m.global.xh
        bd : GetModelDetails().VendorName
    }
    return baseParams
end function

function getPlayReportParams(action as String) as Object
    if m.global.action.time = action
        return getTimeParams(action)
    else if m.global.action.init = action
        return getInitParams(action)
    else if m.global.action.play = action
        return getPlayParams(action)
    else if m.global.action.block = action or m.global.action.eblock = action
        return getBlockParams(action)
    else if m.global.action.finish = action or m.global.action.end = action
        return getFinishParams(action)
    end if
end function

function getFinishParams(action as String) as Object
    params = {
        ctime : nowAsMilliseconds(),
        uuid: m.global.uuid,
        ch : m.global.ch,
        ac : action,
        vt : m.channelStreams[m.defStreamPos]["rateType"],
        prg : m.player.position
    }
    addCommonParams(params)
    return params
end function

function getBlockParams(action as String) as Object
    params = {
        ctime : nowAsMilliseconds(),
        uuid: m.global.uuid,
        ch : m.global.ch,
        ac : action,
        vt : m.channelStreams[m.defStreamPos]["rateType"],
        prg : m.player.position
    }
    addCommonParams(params)
    return params
end function

function getPlayParams(action as String) as Object
    params = {
        ctime : nowAsMilliseconds(),
        uuid: m.global.uuid,
        ch : m.global.ch,
        ac : action,
        vt : m.channelStreams[m.defStreamPos]["rateType"],
    }
    params.addReplace("pay",m.channelSelected.isPay)
    params.addReplace("joint",m.global.joint.no)
    params.addReplace("prl",m.global.prl.no_preloading)
    addCommonParams(params)
    return params
end function

function getInitParams(action as String) as Object
    params = {
        ctime : nowAsMilliseconds(),
        uuid: m.global.uuid,
        ch : m.global.ch,
        ac : action,
        vt : m.channelStreams[m.defStreamPos]["rateType"],
    }
    addCommonParams(params)
    return params
end function

function getTimeParams(action as String) as Object
    params = {
        ctime : nowAsMilliseconds(),
        uuid: m.global.uuid,
        ch : m.global.ch,
        ac : action,
        vt : m.channelStreams[m.defStreamPos]["rateType"],
        pt : m.playTime
    }
    addCommonParams(params)
    return params
end function

sub addCommonParams(params as Object)
    if m.channelSelected.channelId <> invalid
        params.addReplace("cid",m.channelSelected.channelId)
    end if
    if m.currentChannelType = m.global.TYPE_LIVE
        params.addReplace("ty",m.global.ty.live.toStr())
        params.addReplace("lid",m.channelSelected.channelId)
    else
        params.addReplace("ty", m.global.ty.polling.toStr())
        pid = m.channelSelected.curProgram.aid
        if pid <> invalid
            params.addReplace("pid", pid)
        else
            params.addReplace("pid", m.global.unknown)
        end if
        params.addReplace("st", m.channelSelected.channelEname)
        params.addReplace("vid", m.channelStreams[m.defStreamPos]["streamId"])
        params.addReplace("zid", m.global.unknown)
    end if
end sub

function getDuration() as Integer
    if m.player <> invalid
        return m.player.position
    else
        return 0
    end if
end function

sub setSeekBarWidth(width as Integer)
    m.controller.seekbar_width = width
end sub

sub hideChannelCurrentDuration()
    m.controller.current_duration_visible = false
end sub

sub showChannelCurrentDuration()
    m.controller.current_duration_visible = true
end sub

sub hideChannelNextView()
    m.controller.next_layout_visible = false
end sub

sub showChannelNextView()
    m.controller.next_layout_visible = true
end sub

sub showController()
    if m.homeScreen.visible = false
        m.controller.visible = true
    end if
end sub

sub hideController()
    m.controller.visible = false
end sub

sub showRetrievingBar()
    if m.retrievingBar.visible = false
        m.retrievingBar.visible = true
    end if
end sub

sub hideRetrievingBar()
    if m.retrievingBar.visible
        m.retrievingBar.visible = false
    end if
end sub

sub setChannelName(channelName as String)
    m.controller.channel_name = channelName
end sub

sub setChannelNumber(channelNumber as String)
    m.controller.channel_number = channelNumber
end sub

sub setChannelCurrentStartTime(currentStartTime as String)
    m.controller.current_start_time = currentStartTime
end sub

sub setChannelCurrentTitle(currentTitle as String)
    m.controller.current_title = currentTitle
end sub

sub setChannelCurrentDuration(currentDuration as String)
    m.controller.current_duration = currentDuration
end sub

sub setChannelNextStartTime(nextStartTime as String)
    m.controller.next_start_time = nextStartTime
end sub

sub setChannelNextTitle(nextTitle as String)
    m.controller.next_title = nextTitle
end sub

sub setChannelCurrentRating(currentRating as String)
    m.controller.current_rating = currentRating
end sub

sub setSuffix()
    m.suffix += 1
    setUUID()
end sub

sub initUUID()
    m.suffix = 0
    setUUID()
end sub

sub setUUID()
    m.global.uuid = getMac().replace(":","") + nowAsMilliseconds() + "_" + m.suffix.toStr()
end sub

sub setAppRunID()
    m.global.apprunid = getDeviceESN() + "_" + nowAsMilliseconds()
end sub

sub setInstallID()
    if m.global.installid = ""
        if m.cache.Cached_installID = invalid OR m.cache.Cached_installID = ""
            m.cache.Cached_installID = getRandomUUID().replace("-","")
        end if
        m.global.installid = m.cache.Cached_installID
    end if
end sub

function mutiLiveOprationTimerFired()
    if m.mutiLiveViewShowState and getMutiliveHiddenKeypress()
        showMutilive(false)
    end if
end function

sub startMutiLiveOprationTimer()
    if m.mutiLiveOprationTimer.control <> "start"
        m.mutiLiveOprationTimer.control = "start"
    end if
end sub

sub stopMutiLiveOprationTimer()
    if m.mutiLiveOprationTimer.control = "start"
        m.mutiLiveOprationTimer.control = "stop"
    end if
end sub

function showMutilive(show as Boolean)
    if show
'        m.LiveRowList.setFocus(true)
        m.ShowBar.control = "start"
        m.mutiLiveViewShowState = true
        m.mutiLiveMainView.reloadDataFlag = true
        hideController()
        requestMutiLiveData()
        startMutiLiveOprationTimer()
    else
        m.LiveRowList.setFocus(false)
        m.top.setFocus(true)
        m.HideBar.control = "start"
        m.mutiLiveViewShowState = false
        m.mutiLiveMainView.reloadDataFlag = false
        m.mutiLiveMainView.mutiliveContentNode = getMutiEmptyContent(m.mutiliveContentNode,m.mutiEmptyContent)
        stopMutiLiveOprationTimer()
    end if
end function
