import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/services.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoId;
  final String? title;

  const VideoPlayerPage({
    super.key,
    required this.videoId,
    this.title,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late YoutubePlayerController _controller;

  bool showControls = true;
  Timer? hideTimer;

  @override
  void initState() {
    super.initState();

    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        forceHD: true,
        enableCaption: false,
        controlsVisibleAtStart: true,
      ),
    );

    startHideTimer();
  }

  void startHideTimer() {
    hideTimer?.cancel();

    hideTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        showControls = false;
      });
    });
  }

  void toggleControls() {
    setState(() {
      showControls = !showControls;
    });

    if (showControls) {
      startHideTimer();
    } else {
      hideTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    hideTimer?.cancel();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
      ),

      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.black,

          appBar: showControls
              ? AppBar(
                  backgroundColor: Colors.black,
                  elevation: 0,
                  leading: const BackButton(color: Colors.white),
                )
              : null,

          body: GestureDetector(
            onTap: toggleControls,

            child: Column(
              children: [

                // VIDEO
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: player,
                    ),
                  ),
                ),

                // DESCRIPTION (hide with controls)
                if (showControls)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Text(
                      widget.title ?? "Playing Video 🎬",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}