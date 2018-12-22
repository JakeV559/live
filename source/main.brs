' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Live - https://github.com/h4091
' **
' **  Author h4091
' ********************************************************************************************************
' ********************************************************************************************************

sub Main(input as Dynamic)
    ' Add deep linking support here. Input is an associative array containing
    ' parameters that the client defines. Examples include "options, contentId, etc."
    ' See guide here: https://sdkdocs.roku.com/display/sdkdoc/External+Control+Guide
    ' For example, if a user clicks on an ad for a movie that your app provides,
    ' you will have mapped that movie to a contentId and you can parse that ID
    ' out from the input parameter here.
    ' Call the service provider API to look up
    ' the content details, or right data from feed for id
    if input <> invalid
        if input.reason <> invalid
            print "Channel launched from ";input.reason
            'do ad stuff here
        end if
        if input.contentId <> invalid and input.mediaType <> invalid
            print "contentId is: " + input.contentId
            if input.mediaType = "channel"
                m.ECPContentId = input.contentId
            else
                print "Unsupported mediaType :" + input.mediaType
            end if
        end if
    end if
    showLiveScreen()
end sub

sub showLiveScreen()
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)
    m.global = screen.getGlobalNode()
    LoadConfig()
    if m.ECPContentId <> invalid
        m.global.addFields({ECPContentId : m.ECPContentId})
    end if
    m.global.observeField("EXIT_ROKU_LIVE", m.port)
    scene = screen.CreateScene("MainScene")
    screen.show()

    while(true)
        msg = wait(0, m.port)
        msgType = type(msg)

        'Exit the roku live.
        if msgType = "roSGNodeEvent"
            if (m.global.EXIT_ROKU_LIVE)
                    screen.close()
            end if
        end if

        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        end if
    end while
end sub
