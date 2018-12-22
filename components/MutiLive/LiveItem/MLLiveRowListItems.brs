'*************************************************************
'** Roku Live - https://github.com/h4091
'** @Application: Live
'** @File: MLLiveRowListItems.brs
'** @Author: h4091
'** @Brief description
'** @uses modules
'*************************************************************
Sub init()
    m.Poster = m.top.findNode("mlLivePoster")
    m.ItemNormalTitleView = m.top.findNode("MLItemNormalTitleView")
    m.ItemLiveTitleLivingPoster = m.top.findNode("mlLiveTitleLivingPoster")

    m.Bottomlabel = m.top.findNode("mlrowBottomlabel")
    m.Bottomlabel.font.size = "27"

    m.itemOverlay = m.top.findNode("itemOverlay")

    m.ItemLiveNormalTitleView = m.top.findNode("mlItemLiveNormalTitleView")

    m.ItemLiveSelectedTitleView = m.top.findNode("mlItemLiveSelectedTitleView")
    m.ItemLiveSelecteLabel      = m.top.findNode("mlItemLiveSelecteLabel")
    m.ItemRateLabel      = m.top.findNode("mlItemRateLabel")

    m.ItemLiveSelecteLabel.font.size= "30"
    m.ItemRateLabel.font.size = "27"

    m.LiveScaleGroup = m.top.findNode("mlLiveScaleGroup")
    m.LiveScaleGroup.scaleRotateCenter = [180,180]

    m.LiveCannotPlayLabel = m.top.findNode("mlLiveCannotPlayLabel")
    m.LiveCannotPlayLabel.font.size = "30"
    m.LiveCannotPlayLabel.text = "COME SOON"
End Sub

Sub itemContentChanged()
    if m.top.itemContent.showMutiLiveFlag
        changeShowField()
        updateLiveState()
        updateLayout()
    else
    end if
End Sub

sub changeShowField()
     if m.top.itemContent.viewPic <> invalid
        m.Poster.uri = m.top.itemContent.viewPic
    end if

    if m.top.itemContent.title <> invalid
        m.Bottomlabel.text = m.top.itemContent.title
    endif

    if m.top.itemContent.title<> invalid
        m.ItemLiveSelecteLabel.text= m.top.itemContent.title
    end if

    if m.top.itemContent.playTime<> invalid
        m.ItemRateLabel.text = m.top.itemContent.playTime
    end if
end sub
Sub updateLayout()
    if m.top.height > 0 and m.top.width > 0

    end if
End Sub

function updateLiveState()
    if m.top.itemContent <> invalid
        if  m.top.itemContent.programType=0
            m.itemOverlay.opacity = 1
            m.ItemNormalTitleView.visible = true
            m.ItemLiveTitleLivingPoster.visible = false
            m.LiveCannotPlayLabel.visible = false
        else if m.top.itemContent.programType=1
            m.itemOverlay.opacity = 1
            m.ItemNormalTitleView.visible = false
            m.ItemLiveTitleLivingPoster.visible = true
            m.LiveCannotPlayLabel.visible = false
        else if m.top.itemContent.programType=2
            m.itemOverlay.opacity = 0.3
            m.ItemNormalTitleView.visible = false
            m.ItemLiveTitleLivingPoster.visible = false
            m.LiveCannotPlayLabel.visible = true
        end if
    end if
end function

function focusPercentChanged()
    if m.top.focusPercent = 1
            m.itemOverlay.opacity = 1
            m.ItemLiveNormalTitleView.visible = false
            m.ItemLiveSelectedTitleView.visible = true
    else
            m.itemOverlay.opacity = 0.8
            m.ItemLiveNormalTitleView.visible = true
            m.ItemLiveSelectedTitleView.visible = false
    end if

    scale = 1 + (m.top.focusPercent * 0.1)
    m.LiveScaleGroup.scale  =[scale,scale]

    updateLiveState()
end function