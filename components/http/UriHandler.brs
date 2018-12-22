'*************************************************************
'** @Application: Live
'** @File: UriHandler.brs
'** @Author: h4091
'** @Brief Sets the execution function for the UriFetcher and tells the UriFetcher to run
'** @date 2017-1-15
'** @uses modules
'*************************************************************
                
sub init()
  info("UriHandler.brs","- [init]")

  ' create the message port
  m.port = createObject("roMessagePort")
  m.top.numBadRequests = 0

  ' setting callbacks for url request and response
  m.top.observeField("request", m.port)

  ' setting the task thread function
  m.top.functionName = "go"
  m.top.control = "RUN"
end sub

' go(): The "Task" function.
'   Has an event loop which calls the appropriate functions for
'   handling requests made by the HeroScreen and responses when requests are finished
' variables:
'   m.jobsById: AA storing HTTP transactions where:
'           key: id of HTTP request
'       val: an AA containing:
'       - key: context
'         val: a node containing request info
'       - key: xfer
'         val: the roUrlTransfer object
sub go()
  info("UriHandler.brs","- [go]")

  ' Holds requests by id
  m.jobsById = {}

    ' UriFetcher event loop
  while true
    msg = wait(0, m.port)
    mt = type(msg)
    info("UriHandler.brs","- [Received event type '" + mt + "']")
    ' If a request was made
    if mt = "roSGNodeEvent"
      if msg.getField()="request"
        if addRequest(msg.getData())
        else
            err("UriHandler.brs","- [Invalid request]")
        end if
        m.top.afterRequest = msg.getData().context.num
      else
        err("UriHandler.brs","- [Error: unrecognized field '" + msg.getField() +"']")
      end if
    ' If a response was received
    else if mt="roUrlEvent"
      processResponse(msg)
    ' Handle unexpected cases
    else
       err("UriHandler.brs","- [Error: unrecognized event type '" + mt +"']")
    end if
  end while
end sub

' addRequest():
'   Makes the HTTP request
' parameters:
'       request: a node containing the request params/context.
' variables:
'   m.jobsById: used to store a history of HTTP requests
' return value:
'   True if request succeeds
'   False if invalid request
function addRequest(request as Object) as Boolean
  info("UriHandler.brs","- [addRequest]")

  if type(request) = "roAssociativeArray"
    context = request.context
    if type(context) = "roSGNode"
      parameters = context.parameters
      if type(parameters)="roAssociativeArray"
        headers = parameters.headers
        method = parameters.method
        uri = parameters.uri
        if isstr(uri) and LEN(strTrim(uri)) > 0
          urlXfer = createObject("roUrlTransfer")
          'urlXfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
          'urlXfer.InitClientCertificates()
          urlXfer.setUrl(uri)
          urlXfer.setPort(m.port)
          ' Add headers to the request
          for each header in headers
            urlXfer.AddHeader(header, headers.lookup(header))
          end for
          ' should transfer more stuff from parameters to urlXfer
          idKey = stri(urlXfer.getIdentity()).trim()
          'Make request based on request method
          ' AsyncGetToString returns false if the request couldn't be issued
          if method = "POST" or method = "PUT" or method = "DELETE"
            urlXfer.setRequest(method)
            ok = urlXfer.AsyncPostFromString("")
          else
            ok = urlXfer.AsyncGetToString()
          end if
          if ok then
            m.jobsById[idKey] = {
              context: request,
              xfer: urlXfer
            }
          else
            err("UriHandler.brs","- [Error: request couldn't be issued]")
          end if
            info("UriHandler.brs","- [Initiating transfer '"+ idkey + "' for URI '" + uri + "' succeeded: " + ok.toStr() +"]")
        else
          err("UriHandler.brs","- [Error: invalid uri: "+ uri +"]")
          m.top.numBadRequests++
        end if
      else
        err("UriHandler.brs","- [Error: parameters is the wrong type: " + type(parameters) +"]")
        return false
      end if
    else
      err("UriHandler.brs","- [Error: context is the wrong type: " + type(context) +"]")
        return false
    end if
  else
    err("UriHandler.brs","- [Error: request is the wrong type: " + type(request) +"]")
    return false
  end if
  info("UriHandler.brs","--------------------------------------------------------------------------")
  return true
end function

' processResponse():
'   Processes the HTTP response.
'   Sets the node's response field with the response info.
' parameters:
'   msg: a roUrlEvent (https://sdkdocs.roku.com/display/sdkdoc/roUrlEvent)
sub processResponse(msg as Object)
  info("UriHandler.brs","- [processResponse]")
  idKey = stri(msg.GetSourceIdentity()).trim()
  job = m.jobsById[idKey]
  if job <> invalid
    context = job.context
    parameters = context.context.parameters
    jobnum = job.context.context.num
    uri = parameters.uri
    info("UriHandler.brs","- [Response for transfer '" + idkey + "' for URI '" + uri + "']")
    result = {
      code:    msg.GetResponseCode(),
      headers: msg.GetResponseHeaders(),
      content: msg.GetString(),
      num:     jobnum
    }
    ' could handle various error codes, retry, etc. here
    m.jobsById.delete(idKey)
    job.context.context.response = result
    if msg.GetResponseCode() = 200
      if result.num = m.global.home_job_num
        parseHomePage(job)
      else if result.num = m.global.muti_list_num
        parseMutiLivePage(job)
      else if result.num = m.global.video_schedule_job_num
        parseVideoSchedule(job)
      ' we do not care the following
      else if result.num = m.global.report_env_job_num
      else if result.num = m.global.report_er_job_num
      else if result.num = m.global.report_pl_job_num
      end if
      m.top.networkError = m.global.netStatus.netRight      'network    right
    else
      err("UriHandler.brs","- [Error: status code was: " + (msg.GetResponseCode()).toStr() +"]")
      m.top.numBadRequests++
      if result.num = m.global.home_job_num
        m.top.networkError = m.global.netStatus.netErrorRetry   'Retry
      else if result.num = m.global.muti_list_num
        m.top.networkError = m.global.netStatus.netErrorToast   'Toast
      else if result.num = m.global.video_schedule_job_num
        m.top.networkError = m.global.netStatus.netErrorPlayRetryNextChannel    'RetryNextChannel
      end if
      m.top.networkError = m.global.netStatus.netReset
    end if
  else
    err("UriHandler.brs","- [Error: event for unknown job " + idkey +"]")
  end if
end sub

function getErrParams(isPlayerError as Boolean, errorCode as String, uuid as String) as Object
    params = {
        uuid: uuid,
        os : m.global.os,
        model : GetModel(),
        osv : GetDeviceVersion(),
        ro : getResolution()
    }
    if isPlayerError
        params.addReplace("et", "pl")
    end if
    params.addReplace("err", errorCode)
end function

' For parsing home page content
sub parseHomePage(job as object)
    info("UriHandler.brs","- [parseHomePage]")
    result = job.context.context.response
    json = ParseJson(result.content)
    if json <> invalid
        status = json.status
        resultStatus = json.resultStatus
        categoryList = json.data
        contentData = CreateObject("roSGNode", "ContentNode")
        if categoryList <> invalid
            for categoryIndex = 0 to categoryList.count()
                category = categoryList[categoryIndex]
                if category <> invalid and category.categoryName <> "Add-ons" 'Add-ons are all pay channel, skip it.
                    categoryItem = CreateObject("roSGNode", "CategoryListItemData")
                    channelList = parseHomePageChannel(categoryItem, categoryIndex, category.categoryId, category.channelList)
                    if channelList <> invalid and channelList.count() > 0
                        categoryItem.channelList = channelList
                        categoryItem.resourceId = category.id
                        categoryItem.categoryId = category.categoryId
                        categoryItem.categoryName = category.categoryName
                        categoryItem.categoryMultiTitle = category.categoryMultiTitle
                        categoryItem.categoryPic = category.categoryPic
                        categoryItem.color = category.color
                        categoryItem.parentCgId = category.parentCgId
                        categoryItem.dataSource = category.dataSource
                        categoryItem.dataType = category.dataType
                        categoryItem.contentManulNum = category.contentManulNum
                        categoryItem.contentTotal = category.contentTotal
                        categoryItem.templateId = category.templateId
                        categoryItem.categoryOnFocusPic = category.categoryOnFocusPic
                        categoryItem.isPersonalizedSort = category.isPersonalizedSort
                        contentData.appendChild(categoryItem)
                    end if
                end if
            end for
        end if

        getSettingNode(contentData)

        m.top.homeContent = contentData
    end if
end sub

function parseHomePageChannel(category as Object, categoryIndex as Integer, categoryId as String, channelList as Object) as Object
    if (channelList = invalid) or (channelList.count() = 0)
        return invalid
    end if

    channelArray = CreateObject("roArray", 0, true)
    for each channel in channelList
        if channel <> invalid and channel.isPay <> "1" 'Skip the pay channel
            channelItem = category.CreateChild("ChannelGridItemData")
            channelArray.push(channelItem)

            channelItem.categoryIndex = categoryIndex
            channelItem.categoryId = categoryId
            channelItem.channelId = channel.channelId
            channelItem.channelName = channel.channelName
            channelItem.channelPic = channel.channelPic
            channelItem.isPay = channel.isPay
            channelItem.channelType = channel.type
            channelItem.splatId = channel.splatId

            'Transform long integer to string
            if channel.cur <> invalid 'For sometimes the interface data error.
                channel.cur.playTimeinMills = channel.cur.playTimeinMills.ToStr()
                channel.cur.endTimeinMills = channel.cur.endTimeinMills.ToStr()
                channelItem.curProgram = channel.cur
            end if
            if channel.next <> invalid 'For sometimes the interface data error.
                channel.next.playTimeinMills = channel.next.playTimeinMills.ToStr()
                channel.next.endTimeinMills = channel.next.endTimeinMills.ToStr()
                channelItem.nextProgram = channel.next
            end if

            channelItem.channelStreams = channel.streams
            channelItem.channelEname = channel.channelEname
            channelItem.signal = channel.signal
            channelItem.channelClass = channel.channelClass
            channelItem.numericKeys = channel.numericKeys
            channelItem.selfCopyRight = channel.selfCopyRight
            channelItem.isArtificialRecommend = channel.isArtificialRecommend
            channelItem.orderNo = channel.orderNo
            channelItem.haveProducts = channel.haveProducts
            channelItem.is3D = channel.is3D
            channelItem.is4K = channel.is4K
            channelItem.childLock = channel.childLock
            channelItem.isTimeShiftingDisabled = channel.isTimeShiftingDisabled
            channelItem.isSupportPushVideo = channel.isSupportPushVideo
            channelItem.isAnchor = channel.isAnchor
        end if
    end for

    return channelArray
end function

function getSettingNode(contentData as Object)
    dataItem = contentData.CreateChild("CategoryListItemData")
    dataItem.categoryId = m.global.leeco_roku_setting
    dataItem.categoryName = m.global.setting
end function

' For parsing mutiLive page content
sub parseMutiLivePage(job as object)
    info("UriHandler.brs","- [parseMutiLivePage]")
    result = job.context.context.response
    json = ParseJson(result.content)
    if json <> invalid
        status = json.status
        resultStatus = json.resultStatus
        if resultStatus <> invalid
            data = json.data
            if data = invalid then return 'For error data, first let it work, then let @chenqingxian fix it.
            dataArray = data
            if dataArray.count()>0
                if dataArray[0].programs<> invalid
'                   programsList =data.programs     'increasement
                    programsList =dataArray[0].programs  'current

                    contentData = CreateObject("roSGNode", "ContentNode")
                    sectionData = contentData.CreateChild("ContentNode")
                    sectionData.title = "Muti Title"

                    for each programItem in programsList
                        dataItem = sectionData.CreateChild("MLRowItemData")

                        dataItem.programsItemID = programItem.id
                        dataItem.playTime = programItem.playTime
                        dataItem.endTime  = programItem.endTime
                        dataItem.playTimeinMills = programItem.playTimeinMills.ToStr()
                        dataItem.endTimeinMills = programItem.endTimeinMills.ToStr()
                        dataItem.duration = programItem.duration
                        dataItem.viewPic = programItem.viewPic
                        dataItem.programType = programItem.programType

                        dataItem.vid = programItem.vid
                        dataItem.categoryID = programItem.category
                        dataItem.aid = programItem.aid
                        dataItem.title = programItem.title
                        dataItem.contentRating = programItem.contentRating
                        dataItem.showLabelFlag = false
                        dataItem.livingStateType = m.global.mutilive_replay

                        dataItem.showMutiLiveFlag = true
                    end for
                    m.top.mutiLiveContent = contentData
                end if
            end if
        end if
    end if
end sub

' For parsing video content
sub parseVideoSchedule(job as object)
    info("UriHandler.brs","- [parseVideoSchedule]")
    result = job.context.context.response
    json = ParseJson(result.content)
    if json <> invalid
        status = json.status
        resultStatus = json.resultStatus
        scheduleURL = json.location
        m.top.videoSchedule = scheduleURL
    end if
end sub