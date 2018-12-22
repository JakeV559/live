'*************************************************************
'** Roku Live - https://github.com/h4091
'** @Application: Live
'** @File: MLMutiLive.brs
'** @Author: h4091
'** @Brief description
'** @uses modules
'*************************************************************
Sub init()
    initTimer()

    m.mlTitleLabel = m.top.findNode("MLMainTitle")
    m.mlTitleLabel.font.size = "30"
    m.ProgramRowList = m.top.findNode("MLProgramRowList")
    m.LiveRowList = m.top.findNode("MLLiveRowList")
    m.LiveRowList.ObserveField("itemSelected", "onMutiLiveItemSelected")
    m.LiveRowList.visible = false
    m.itemOverlay = m.top.findNode("itemOverlay")
    m.top.observeField("curProgram", "onCurProgramChanged")
    m.top.observeField("channelID", "onChannelChanged")
    m.top.observeField("mutiliveContentNode", "mutiliveContentChanged")
    m.top.observeField("inTenMinsFlag", "inTenMinsFlagChanged")
End Sub

function initTimer()
    m.mutiliveTimer = createObject("RoSGNode","Timer")
    m.mutiliveTimer.repeat = false
    m.mutiliveTimer.duration = 10 * 60
    m.mutiliveTimer.observeField("fire", "mutiliveTimerFired")
end function

function mutiliveTimerFired()
    m.top.inTenMinsFlag = false
end function

function inTenMinsFlagChanged()
    if m.top.inTenMinsFlag
        if m.mutiliveTimer.control <> "start"
            m.mutiliveTimer.control = "start"
        end if
    end if
end function

function mutiliveContentChanged()
    if m.top.reloadDataFlag
        reloadData()
        m.ProgramRowList.setFocus(true)
    else
        m.ProgramRowList.jumpToRowItem = [0,0]
        m.ProgramRowList.content = m.top.mutiliveContentNode
    end if
end function

function onChannelChanged(event as Object)
    m.channelID = event.getData()
end function

function onCurProgramChanged(event as Object)
    m.curProgram = event.getData()
end function

function onMutiLiveItemSelected()
    itemSelectedNode = m.ProgramRowList.itemSelected
    mutiProgramSelectedNode = m.ProgramRowList.content.getChild(itemSelectedNode)
    m.top.mutiLiveSelectedNode = mutiLiveSelectedNode
end function

function reloadData()
    contentData = m.top.mutiliveContentNode
    if contentData<> invalid
        tmpCount = contentData.getChildCount()
        if tmpCount>0
            contentDataChild = contentData.getChild(0)
            cateCount = contentDataChild.getChildCount()
            if cateCount>0
                j  =  getCurIndex(contentDataChild)
                if j>=0
                    if j<cateCount
                        dataItem = contentDataChild.getChild(j)
                        dataItem.livingStateType = true
                        m.ProgramRowList.content = contentData
                        m.ProgramRowList.jumpToRowItem = [0,0]
                        m.ProgramRowList.jumpToRowItem = [0,j]
                        if dataItem.showMutiLiveFlag
                            m.mlTitleLabel.text = "Program List ("+str(cateCount)+" )"
                        end if
                    else
                        ?"error :in MLMutiLive ----"
                    end if
                else
                    m.mlTitleLabel.text = ""
                    m.ProgramRowList.content = contentData
                end if
            end if
        end if
    endif
end function

function getCurIndex(contentDataChild as Object) as integer
    j = -1
    if m.top.curProgram <> invalid
        changeFlag = false
        subFlag = false
        cateCount = contentDataChild.getChildCount()
        curTimeinMills = getCurrentDateSeconds()
        for i = 0 to  cateCount-1
            item = contentDataChild.getChild(i)
            playTimeinMills = getPlayTimeinMillsSeconds(item.playTimeinMills)
            endTimeinMills = getPlayTimeinMillsSeconds(item.endTimeinMills)
            if i > 0 and (curTimeinMills > m.lastEndTimeinMills)
                m.flag = false
                if (m.lastEndTimeinMills < curTimeinMills) and (curTimeinMills <= playTimeinMills) and (curTimeinMills <= endTimeinMills)
                    m.flag = true
                end if
                if (curTimeinMills > playTimeinMills) and (curTimeinMills <= endTimeinMills)
                    m.flag = true
                end if

                if m.flag = true
                    item.livingStateType = m.global.mutilive_living
                    changeFlag = true
                    j = i
                end if
            end if

            if changeFlag
                item.livingStateType = m.global.mutilive_coming_soon
            else
                item.livingStateType = m.global.mutilive_replay
            end if

            m.lastEndTimeinMills = endTimeinMills
        end for
     end if
    return j
end function

function focusPercentChanged()
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    result = false
    if m.top.visible
        if key ="down" and press = true
            m.ProgramRowList.setFocus(true)
        end if
    end if
    return result
end function