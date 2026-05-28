import 'dart:async';
import 'package:flutter/material.dart';
import '../services/youtube_service.dart';
import 'video_player_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<dynamic>> videos;

  List<dynamic> allVideos = [];
  List<dynamic> filteredVideos = [];
  bool isSearching = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    videos = YoutubeService.fetchVideos();
  }

  Future<void> filterSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        isSearching = false;
        videos = YoutubeService.fetchVideos(); // back to default
      });
      return;
    }

    setState(() {
      isSearching = true;
    });

    final results = await YoutubeService.searchVideos(query);

    setState(() {
      filteredVideos = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // SEARCH BAR INSIDE APPBAR
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Search songs...",
            hintStyle: const TextStyle(color: Colors.grey),
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: Colors.white),
          ),

          onChanged: (value) {
            if (_debounce?.isActive ?? false) _debounce!.cancel();

            _debounce = Timer(const Duration(milliseconds: 500), () {
              filterSearch(value);
            });
          },
        ),
      ),

      body: FutureBuilder<List<dynamic>>(
        future: videos,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            allVideos = snapshot.data!;

            final displayList = isSearching ? filteredVideos : allVideos;

            return ListView.builder(
              itemCount: displayList.length,
              itemBuilder: (context, index) {
                final video = displayList[index];
                final title = video['snippet']['title'];
                final thumbnail = video['snippet']['thumbnails']['high']['url'];
                final videoId = video['id']['videoId'];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            VideoPlayerPage(videoId: videoId, title: title),
                      ),
                    );
                  },

                  // CARD DESIGN
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(15),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // THUMBNAIL
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                          child: Image.network(
                            thumbnail,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),

                        // DESCRIPTION (TITLE)
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
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

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
