'*************************************************************
'** Roku Live - https://github.com/h4091
'** @Application: Live
'** @File: MLItemNormalTitleView.brs
'** @Author: h4091
'** @Brief description
'** @uses modules
'*************************************************************
sub init()
    m.Titlelabel = m.top.findNode("mlTitleLabel")
    m.Titlelabel.text = "Replay"
end sub