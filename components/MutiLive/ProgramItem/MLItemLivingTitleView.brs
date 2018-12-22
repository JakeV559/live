'*************************************************************
'** Roku Live - https://github.com/h4091
'** @Application: Live
'** @File: MLItemLivingTitleView.brs
'** @Author: h4091
'** @Brief description
'** @uses modules
'*************************************************************
sub init()
    m.Titlelabel = m.top.findNode("MutilLiveTitleLivingPosterLabel")
    m.Titlelabel.text = "Live"
end sub