'*************************************************************
'** Roku Live - https://github.com/h4091
'** @Application: Live
'** @File: SeekBar.brs
'** @Author: h4091
'** @Brief SeekBar
'** @date 2016-12-19
'** @uses widget
'*************************************************************
sub init()
    initSeekBar()
end sub

sub initSeekBar()
    m.width = m.top.width 'the seekbar's width
    m.height = m.top.height 'the seekbar's height
    m.background = m.top.background 'the seekbar's background color
    m.foreground = m.top.foreground 'the seekbar's foreground color
    m.secondaryground = m.top.secondaryground 'the seekbar's secondaryground color
    m.thumbnail = m.top.thumbnail 'the seekbar slider's thumbnail
    m.maxProgress = m.top.maxProgress 'the seekbar's max progress
    m.progress = m.top.progress 'the seekbar's progress
    m.secondaryProgress = m.top.secondaryProgress 'the seekbar's secondary progress

    m.seekbarBackground = m.top.findNode("SeekBarBackground") 'the seekbar's background color
    m.seekbarSecondaryground = m.top.findNode("SeekBarSecondaryground") 'the seekbar's secondary progress color
    m.seekbarForeground = m.top.findNode("SeekBarForeground") 'the seekbar's progress color
    m.slider = m.top.findNode("Slider") 'the seekbar's slider

    'the slider animation
    m.sliderAnim = m.top.findNode("SliderAnim")
    m.sliderInterp = m.top.findNode("SliderInterp")
    'secondary progress animation
    m.secondaryProgressAnim = m.top.findNode("SecondaryProgressAnim")
    m.secondaryProgressInterp = m.top.findNode("SecondaryProgressInterp")
    'progress animation
    m.progressAnim = m.top.findNode("ProgressAnim")
    m.progressInterp = m.top.findNode("ProgressInterp")
    'fastforward animation
    m.fastforwardAnim = m.top.findNode("FastforwardAnim")
    m.fastforwardInterp = m.top.findNode("FastforwardInterp")
    'rewind animation
    m.rewindAnim = m.top.findNode("RewindAnim")
    m.rewindInterp = m.top.findNode("RewindInterp")
end sub

'Refresh the seekbar's progress
sub refreshProgress()
    scale = getScale()
    m.available = scale * m.width
    m.seekbarForeground.width = m.available
    m.slider.translation = [m.seekbarForeground.width - m.slider.width / 2, 0]
    'the seekbar's animation
'    m.oldWidth = m.seekbarForeground.width
'    m.progressInterp.keyValue = [m.oldWidth, m.available]
'    m.sliderInterp.keyValue = [[m.oldWidth, 0], [m.seekbarForeground.width, 0]]
'    startAnimation()
end sub

function getScale() as Float
    if m.maxProgress > 0
        p = csng(m.progress)
        max = csng(m.maxProgress)
        return p / max
    else
        return 0
    end if
end function

'Start update animation
sub startAnimation()
    if m.sliderAnim.state = "stopped" then m.sliderAnim.control = "start"
    if m.progressAnim.state = "stopped" then m.progressAnim.control = "start"
end sub

'Pause update animation
sub pauseAnimation()
    if m.sliderAnim.state = "running" then m.sliderAnim.control = "pause"
    if m.progressAnim.state = "running" then m.progressAnim.control = "pause"
end sub

'Resume update animation
sub resumeAnimation()
    if m.sliderAnim.state = "paused" then m.sliderAnim.control = "resume"
    if m.progressAnim.state = "paused" then m.progressAnim.control = "resume"
end sub

'Stop update animation
sub stopAnimation()
    if m.sliderAnim.state <> "stopped" then m.sliderAnim.control = "stop"
    if m.progressAnim.state <> "stopped" then m.progressAnim.control = "stop"
end sub

'Set the seekbar's width
sub setWidth()
    m.width = m.top.width
end sub

'Set the seekbar's height
sub setHeight()
    m.height = m.top.height
end sub

'Set the seekbar's background color
sub setBackground()
    m.background = m.top.background
end sub

'Set the seekbar's foreground color
sub setForeground()
    m.foreground = m.top.foreground
end sub

'Set the seekbar's secondaryground color
sub setSecondaryground()
    m.secondaryground = m.top.secondaryground
end sub

' set the seekbar slider's thumbnail
sub setThumbnail()
    m.thumbnail = m.top.thumbnail
end sub

'Set max progress
sub setMaxProgress()
    if m.top.maxProgress < 0 then m.top.maxProgress = 0
    if m.maxProgress <> m.top.maxProgress
        m.maxProgress = m.top.maxProgress
        if m.top.progress > m.maxProgress
            setProgress()
        else
            refreshProgress()
        end if
    end if
end sub

'Return max progress
function getMax() as Integer
    return m.maxProgress
end function

'Set current progresses
sub setProgress()
    if m.top.progress < 0 then m.top.progress = 0
    if m.top.progress > m.top.maxProgress then m.top.progress = m.top.maxProgress
    if m.progress <> m.top.progress
        m.progress = m.top.progress
         refreshProgress()
    end if
end sub

'Return current progress
function getProgress() as Integer
    return m.progress
end function

'TODO Set current secondary progress
sub setSecondaryProgress()
    if m.top.secondaryProgress < 0 then m.top.secondaryProgress = 0
    if m.top.secondaryProgress > m.top.maxProgress then m.top.secondaryProgress = m.top.maxProgress
    if m.secondaryProgress <> m.top.secondaryProgress
        m.secondaryProgress = m.top.secondaryProgress
        ' refreshProgress()
    end if
end sub

'Get current secondary progress
function getSecondaryProgress() as Integer
    return m.secondaryProgress
end function