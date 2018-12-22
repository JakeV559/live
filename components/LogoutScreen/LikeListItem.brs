'*************************************************************
'** Roku Live - https://github.com/h4091
'** @Application: Live
'** @File: LikeListItem.brs
'** @Author: h4091
'** @Brief description
'** @uses modules
'*************************************************************

sub init()
    m.channelPoster = m.top.findNode("channelPoster")
    m.channelCover = m.top.findNode("channelCover")

    m.channelNameBg = m.top.findNode("channelNameBg")
    m.channelNameHelp = m.top.findNode("channelNameHelp")
    m.channelName = m.top.findNode("channelName")

    m.channelNumBg = m.top.findNode("channelNumBg")
    m.channelNum = m.top.findNode("channelNum")

    m.channelCommonStatusCont = m.top.findNode("channelCommonStatusCont")
    m.channelLiveStatus = m.top.findNode("channelLiveStatus")

    m.channelDesCont = m.top.findNode("channelDesCont")
    m.channelDesHelp = m.top.findNode("channelDesHelp")
    m.channelDes = m.top.findNode("channelDes")

    m.channelPlayingIcon = m.top.findNode("channelPlayingIcon")

    m.channelLevelCont = m.top.findNode("channelLevelCont")
    m.channelLevelHelp = m.top.findNode("channelLevelHelp")
    m.channelLevel = m.top.findNode("channelLevel")

    m.channelNameMaxWidth = 168 'the max width of the channel name.
    m.channelNameHorizSpacing = 24 'the horizontal spacing of the channel name.
    m.channelNameNameOffset = 2 
    m.channelDesMaxWidth = 366 
    m.channelDesSpacing = 12
    m.channelLevelHorizSpacing = 24
end sub

sub likeListChanged()
    channelData = m.top.itemContent

    m.channelPoster.uri = channelData.channelPic

    if (channelData.channelFocused)
        m.channelCover.visible = false
    else
        m.channelCover.visible = true
    end if

    m.channelNameHelp.text = channelData.channelName
    m.channelName.text = channelData.channelName

    if (channelData.channelType = m.global.TYPE_LIVE)
        m.channelNum.text = m.global.NUMERIC_KEY_LIVE
    else
        if (channelData.numericKeys <> invalid)
            m.channelNum.text = channelData.numericKeys
        end if
    end if

    m.channelLiveStatusTranslationX = m.channelPoster.width - m.channelLiveStatus.width - m.channelDes.translation[0]
    m.channelLiveStatus.translation = [m.channelLiveStatusTranslationX, m.channelDes.translation[1]]

    m.channelCommonStatusContTranslationX = m.channelPoster.width - m.channelCommonStatusCont.width - m.channelDes.translation[0]
    m.channelCommonStatusCont.translation = [m.channelCommonStatusContTranslationX, m.channelDes.translation[1]]

    m.channelPlayingIconTranslationX = m.channelPoster.width - m.channelPlayingIcon.width - m.channelDes.translation[0]
    m.channelPlayingIconTranslationY = m.channelPoster.height - m.channelPlayingIcon.height - (m.channelDes.translation[1] / 3 * 4)
    m.channelPlayingIcon.translation = [m.channelPlayingIconTranslationX, m.channelPlayingIconTranslationY]

    if channelData.curProgram <> invalid
        m.channelDesCont.visible = channelData.channelFocused
        if (channelData.curProgram.title <> invalid)
            m.channelDesHelp.text = channelData.curProgram.title
            m.channelDes.text = channelData.curProgram.title

            m.channelDesCont.width = m.channelPoster.width

            channelDesHelpBoundRec = m.channelDesHelp.boundingRect()
            if (channelDesHelpBoundRec.width > m.channelDesMaxWidth)
                m.channelDes.maxWidth = m.channelDesMaxWidth + m.channelDesSpacing
            else
                m.channelDes.maxWidth = channelDesHelpBoundRec.width + m.channelDesSpacing
            end if

            m.channelDesContTranslationY = m.channelPoster.height - m.channelDesCont.height
            m.channelDesCont.translation = [0, m.channelDesContTranslationY]
        end if

        m.channelLevelCont.visible = channelData.channelFocused
        if (channelData.curProgram.contentRating <> invalid) and (channelData.curProgram.contentRating <> "")
            m.channelLevelHelp.text = channelData.curProgram.contentRating
            m.channelLevel.text = channelData.curProgram.contentRating

            channelLevelHelpBoundRec = m.channelLevelHelp.boundingRect()
            m.channelLevelCont.width = channelLevelHelpBoundRec.width + m.channelLevelHorizSpacing
            m.channelLevel.width = channelLevelHelpBoundRec.width

            m.channelLevelTranslationX = m.channelPoster.width - m.channelLevelCont.width - m.channelDes.translation[0]
            m.channelLevelTranslationY = m.channelPoster.height - m.channelDesCont.height + (m.channelDesCont.height - m.channelLevelCont.height) / 2
            m.channelLevelCont.translation = [m.channelLevelTranslationX, m.channelLevelTranslationY]
        else
            m.channelLevelCont.visible = false
        end if
    else
        m.channelLevelCont.visible = false
    end if

    if (channelData.channelType <> invalid)
        if (channelData.channelType = "3") 'Loop play
            m.channelLiveStatus.visible = false
            m.channelCommonStatusCont.visible = false

            m.channelNameBg.visible = true
            m.channelName.visible = true
            m.channelNumBg.visible = true
            m.channelNum.visible = true

            m.channelNumBg.width = m.channelNum.boundingRect().width + m.channelNameHorizSpacing

            channelNameHelpBoundRec = m.channelNameHelp.boundingRect()
            if (channelNameHelpBoundRec.width > m.channelNameMaxWidth)
                m.channelNameBg.width = m.channelNameMaxWidth + m.channelNameHorizSpacing + m.channelNumBg.width
                m.channelName.maxWidth = m.channelNameMaxWidth + m.channelNameNameOffset
            else
                m.channelNameBg.width = channelNameHelpBoundRec.width + m.channelNameHorizSpacing + m.channelNumBg.width
                m.channelName.maxWidth = channelNameHelpBoundRec.width + m.channelNameNameOffset
            end if

            m.channelNumBgTranslationX = m.channelNameBg.width + m.channelNameBg.translation[0] - m.channelNumBg.width
            m.channelNumBg.translation = [m.channelNumBgTranslationX, m.channelNameBg.translation[1]]
            m.channelNumTranslationX = m.channelNumBgTranslationX + m.channelNameHorizSpacing / 2
            m.channelNum.translation = [m.channelNumTranslationX, m.channelName.translation[1]]
        else if (channelData.channelType = "2") 'Live play
            m.channelLiveStatus.visible = true
            m.channelCommonStatusCont.visible = false

            m.channelNameBg.visible = false
            m.channelName.visible = false
            m.channelNumBg.visible = false
            m.channelNum.visible = false
        else
            m.channelLiveStatus.visible = false
            m.channelCommonStatusCont.visible = false

            m.channelNameBg.visible = false
            m.channelName.visible = false
            m.channelNumBg.visible = false
            m.channelNum.visible = false
        end if
    else
        m.channelLiveStatus.visible = false
        m.channelCommonStatusCont.visible = false
    end if
end sub