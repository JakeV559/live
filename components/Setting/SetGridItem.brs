'*************************************************************
'** Roku Live - https://github.com/h4091
'** @Application: Live
'** @File: SetGridItem.brs
'** @Author: h4091
'** @Brief description
'** @uses modules
'*************************************************************
function init()
    m.setName = m.top.findNode("setName")
    m.itemText = m.top.findNode("setUri")
    m.gridItemPost = m.top.findNode("SetGridItemPost")
    m.gridIconPost = m.top.findNode("SetGridIconPost")
end function

function itemContentChanged()
    itemData = m.top.itemContent
    m.top.setName = itemData.name
    if itemData.focusFlag
        m.gridItemPost.uri = m.top.itemContent.selectBackgroundUri
        m.gridIconPost.uri = m.top.itemContent.selectUri
        m.gridItemPost.opacity = 0.9
    else
        m.gridItemPost.uri = m.top.itemContent.unselectBackgroundUri
        m.gridIconPost.uri = m.top.itemContent.unselectUri
        m.gridItemPost.opacity = 0.85
    end if
end function