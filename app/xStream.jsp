<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="X-UA-Compatible" content="IE=Edge" />
<meta charset=utf-8 />
<link rel="icon" href="resources/images/anim_applogo.gif" type="image/gif" sizes="16x16">
<meta name="csrf-token" content="rlrjMdvDkLPrGPWIiByKS3250Sn6fNJr9FcUwy7v">

<link href="https://unpkg.com/video.js@7.8.3/dist/video-js.min.css" rel="stylesheet">
<script src="https://unpkg.com/video.js@7.8.3/dist/video.min.js"></script>
<script src="https://unpkg.com/videojs-flash@2.0.1/dist/videojs-flash.min.js"></script>
<script src="https://unpkg.com/videojs-contrib-hls@5.12.2/dist/videojs-contrib-hls.min.js"></script>

<style type="text/css">
body{
    background-color:transparent;
}

*,
*::before,
*::after { 
    margin: 0; 
    padding: 0; 
    box-sizing: border-box; 
}

</style>
</head>
<body>
<%
    String url = request.getParameter("url"); 
    if(url == null){
        response.sendRedirect("/error");
    }
%>
<!-- main container -->
<video id="my_video_1" class="video-js vjs-fluid vjs-default-skin" controls autoplay="true" poster="https://app.redstag.live/images/placeholder.png" data-setup='{"controls": false,  "autoplay": true }'>
<source src="<%=url%>" controls="false" type="application/x-mpegURL"> 
</video>
<script>
 var player = videojs('my_video_1'{
    autoplay: true,
        html5: {
            hlsjsConfig: {
                debug: true
            }
        }
      });

	player.play();
</script>

</body>
</html>