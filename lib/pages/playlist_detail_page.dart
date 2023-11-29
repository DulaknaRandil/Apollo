import 'package:apollodemo1/pages/music_Detail_page.dart';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class PlaylistDetailPage extends StatefulWidget {
  final String genre;
  final String playlistId;
  final String playlistName;
  final String playlistImageUrl;

  const PlaylistDetailPage({
    required this.genre,
    required this.playlistId,
    required this.playlistName,
    required this.playlistImageUrl,
  });

  @override
  _PlaylistDetailPageState createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  List<Map<String, dynamic>> playlistTracks = [];
  Color primary = Colors.amber;
  bool playAds = true;

  @override
  void initState() {
    super.initState();
    fetchPlaylistTracks();
  }

  Future<void> fetchPlaylistTracks() async {
    // Fetch playlist tracks using the Spotify API based on playlistId
    final String clientId = '5d01e47fab0844c9b7f5c7ed4cf12718';
    final String clientSecret = '34fa810e6c054630939ea51cd226d2ec';
    final String authUrl = 'https://accounts.spotify.com/api/token';

    // Fetch access token
    final authResponse = await http.post(
      Uri.parse(authUrl),
      headers: {
        'Authorization':
            'Basic ${base64Encode(utf8.encode("$clientId:$clientSecret"))}',
      },
      body: {'grant_type': 'client_credentials'},
    );

    if (authResponse.statusCode == 200) {
      final Map<String, dynamic> authData = json.decode(authResponse.body);
      final accessToken = authData['access_token'];

      // Fetch playlist tracks using accessToken and playlistId
      final playlistUrl =
          'https://api.spotify.com/v1/playlists/${widget.playlistId}/tracks';
      final playlistResponse = await http.get(
        Uri.parse(playlistUrl),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (playlistResponse.statusCode == 200) {
        final Map<String, dynamic> playlistData =
            json.decode(playlistResponse.body);
        final List<dynamic> playlistTracksData = playlistData['items'];

        setState(() {
          playlistTracks = playlistTracksData
              .map<Map<String, dynamic>>(
                (trackItem) => trackItem['track'],
              )
              .toList();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    backgroundColor: Colors.black,
                    expandedHeight: 400.0, // Initially smaller height
                    floating: false,
                    pinned: true, // Keep the app bar and title pinned
                    flexibleSpace: FlexibleSpaceBar(
                      title:
                          innerBoxIsScrolled ? Text(widget.playlistName) : null,
                      background: Image.network(
                        widget.playlistImageUrl,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ];
              },
              body: CustomScrollView(
                slivers: <Widget>[
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final track = playlistTracks[index];
                        final artistName = track['artists'][0]['name'];
                        final trackName = track['name'];
                        final previewUrl = track['id'];
                        final trackImage = track['album']['images'][0]['url'];
                        return ListTile(
                          leading: Image.network(trackImage),
                          title: Text(
                            trackName,
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            artistName,
                            style: TextStyle(color: Colors.grey.shade400),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.play_arrow),
                            color: Colors.white,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => MusicDetailPage(
                                    title: trackName,
                                    description: artistName,
                                    img: trackImage,
                                    songUrl: previewUrl,
                                    color: primary,
                                    playlistId: widget.playlistId,
                                    trackType: "playlist",
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      childCount: playlistTracks.length,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 9.0,
              left: 8.0,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
