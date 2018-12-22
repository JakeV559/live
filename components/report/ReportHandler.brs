'*************************************************************
'** @Application: Live
'** @File: ReportHandler.brs
'** @Author: h4091
'** @Brief Data report handler
'** @date 2017-1-16
'** @uses modules
'*************************************************************
sub init()
    info("ReportHandler.brs","- [init]")
    initRepoHandler()
    m.port = createObject("roMessagePort")
    m.top.observeField("report", m.port)
    m.top.functionName = "listening"
    m.top.control = "RUN"
end sub

sub initRepoHandler()
    m.repoHandler = CreateObject("roSGNode", "UriHandler")
    m.repoHandler.observeField("afterRequest","uriRequestCallback")
end sub

sub uriRequestCallback(event as Object)
    jobNum = event.getData()
    if isReportJob(jobNum) then m.top.afterUriRequest = jobNum
end sub

function isReportJob(num as Integer) as Boolean
    if num = m.global.report_env_job_num
        return true
    else if num = m.global.report_er_job_num
        return true
    else if num = m.global.report_pl_job_num
        return true
    else
        return false
    end if
end function

sub listening()
    info("ReportHandler.brs","- [listening]")

    ' UriFetcher event loop
    while true
        msg = wait(0, m.port)
        mt = type(msg)
        info("ReportHandler.brs","- [Received report event type '" + mt + "']")

        if mt = "roSGNodeEvent"
            if msg.getField()="report"
                if addReport(msg.getData()) <> true then err("ReportHandler.brs","- [Invalid report]")
            else
                err("ReportHandler.brs","- [Error: unrecognized field '" + msg.getField() +"']")
            end if
        else
           err("ReportHandler.brs","- [Error: unrecognized report event type '" + mt +"']")
        end if
    end while
end sub

function addReport(report as Object) as Boolean
    info("ReportHandler.brs","- [addReport]")
    if type(report) = "roAssociativeArray"
        context = report.context
        if type(context) = "roSGNode"
            method = context.method
            parameters = context.parameters
            if type(parameters) = "roAssociativeArray"
                if method = m.top.env
                    reportEnvironment(parameters)
                else if method = m.top.er
                    reportError(parameters)
                else if method = m.top.pl
                    reportPlay(parameters)
                else
                    err("ReportHandler.brs","- [Error: unsupported method :" + method + "]")
                end if
             else
                err("ReportHandler.brs","- [Error: parameters is the wrong type: " + type(parameters) +"]")
                return false
            end if
        else
            err("ReportHandler.brs","- [Error: context is the wrong type: " + type(context) +"]")
            return false
        end if
    else
        err("ReportHandler.brs","- [Error: report is the wrong type: " + type(report) +"]")
        return false
    end if
    return true
end function

sub reportEnvironment(params as Object)'uuid as String)
    url = getBaseUrl(m.global.report_env_url, params)
    url += "&stime=" + nowAsMilliseconds()
    info("ReportHandler.brs","- [Report environment data to " + url +"]")
    makeRequest(m.repoHandler, {}, url, m.global.get, m.global.report_env_job_num)
end sub

sub reportError(params as Object)
    url = getBaseUrl(m.global.report_er_url, params)
    url += "&stime=" + nowAsMilliseconds()
    info("ReportHandler.brs","- [Report error data to " + url +"]")
    makeRequest(m.repoHandler, {}, url, m.global.get, m.global.report_er_job_num)
end sub

 sub reportPlay(params as Object)
    url = getBaseUrl(m.global.report_pl_url, params)
    url += "&pv=" + getCustomAppVersion()
    url += "&ipt=" + m.global.ipt.zero.toStr()
    url += "&owner=1"
    url += "&stime=" + nowAsMilliseconds()
    info("ReportHandler.brs","- [Report play data to " + url +"]")
    makeRequest(m.repoHandler, {}, url, m.global.get, m.global.report_pl_job_num)
end sub

function getBaseUrl(url as String, params as Object) as String
    macAddress = getMac().replace(":","")  'mac address
    url += "&app=" + getCustomAppVersion()
    url += "&app_name=" + getTitle()
    url += "&apprunid=" + m.global.apprunid
    url += "&nt=" + getNetworkType()    'network type
    url += "&" + m.global.p1
    url += "&" + m.global.p2
    url += "&" + m.global.p3
    url += "&r=" + getRandom(12)
    url += "&auid=" + GetDeviceESN()
    url += "&install_id=" + m.global.installid
    if isWifi() 'wifi network
        url += "&wmac=" + macAddress
    else if isWired() 'wired network
        url += "&mac=" + macAddress
    end if
    url += "&serialno=" + GetDeviceESN()
    if params <> invalid AND params.count() > 0
        for each key in params
            url = url + "&" + key.toStr() + "=" + params.lookup(key).toStr()
        end for
    end if
    return url
end function