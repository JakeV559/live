'*************************************************************
'** Roku Live - https://github.com/h4091
'** @Application: Live
'** @File: PlayerController.brs
'** @Author: h4091
'** @Brief Media player controller
'** @date 2016-12-19
'** @uses modules
'*************************************************************
sub init()
    initFelds()
    initViews()
end sub

sub initViews()
    m.channelNameBg = m.top.findNode("ChannelNameBg")
    m.channelNumberBg = m.top.findNode("ChannelNumberBg")
    m.channelName = m.top.findNode("ChannelName")
    m.channelName.observeField("text","onChannelNameChange")
    m.channelNumber = m.top.findNode("ChannelNumber")
    m.channelNumber.observeField("text","onChannelNumberChange")
    m.bottomPanel = m.top.findNode("BottomPanel")
    m.StartTime = m.top.findNode("StartTime")
    m.title = m.top.findNode("Title")
    m.title.observeField("text","titleTextChange")
    m.ratingLayout = m.top.findNode("Rating_Layout")
    m.rating = m.top.findNode("Rating")
    m.rating.observeField("text","onRatingChange")
    m.ratingPoster = m.top.findNode("RatingBackgroundPoster")
    m.nextStartTime = m.top.findNode("NextStartTime")
    m.nextTitle = m.top.findNode("NextTitle")
    m.seekBar = m.top.findNode("SeekBar")
end sub

sub onChannelNameChange()
    m.channelName.width = 0
    if m.channelName.boundingRect().width > m.channelNameMaxWidth
        m.channelName.width = m.channelNameMaxWidth
    else
        m.channelName.width = m.channelName.boundingRect().width
    end if
    updateChannelNameBg()
end sub

sub onChannelNumberChange()
    m.channelNumber.width = m.channelNumber.boundingRect().width
    updateChannelNameBg()
end sub

sub updateChannelNameBg()
    m.channelNumberBg.width = m.channelNumber.width + m.channelNameHorizSpacing
    m.channelNameBg.width = m.channelName.width + m.channelNameHorizSpacing + m.channelNumberBg.width
    numberTranslationX = m.global.ui_resolution_fhd_x - m.bgOffset - m.channelNumberBg.width
    nameTranslationX = m.global.ui_resolution_fhd_x - m.bgOffset - m.channelNameBg.width
    m.channelNumberBg.translation = [numberTranslationX, m.bgTranslationY]
    m.channelNumber.translation = [numberTranslationX + m.channelNameHorizSpacing / 2, m.channelTranslationY]
    m.channelNameBg.translation = [nameTranslationX, m.bgTranslationY]
    m.channelName.translation = [nameTranslationX + m.channelNameHorizSpacing / 2, m.channelTranslationY]
    m.channelNumberBg.visible = true
    m.channelNameBg.visible = true
end sub

sub onRatingChange()
    if m.rating.text.trim().len() > 0
        m.ratingPoster.width = 2 * m.ratingPaddingX + m.rating.boundingRect().width
        m.rating.translation = [m.ratingPaddingX, m.ratingPaddingY]
        m.rating.visible = true
        m.ratingPoster.visible = true
    else
        m.rating.visible = false
        m.ratingPoster.visible = false
    end if
end sub

sub titleTextChange(event as Object)
    text = event.getData()
    if text <> invalid
        m.title.width = 0
        if m.title.boundingRect().width > m.titleMaxWidth
            m.title.width = m.titleMaxWidth
            m.ratingLayout.translation = [m.title.width + m.ratingMarginX, m.ratingTranslationY]
        else
            m.title.width = m.title.boundingRect().width
            m.ratingLayout.translation = [m.title.boundingRect().width + m.ratingMarginX, m.ratingTranslationY]
        end if
    end if
end sub

sub initFelds()
    m.channelTranslationY = 45 'the channel name and number translation y-axis
    m.channelNameMaxWidth = 372 'the channel name max width
    m.channelNameHorizSpacing = 40 'the space between channel name and number
    m.bgTranslationY = 33 'the channel name bg translation y-axis
    m.bgOffset = 78 'the channel name and number offset
    'the translation x-axis and y-axis when title bounding width > 600
    m.ratingTranslationY = 249 'rating layout translation y
    m.ratingMarginX = 108 'rating layout margin x
    m.ratingPaddingX = 12 'rating layout padding x
    m.ratingPaddingY = 3 'rating layout padding y
    m.titleMaxWidth = 600 'the current title max width
end sub

sub setDuration()
    m.seekBar.maxProgress = m.top.duration
end sub

sub seekTo()
    m.seekBar.progress = m.top.position
end sub
