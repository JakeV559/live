'*************************************************************
'** Roku Live - https://github.com/h4091
'** @Application: Live
'** @File: config.brs
'** @Author: h4091
'** @Brief : Load the application config. Only callded once when application starting in main.brs.
'*************************************************************
sub LoadConfig()
    ty = {
        vod : 0,
        live : 1,
        polling : 2,
        cache : 3,
        local : 4,
        anchor_live : 5
    }

    itype = {
        live : 2,
        polling : 3,
        tv : 4
    }

    login_type = {
        login : 0,
        unlogin : 1
    }

    channel_type = {
        live : "2",
        lunbo: "3"
    }

    action = {
        init : "init",
        time : "time",
        play : "play",
        block : "block",
        eblock : "eblock",
        finish : "finish",
        end : "end"
    }

    ipt = {
        zero : 0,
        one : 1,
        two : 2
    }

    joint = {
        no : 0,
        ads_jointed : 1,
        ads : 2
    }

    prl = {
        no_preloading : 0,
        preloading : 1
    }

    netStatus = {
        netRight :"200"
        netReset:"-1"
        netErrorPlayRetryNextChannel:"0"
        netErrorRetry:"1"
        netErrorToast:"2"
    }

    error = {
        playerror_retry_nextchannel:"0",
        neterror_retry :"1",
        neterror_toast :"2"
    }

    PLAYER_ERROR = {
        CANNOT_CONNECT_SERVER : "-1003",
        DATA_CANNOT_PARSED : "0400",
        MEDIA_PLAY_TIMEOUT : "0403",
        UNKNOWN_ERROR : "9999",
        CANNOT_GET_MEDIA : "0402",
        UNSUPPORTED_MEDIA_FORMAT : "0410"
    }

    fields = {
        home_page_url : "",
        home_job_num : 1,

        muti_list_url : "",
        muti_list_num : 2,

        video_schedule_url:"",
        video_schedule_job_num: 3,

        'environment interface
        report_env_url : "",
        report_env_job_num : 4,

        'error interface
        report_er_url : "",
        report_er_job_num : 5,

        'play interface
        report_pl_url : "",
        report_pl_job_num : 6,

        mutilive_replay : 0,
        mutilive_living : 1,
        mutilive_coming_soon : 2,

        'FHD Resolution
        ui_resolution_fhd_x : 1920,
        ui_resolution_fhd_y : 1080,

        'Remote Key
        REMOTE_KEY_BACK : "back",
        REMOTE_KEY_UP : "up",
        REMOTE_KEY_DOWN : "down",
        REMOTE_KEY_LEFT : "left",
        REMOTE_KEY_RIGHT : "right",
        REMOTE_KEY_OK : "OK",
        REMOTE_KEY_REPLAY : "replay",
        REMOTE_KEY_PLAY : "play",
        REMOTE_KEY_STOP : "play",
        REMOTE_KEY_REWIND : "rewind",
        REMOTE_KEY_FASTFORWARD : "fastforward",
        REMOTE_KEY_OPTIONS : "options",

        'Control the exit of the roku live
        EXIT_ROKU_LIVE : false,

        'Setting
        setting : "Settings",
        leeco_roku_setting : "leeco_roku_setting",
        setting_privacy : "setting_privacy",
        setting_use : "setting_use",

        get : "GET",

        'report parameters
        uuid : "",
        apprunid : "",
        installid : "",
        p1 : "p1=2", 'first service code
        p2 : "p2=20", 'second service code
        p3 : "p3=20_tvlive_roku", 'third service code
        os : "Roku", 'Operating System
        ch : "name",
        xh : "19",
        ty : ty,
        login_type : login_type,
        action : action,
        ipt : ipt,
        joint : joint,
        prl : prl,
        itype : itype,
        channel_type: channel_type,

		'encrypt the schedule url
        gls_key : "f934787c4864dd15e984222efa533c04",

        'error
        netStatus:netStatus,
        error:error,

        privateUri:"domain.com/privacy",
        termsUri:"domain.com/Terms",

        TYPE_LIVE : "2",
        TYPE_POLLING : "3",
        TYPE_TV : "4",
        unknown : "unknown",

        NETWORK_ERROR : "0",
        HTTP_ERROR : "-1",
        TIME_OUT : "-2",
        UNKNOWN_ERROR : "-3",
        NO_STREAMS : "-4",
        UNSUPPORTED_FORMAT : "-5",
        PLAYER_ERROR : PLAYER_ERROR,
        NUMERIC_KEY_LIVE : "Live",
        DEBUG : false
    }

    m.global.addFields(fields)
end sub
