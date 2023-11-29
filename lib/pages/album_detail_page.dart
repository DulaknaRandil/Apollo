import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'music_Detail_page.dart';

class AlbumDetailPage extends StatefulWidget {
  final String albumId;

  const AlbumDetailPage({required this.albumId});

  @override
  _AlbumDetailPageState createState() => _AlbumDetailPageState();
}

class _AlbumDetailPageState extends State<AlbumDetailPage> {
  late Map<String, dynamic> albumData;
  List<dynamic> albumSongs = []; // Placeholder for album songs
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAlbumDetails();
    fetchAlbumSongs();
  }

  Future<void> fetchAlbumDetails() async {
    final String clientId = '5d01e47fab0844c9b7f5c7ed4cf12718';
    final String clientSecret = '34fa810e6c054630939ea51cd226d2ec';
    final String authUrl = 'https://accounts.spotify.com/api/token';

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
      final String accessToken = authData['access_token'];

      final albumUrl = 'https://api.spotify.com/v1/albums/${widget.albumId}';

      final albumResponse = await http.get(
        Uri.parse(albumUrl),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (albumResponse.statusCode == 200) {
        final Map<String, dynamic> albumDetails =
            json.decode(albumResponse.body);
        setState(() {
          albumData = albumDetails;
          isLoading = false;
        });
      }
    }
  }

  Future<void> fetchAlbumSongs() async {
    final String clientId = '5d01e47fab0844c9b7f5c7ed4cf12718';
    final String clientSecret = '34fa810e6c054630939ea51cd226d2ec';
    final String authUrl = 'https://accounts.spotify.com/api/token';

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
      final String accessToken = authData['access_token'];

      final albumSongsUrl =
          'https://api.spotify.com/v1/albums/${widget.albumId}/tracks';

      final songsResponse = await http.get(
        Uri.parse(albumSongsUrl),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (songsResponse.statusCode == 200) {
        final List<dynamic> songsData =
            json.decode(songsResponse.body)['items'];
        setState(() {
          albumSongs = songsData;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Album Detail Page'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Display album details (e.g., name, release date)
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        albumData['images'][0]
                            ['url'], // Assuming first image is the album art
                        height: 200, // Set the desired height for the album art
                      ),
                      SizedBox(height: 16),
                      Text(
                        albumData['name'],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Release Date: ${albumData['release_date']}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // Display list of songs
                _buildSongsList(),
              ],
            ),
    );
  }

  Widget _buildSongsList() {
    return Expanded(
      child: ListView.builder(
        itemCount: albumSongs.length,
        itemBuilder: (context, index) {
          final song = albumSongs[index];
          final albumArtworkUrl = albumData['images'][0]['url'];
          return ListTile(
            leading: Image.network(
              albumArtworkUrl,
              width: 48, // Set the desired width for the song artwork
              height: 48, // Set the desired height for the song artwork
            ),
            title: Text(song['name']),
            trailing: IconButton(
              icon: Icon(Icons.play_circle_outline),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MusicDetailPage(
                      title: song['name'],
                      description: albumData['name'],
                      color: Colors.amber,
                      img: albumData['images'][0]['url'],
                      songUrl: song['id'],
                      trackType: "album",
                      playlistId: widget.albumId,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
