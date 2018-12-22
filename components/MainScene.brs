'*************************************************************
'** Roku Live - https://github.com/h4091
'** @Application: Live
'** @File: MainScene.brs
'** @Author: h4091
'** @Brief application main scene
'** @date 2016-12-14
'** @uses modules
'*************************************************************
function init()
    info("MainScene.brs","- [init]")
    m.playerScreen = m.top.findNode("PlayerScreen")
    m.playerScreen.setFocus(true)
end function

