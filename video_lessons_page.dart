import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoLessonsPage extends StatefulWidget {
  @override
  _VideoLessonsPageState createState() => _VideoLessonsPageState();
}

class _VideoLessonsPageState extends State<VideoLessonsPage> {
  final List<Map<String, String>> _videos = [
    {
      'id': 'Lyf92XjGkmU', // YouTube video ID
      'title': 'Imo ishora tili bilan tanishuv | 1-dars'
    },
    {
      'id': 'C8sn79VdUjU',
      'title': 'Sonlarni haqida bilib oling | 2-dars'
    },
    {
      'id': 'YS2EcAyVibw',
      'title': 'Imo ishora tilida tanishuv | 3-dars'
    },
    {
      'id': '36oSpSOSlFY',
      'title': 'Oila haqida | 4-dars'
    },
    {
      'id': 'p5eHzgy6zXM',
      'title': 'Imo-ishora tilida "uy" mavzusi | 5-dars'
    },
    {
      'id': 'zjByAW8760k',
      'title': "Uy ro'zg'or buyumlar haqida | 6-dars"
    },
  ];

  late List<YoutubePlayerController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = _videos.map((video) {
      return YoutubePlayerController(
        initialVideoId: video['id']!,
        flags: YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      );
    }).toList();
  }

  void _togglePlayPause(YoutubePlayerController controller) {
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎥 Video Tutorials')),
      body: ListView.builder(
        itemCount: _videos.length,
        itemBuilder: (context, index) {
          final video = _videos[index];
          final controller = _controllers[index];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                YoutubePlayerBuilder(
                  player: YoutubePlayer(
                    controller: controller,
                    showVideoProgressIndicator: true,
                    width: double.infinity,
                  ),
                  builder: (context, player) {
                    return GestureDetector(
                      onTap: () => _togglePlayPause(controller),
                      child: Container(
                        height: 200, // <-- Video hajmi kichikroq
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: player,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  video['title']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
