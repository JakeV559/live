'*************************************************************
'** Roku Live - https://github.com/h4091
'** @Application: Live
'** @File: CategoryListItem.brs
'** @Author: h4091
'** @Brief description
'** @uses modules
'*************************************************************
function init()
    m.categoryBar = m.top.findNode("categoryBar")
    m.categoryNameHelp = m.top.findNode("categoryNameHelp")
    m.categoryName = m.top.findNode("categoryName")
    m.contentTotal = m.top.findNode("contentTotal")
    m.categoryStatus = m.top.findNode("categoryStatus")

    m.top.opacity = 0.5

    m.categoryNameMaxWidth = 267
    m.categoryStatusOffsetX = 15
    m.categoryStatusOffsetY = 36
    m.categoryProgramPrefix = "Programs: "
end function

function categoryContentChanged()
    categoryItemData = m.top.itemContent

    m.categoryNameHelp.text = categoryItemData.categoryName
    m.categoryName.text = categoryItemData.categoryName

    boundRec = m.categoryNameHelp.boundingRect()
    if (boundRec.width > m.categoryNameMaxWidth)
        m.categoryName.maxWidth = m.categoryNameMaxWidth
    else
        m.categoryName.maxWidth = boundRec.width
    end if

    if (categoryItemData.categoryLiving)
        m.categoryStatus.visible = true
    else
        m.categoryStatus.visible = false
    end if

    categoryStatusX = m.categoryName.translation[0] + m.categoryName.maxWidth + m.categoryStatusOffsetX
    m.categoryStatus.translation = [categoryStatusX, m.categoryStatusOffsetY]

    'm.contentTotal.text = m.categoryProgramPrefix + stri(categoryItemData.contentTotal).trim()
    if (categoryItemData.channelList <> invalid)
        m.contentTotal.text = m.categoryProgramPrefix + stri(categoryItemData.channelList.count()).trim()
    else
        m.contentTotal.text = m.categoryProgramPrefix + "0" '0 default value
    end if
end function

sub focusPercentChanged()
    if (m.top.focusPercent = 1)
        m.top.opacity = 1
        m.categoryBar.visible = not m.top.listHasFocus

         if (m.categoryName.text = m.global.setting)
            m.contentTotal.visible = false
        else
            m.contentTotal.visible = true
        end if

        m.categoryName.repeatCount = -1
    else
        m.top.opacity = 0.5
        m.categoryBar.visible = false
        m.contentTotal.visible = false
        m.categoryName.repeatCount = 0
    end if
end sub
