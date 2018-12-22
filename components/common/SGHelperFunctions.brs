' Helper function to select only a certain range of content
function select(array as object, first as integer, last as integer) as object
  result = []
  for i = first to last
    result.push(array[i])
  end for
  return result
end function

' Helper function to add and set fields of a content node
function AddAndSetFields(node as object, aa as object)
  'This gets called for every content node -- commented out since it's pretty verbose
  addFields = {}
  setFields = {}
  for each field in aa
    if node.hasField(field)
      setFields[field] = aa[field]
    else
      addFields[field] = aa[field]
    end if
  end for
  node.setFields(setFields)
  node.addFields(addFields)
end function

'*************************************************************
'** replaceTokens
'** @brief get 12-hour clock time,end with am or pm
'** @param strIn Input String
'** @param recquery query string to replace
'*************************************************************
Function replaceTokens(strIn as string, recquery As string, value As string) as Object
  result = strIn
  regExp = CreateObject("roRegex", recquery, "i")
  if regExp.IsMatch(strIn)
    result = regExp.ReplaceAll(strIn, value)
  end if
  return result
End Function

'Get the channel data.
function getChannelData(channel as Object) as Object
    if channel = invalid then return invalid
    channelContent = CreateObject("roSGNode", "ChannelGridItemData")
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
    return channelContent
end function

'*************************************************************
'** getSettingGridContent
'** @return Setting ContentNode
'*************************************************************
function getSettingGridContent() as Object
    channelGridData = CreateObject("roSGNode", "ContentNode")

    channelPrivite = channelGridData.CreateChild("SetData")
    channelPrivite.name = "Privacy Policy"
    channelPrivite.selectUri = "pkg:/images/Setting_privacy_policy_select.png"
    channelPrivite.unselectUri = "pkg:/images/Setting_privacy_policy_unselect.png"
    channelPrivite.selectBackgroundUri = "pkg:/images/Setting_gridItem_select.png"
    channelPrivite.unselectBackgroundUri = "pkg:/images/Setting_gridItem_unselect.png"
    channelPrivite.setId = m.global.setting_privacy

    channelTerm = channelGridData.CreateChild("SetData")
    channelTerm.name = "Terms of Use"
    channelTerm.selectUri = "pkg:/images/Setting_terms_service_select.png"
    channelTerm.unselectUri = "pkg:/images/Setting_terms_service_unselect.png"
    channelTerm.selectBackgroundUri = "pkg:/images/Setting_gridItem_select.png"
    channelTerm.unselectBackgroundUri = "pkg:/images/Setting_gridItem_unselect.png"
    channelTerm.setId = m.global.setting_use
    return channelGridData
end function

function getV2SettingGridContent() as Object
    channelGridData = CreateObject("roSGNode", "ContentNode")

    channelPrivite = channelGridData.CreateChild("SetData")
    channelPrivite.name = "Privacy  Terms"
    channelPrivite.selectUri = "pkg:/images/Setting_privacy_policy_select.png"
    channelPrivite.unselectUri = "pkg:/images/Setting_privacy_policy_unselect.png"
    channelPrivite.selectBackgroundUri = "pkg:/images/Setting_gridItem_select.png"
    channelPrivite.unselectBackgroundUri = "pkg:/images/Setting_gridItem_unselect.png"
    channelPrivite.setId = m.global.setting_privacy
    return channelGridData
end function

function getLastMutiliveProgramItemPlayTimeMili(mutiliveContentNode as Object) as String
    count = mutiliveContentNode.getChildCount()
    if count>0
        contentNode = mutiliveContentNode.getChild(0)
        count = contentNode.getChildCount()
        if count>0
            return contentNode.getChild(count-1).playTimeinMills
        end if
    end if
    return ""
end function

function hasMutiDataStruct(mutiEmptyContent as Object) as Boolean
    if mutiEmptyContent<>invalid
        count = mutiEmptyContent.getChildCount()
        if count>0
            emptyChildContentNode = mutiEmptyContent.getChild(0)
            if emptyChildContentNode <>invalid
                count = emptyChildContentNode.getChildCount()
                if count > 0
                    return true
                end if
            end if
        end if
    end if
    return false
end function

function getMutiEmptyContent(mutiContent as Object,oldMutiEmptyContent as Object) as Object
    if (hasMutiDataStruct(mutiContent)) and (hasMutiDataStruct(oldMutiEmptyContent))
        mutiCount = mutiContent.getChild(0).getChildCount()
        oldEmptyCount = oldMutiEmptyContent.getChild(0).getChildCount()
        t = mutiCount-oldEmptyCount
        if t > 0
            sectionData = oldMutiEmptyContent.getChildCount(0)
            for i = 0 to (t - 1)
                dataItem = sectionData.CreateChild("MLRowItemData")
                dataItem.title=""
                dataItem.showMutiLiveFlag=false
            end for
        else
        end if
    end if
    return oldMutiEmptyContent
end function
