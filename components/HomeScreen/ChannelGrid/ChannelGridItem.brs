'*************************************************************
'** Roku Live - https://github.com/h4091
'** @Application: Live
'** @File: ChannelGridItem.brs
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

    m.channelNameRecMaxWidth = 387
    m.channelNameComMaxWidth = 168
    m.channelNameHorizSpacing = 24
    m.channelNameNameOffset = 2
    m.channelDesRecMaxWidth = 836
    m.channelDesComMaxWidth = 366
    m.channelDesSpacing = 12
    m.channelLevelHorizSpacing = 24
end sub

sub channelContentChanged()
    channelData = m.top.itemContent

    m.channelPoster.width = channelData.channelPosterWidth
    m.channelPoster.height = channelData.channelPosterHeight
    m.channelPoster.uri = channelData.channelPic

    m.channelCover.width = channelData.channelPosterWidth
    m.channelCover.height = channelData.channelPosterHeight

    if (channelData.channelFocused)
        m.channelCover.visible = false
        'm.channelName.repeatCount = -1
    else
        m.channelCover.visible = true
        'm.channelName.repeatCount = 0
    end if

    m.channelNameHelp.text = channelData.channelName
    m.channelName.text = channelData.channelName

    m.channelNum.text = channelData.numericKeys

    m.channelLiveStatusTranslationX = channelData.channelPosterWidth - m.channelLiveStatus.width - m.channelDes.translation[0]
    m.channelLiveStatus.translation = [m.channelLiveStatusTranslationX, m.channelDes.translation[1]]

    m.channelCommonStatusContTranslationX = channelData.channelPosterWidth - m.channelCommonStatusCont.width - m.channelDes.translation[0]
    m.channelCommonStatusCont.translation = [m.channelCommonStatusContTranslationX, m.channelDes.translation[1]]

    m.channelPlayingIconTranslationX = channelData.channelPosterWidth - m.channelPlayingIcon.width - m.channelDes.translation[0]
    m.channelPlayingIconTranslationY = channelData.channelPosterHeight - m.channelPlayingIcon.height - (m.channelDes.translation[1] / 3 * 4)
    m.channelPlayingIcon.translation = [m.channelPlayingIconTranslationX, m.channelPlayingIconTranslationY]

    if (channelData.curProgram <> invalid)
        m.channelDesCont.visible = channelData.channelFocused
        if (channelData.curProgram.title <> invalid)
            m.channelDesHelp.text = channelData.curProgram.title
            m.channelDes.text = channelData.curProgram.title

            m.channelDesCont.width = channelData.channelPosterWidth

            if (channelData.channelRecommend) 'recommend channel
                channelDesMaxWidth = m.channelDesRecMaxWidth
            else 'common channel
                channelDesMaxWidth = m.channelDesComMaxWidth
            end if

            channelDesHelpBoundRec = m.channelDesHelp.boundingRect()
            if (channelDesHelpBoundRec.width > channelDesMaxWidth)
                m.channelDes.maxWidth = channelDesMaxWidth + m.channelDesSpacing
            else
                m.channelDes.maxWidth = channelDesHelpBoundRec.width + m.channelDesSpacing
            end if

            m.channelDesContTranslationY = channelData.channelPosterHeight - m.channelDesCont.height
            m.channelDesCont.translation = [0, m.channelDesContTranslationY]
        end if

        m.channelLevelCont.visible = channelData.channelFocused
        if (channelData.curProgram.contentRating <> invalid) and (channelData.curProgram.contentRating <> "")
            m.channelLevelHelp.text = channelData.curProgram.contentRating
            m.channelLevel.text = channelData.curProgram.contentRating

            channelLevelHelpBoundRec = m.channelLevelHelp.boundingRect()
            m.channelLevelCont.width = channelLevelHelpBoundRec.width + m.channelLevelHorizSpacing
            m.channelLevel.width = channelLevelHelpBoundRec.width

            m.channelLevelTranslationX = channelData.channelPosterWidth - m.channelLevelCont.width - m.channelDes.translation[0]
            m.channelLevelTranslationY = channelData.channelPosterHeight - m.channelDesCont.height + (m.channelDesCont.height - m.channelLevelCont.height) / 2
            m.channelLevelCont.translation = [m.channelLevelTranslationX, m.channelLevelTranslationY]
        else
            m.channelLevelCont.visible = false
        end if
    else
        m.channelLevelCont.visible = false
    end if

    if (channelData.channelType <> invalid)
        if (channelData.channelType = m.global.TYPE_POLLING)
            m.channelLiveStatus.visible = false
            m.channelCommonStatusCont.visible = false

            m.channelNameBg.visible = true
            m.channelName.visible = true
            m.channelNumBg.visible = true
            m.channelNum.visible = true

            m.channelNumBg.width = m.channelNum.boundingRect().width + m.channelNameHorizSpacing

            channelNameHelpBoundRec = m.channelNameHelp.boundingRect()

            if (channelData.channelRecommend) 'recommend channel
                channelNameMaxWidth = m.channelNameRecMaxWidth
            else 'common channel
                channelNameMaxWidth = m.channelNameComMaxWidth
            end if

            if (channelNameHelpBoundRec.width > channelNameMaxWidth)
                m.channelNameBg.width = channelNameMaxWidth + m.channelNameHorizSpacing + m.channelNumBg.width
                m.channelName.maxWidth = channelNameMaxWidth + m.channelNameNameOffset
            else
                m.channelNameBg.width = channelNameHelpBoundRec.width + m.channelNameHorizSpacing + m.channelNumBg.width
                m.channelName.maxWidth = channelNameHelpBoundRec.width + m.channelNameNameOffset
            end if

            m.channelNumBgTranslationX = m.channelNameBg.width + m.channelNameBg.translation[0] - m.channelNumBg.width
            m.channelNumBg.translation = [m.channelNumBgTranslationX, m.channelNameBg.translation[1]]
            m.channelNumTranslationX = m.channelNumBgTranslationX + m.channelNameHorizSpacing / 2
            m.channelNum.translation = [m.channelNumTranslationX, m.channelName.translation[1]]
        else if (channelData.channelType = m.global.TYPE_LIVE)
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