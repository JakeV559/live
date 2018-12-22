'*************************************************************
'** @Application: Live
'** @File: HttpManager.brs
'** @Author: h4091
'** @Brief HTTP request manager
'** @date 2017-1-15
'** @uses modules
'*************************************************************
'Handles the creation of a URL request
sub makeRequest(handler as Object, headers as Object, url as String, method as String, num as Integer)
    if handler = invalid then return
    if type(handler) <> "roSGNode" then return
    if m.global.DEBUG then print "HttpManager.brs[info-log] - [makeRequest]"
    context = createObject("roSGNode", "Node")
    params = {
        headers: headers,
        uri: url,
        method: method
    }
    context.addFields({
        parameters: params,
        num: num,
        response: {}
    })
    handler.request = { context: context }
end sub