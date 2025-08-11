
<% 
	response.setHeader("Access-Control-Allow-Origin", "*");
    response.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS, DELETE");
    response.setHeader("Access-Control-Max-Age", "3600");
    response.setHeader("Access-Control-Allow-Headers", "x-requested-with");
%>
<html lang="en">
<head>
    <title>Redstag Stream Engine</title>
	<meta charset="utf-8">
    <meta name=viewport content="width=device-width,initial-scale=1,maximum-scale=1,minimum-scale=1,user-scalable=no,minimal-ui">
    <style type="text/css">
        html, body {width:100%;height:100%;margin:auto;overflow: hidden;}
        body {display:flex;}
        #player {flex:auto;}
    </style>
    <script type="text/javascript">
        window.addEventListener('resize',function(){document.getElementById('player').style.height=window.innerHeight+'px';});
    </script>
    <!-- Clappr Builds -->
    <script src="//cdn.jsdelivr.net/npm/@clappr/player@0.4.7/dist/clappr.min.js"></script>
    <script type="text/javascript" src="//cdn.jsdelivr.net/gh/clappr/clappr-level-selector-plugin@latest/dist/level-selector.min.js"></script>
    <!-- P2PEngine -->
    <script src="https://cdn.jsdelivr.net/npm/swarmcloud-hls@latest/dist/p2p-engine.min.js"></script>
    <!-- P2P Clappr Plugin -->
    <script src="https://cdn.jsdelivr.net/npm/swarmcloud-hls@latest/dist/clappr-p2p-plugin.min.js"></script>
</head>

<body>
<div id="player"></div>
<script>
    var p2pConfig = {
        // logLevel: 'debug',
        live: true,        // set to false in VOD mode
        announceLocation: 'hk',        // if using Hongkong tracker
        // announceLocation: 'us',        // if using USA tracker
        // Other p2pConfig options provided by CDNBye
    }
    if (!P2pEngineHls.isMSESupported()) {
        // use ServiceWorker based p2p engine if hls.js is not supported
        new P2pEngineHls(p2pConfig)
    }
 
    var player = new Clappr.Player(
        {
            source: '<%=request.getParameter("url")%>',	// Multi source
			// source: 'https://samplesource/hackfight/playlist.m3u8',	// Single source
            parentId: "#player",
			width: '100%',
			height: '100%',
			mute: false,
            autoPlay: true,
            plugins: [SwarmCloudClapprPlugin],
            playback: {
				playInline: true,
                hlsjsConfig: {
                    maxBufferSize: 0,       // Highly recommended setting in live mode
                    maxBufferLength: 10,     // Highly recommended setting in live mode
                    liveSyncDurationCount: 3,   // Highly recommended setting in live mode
                    // Other hlsjsConfig options provided by hls.js
                    p2pConfig
                }
            },
             mediacontrol: {buttons: "#ff9600"},
             mimeType: "application/x-mpegURL"
        });

    setTimeout(function () {      
        player.play();
    }, 500);
</script>

</body>
</html>