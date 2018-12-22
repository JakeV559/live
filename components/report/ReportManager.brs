'*************************************************************
'** Roku Live - https://github.com/h4091
'** @Application: Live
'** @File: ReportManager.brs
'** @Author: h4091
'** @Brief description
'** @date 2017-1-16
'** @uses modules
'*************************************************************
sub makeEnvReport(params as Object)
    makeReport(getReportHandler().env, params)
end sub

sub makeErrorReport(params as Object)
    makeReport(getReportHandler().er, params)
end sub

sub makePlayReport(params as Object)
    makeReport(getReportHandler().pl, params)
end sub

sub makeReport(method as String, params as Object)
    context = createObject("roSGNode", "Node")
    context.addFields({
        parameters: params,
        method : method
    })
    getReportHandler().report = {context : context}
end sub

function getReportHandler() as Object
    this = m.reportHandler
    if this = invalid
        this = CreateObject("roSGNode","ReportHandler")
        m.reportHandler = this
        m.reportHandler.observeField("afterUriRequest","afterUriRequestCallback")
    end if
    return this
end function

sub afterUriRequestCallback(event as Object)
    m.mAfterRequest(event)
end sub

sub setAfterUriRequestCallback(obj as Object)
    m.mAfterRequest = obj
end sub