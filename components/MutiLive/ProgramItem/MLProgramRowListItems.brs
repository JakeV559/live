'*************************************************************
'** Roku Live - https://github.com/h4091
'** @Application: Live
'** @File: MLProgramRowListItems.brs
'** @Author: h4091
'** @Brief description
'** @uses modules
'*************************************************************
Sub init()
    m.totalItemOverlay = m.top.findNode("totalItemOverlay")
    m.Poster = m.top.findNode("mlProgramPoster")
    m.focusPost = m.top.findNode("focusPost")

    m.ItemNormalTitleView = m.top.findNode("MLItemNormalTitleView")
    m.ItemProgramTitleLivingPoster = m.top.findNode("mlProgramTitleLivingPoster")

    m.Bottomlabel = m.top.findNode("mlrowBottomlabel")
    m.Bottomlabel.font.size = "27"

    m.programCannotPlayOverlayer = m.top.findNode("mlProgramCannotPlayOverlayer")

    m.ItemProgramNormalTitleView = m.top.findNode("mlItemProgramNormalTitleView")

    m.ItemProgramSelectedTitleView = m.top.findNode("mlItemProgramSelectedTitleView")
    m.ItemProgramSelecteLabel= m.top.findNode("mlItemProgramSelecteLabel")
    m.ItemProgramSelectePoster = m.top.findNode("mlItemProgramSelectePoster")
    m.ItemProgramSelecteSubLabelHelp= m.top.findNode("mlItemProgramSelecteSubLabelHelp")
    m.ItemProgramSelecteSubLabel= m.top.findNode("mlItemProgramSelecteSubLabel")

    m.ProgramScaleGroup = m.top.findNode("mlProgramScaleGroup")
    m.ProgramScaleGroup.scaleRotateCenter = [180,180]

    m.ProgramCannotPlayLabel = m.top.findNode("mlProgramCannotPlayLabel")
    m.ProgramCannotPlayLabel.font.size = "30"
    m.ProgramCannotPlayLabel.text = "Coming soon..."

    m.RowTimelabel = m.top.findNode("mlRowTimeLabel")
    m.RowTimelabel.font.size = "27"
     m.RowTimePost = m.top.findNode("mlRowTimePost")

    m.programSelecteBoundWidth = 348
    m.channelLevelMaxWidth = m.programSelecteBoundWidth
    m.channelLevelHorizSpacing = 24
    m.programSelecteBoundHeight = 57
End Sub

Sub itemContentChanged()
    if m.top.itemContent.showMutiLiveFlag
        m.totalItemOverlay.visible = true
        changeShowField()
        updateProgramState()
    else
        m.totalItemOverlay.visible = false
    end if
End Sub

sub changeShowField()
    if m.top.itemContent.viewPic <> invalid
        m.Poster.uri = m.top.itemContent.viewPic
    else
        m.Poster.uri =""
    end if

    if m.top.itemContent.title <> invalid
        m.Bottomlabel.text = m.top.itemContent.title
        m.ItemProgramSelecteLabel.text= m.top.itemContent.title
    else
        m.Bottomlabel.text = ""
        m.ItemProgramSelecteLabel.text= ""
    endif

    if m.top.itemContent.playTimeinMills<> invalid
        m.RowTimelabel.text = getDayNearToday(m.top.itemContent.playTimeinMills)
    else
        m.RowTimelabel.text = ""
    end if

    if isnonemptystr(m.top.itemContent.contentRating)
        m.ItemProgramSelectePoster.visible = true
        m.ItemProgramSelecteSubLabel.text = m.top.itemContent.contentRating
        layoutRateViews()
    else
        m.ItemProgramSelecteSubLabel.text =""
        m.ItemProgramSelectePoster.visible = false
    end if
end sub

function layoutRateViews()
    if (m.top.itemContent.contentRating <> invalid)
        m.ItemProgramSelecteSubLabelHelp.text = m.top.itemContent.contentRating
        m.ItemProgramSelecteSubLabel.text = m.top.itemContent.contentRating

        programSelecteHelpBoundRec = m.ItemProgramSelecteSubLabelHelp.boundingRect()
        if (programSelecteHelpBoundRec.width > m.channelLevelMaxWidth)
            m.ItemProgramSelecteSubLabel.width = m.channelLevelMaxWidth
            m.ItemProgramSelectePoster.width = m.channelLevelMaxWidth + m.channelLevelHorizSpacing
        else
            m.ItemProgramSelecteSubLabel.width = programSelecteHelpBoundRec.width + m.channelLevelHorizSpacing *0.3
            m.ItemProgramSelectePoster.width   = programSelecteHelpBoundRec.width + m.channelLevelHorizSpacing *1.3
        end if

        m.channelLevelTranslationX = m.programSelecteBoundWidth - m.ItemProgramSelectePoster.width - m.channelLevelHorizSpacing *0.5
        m.channelLevelTranslationY = (m.programSelecteBoundHeight - m.ItemProgramSelectePoster.height)/2

        m.ItemProgramSelectePoster.translation = [m.programSelecteBoundWidth - m.ItemProgramSelectePoster.width -m.channelLevelHorizSpacing *0.5,
                                                    m.ItemProgramSelectePoster.translation[1]]
        m.ItemProgramSelecteLabel.maxWidth = m.channelLevelTranslationX - m.channelLevelHorizSpacing
    end if
End function

function updateLayout()
End function

function updateProgramState()
    if m.top.itemContent <> invalid
       if m.global.mutilive_coming_soon=m.top.itemContent.livingStateType
            m.programCannotPlayOverlayer.opacity = 0.7
            m.ItemProgramTitleLivingPoster.visible = false
            m.ProgramCannotPlayLabel.visible = true
        else if m.global.mutilive_replay=m.top.itemContent.livingStateType
            m.programCannotPlayOverlayer.opacity = 0
            m.ItemProgramTitleLivingPoster.visible = false
            m.ProgramCannotPlayLabel.visible = false
        else if m.global.mutilive_living=m.top.itemContent.livingStateType
            m.programCannotPlayOverlayer.opacity = 0
            m.ItemProgramTitleLivingPoster.visible = true
            m.ProgramCannotPlayLabel.visible = false
        end if
    else
        m.programCannotPlayOverlayer.opacity = 0
        m.ItemProgramTitleLivingPoster.visible = false
        m.ProgramCannotPlayLabel.visible = false
    end if
end function

function focusPercentChanged()
    if m.top.focusPercent = 1
        m.programCannotPlayOverlayer.opacity = 1
        m.ItemProgramNormalTitleView.visible = false
        m.ItemProgramSelectedTitleView.visible = true
        m.RowTimePost.uri="pkg:/images/MutiLive_TimeLine_Living.png"
        m.ItemProgramSelecteLabel.text= m.top.itemContent.title
        m.focusPost.visible = true
    else
        m.programCannotPlayOverlayer.opacity = 0.7
        m.ItemProgramNormalTitleView.visible = true
        m.ItemProgramSelectedTitleView.visible = false
        m.RowTimePost.uri="pkg:/images/MutiLive_TimeLine_NOLiving.png"
        m.ItemProgramSelecteLabel.text= ""
        m.focusPost.visible = false
    end if

    updateProgramState()
end function

