import 'dart:convert';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'album_detail_page.dart';
import 'chat_page.dart';
import 'music_Detail_page.dart';

class ArtistPage extends StatefulWidget {
  final String artistId;
  final String artistName; // Add artist name
  final String artistImage; // Add artist image

  const ArtistPage({
    required this.artistId,
    required this.artistName,
    required this.artistImage,
  });

  @override
  _ArtistPageState createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  late Map<String, dynamic> artistData;
  bool isLoading = true;
  List<dynamic> artistSongs = [];
  List<dynamic> artistAlbums = [];
  late String artistRanking = '';
  late Map<String, dynamic> artistInfo;

  @override
  void initState() {
    super.initState();
    fetchArtistDetails();
    fetchArtistRanking();
  }

  Future<void> fetchArtistRanking() async {
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

      final String artistUrl =
          'https://api.spotify.com/v1/artists/${widget.artistId}';

      final artistResponse = await http.get(
        Uri.parse(artistUrl),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (artistResponse.statusCode == 200) {
        final Map<String, dynamic> artistDetails =
            json.decode(artistResponse.body);
        final double popularity = artistDetails['popularity'];

        setState(() {
          artistRanking = 'Spotify Ranking: $popularity';
        });
      }
    }
  }

  Future<void> fetchArtistDetails() async {
    // Fetch artist details using the artistId
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

      final String artistUrl =
          'https://api.spotify.com/v1/artists/${widget.artistId}';

      final artistResponse = await http.get(
        Uri.parse(artistUrl),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      // Fetch artist's top tracks
      final topTracksUrl =
          'https://api.spotify.com/v1/artists/${widget.artistId}/top-tracks?country=US';

      final topTracksResponse = await http.get(
        Uri.parse(topTracksUrl),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (topTracksResponse.statusCode == 200) {
        final Map<String, dynamic> topTracksData =
            json.decode(topTracksResponse.body);
        artistSongs = topTracksData['tracks'];
      }

      // Fetch artist's albums
      final albumsUrl =
          'https://api.spotify.com/v1/artists/${widget.artistId}/albums';

      final albumsResponse = await http.get(
        Uri.parse(albumsUrl),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (albumsResponse.statusCode == 200) {
        final Map<String, dynamic> albumsData =
            json.decode(albumsResponse.body);
        artistAlbums = albumsData['items'];
      }

      if (artistResponse.statusCode == 200) {
        final Map<String, dynamic> artistDetails =
            json.decode(artistResponse.body);
        setState(() {
          artistData = artistDetails;
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Artist Page'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Artist Image and Name
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                            artistData['images'][0]['url'],
                          ),
                          radius: 50,
                        ),
                        SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              artistData['name'],
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 15),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // Implement follow functionality
                                  },
                                  child: Text('Follow'),
                                ),
                                SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ChatPage(
                                                artistId: widget.artistId,

                                                // Pass the artist's image URL ,
                                              )),
                                    );
                                    // Implement follow functionality
                                  },
                                  child: Text('Chat'),
                                ),
                                IconButton(
                                  icon: Icon(FeatherIcons.moreVertical),
                                  onPressed: () {
                                    // Implement more options functionality
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Pushes the buttons to the right
                      ],
                    ),
                  ),

                  // Top Hits Title
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Top Hits',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),

                  // Artist Songs in a Horizontal Scrollable View
                  Container(
                    height: 200,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: artistSongs.length,
                      separatorBuilder: (context, index) => SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final track = artistSongs[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MusicDetailPage(
                                  title: track['name'],
                                  description: artistData['name'],
                                  color: Colors.amber,
                                  img: track['album']['images'][0]['url'],
                                  songUrl: track['id'],
                                  playlistId: widget.artistId,
                                  trackType: "artist",
                                ),
                              ),
                            );
                          },
                          child: Card(
                            child: Container(
                              width: 150,
                              child: Column(
                                children: [
                                  Image.network(
                                      track['album']['images'][0]['url']),
                                  SizedBox(height: 5),
                                  Expanded(
                                    child: Text(
                                      track['name'],
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Albums Title
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Albums',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),

                  // Artist Albums in a Horizontal Scrollable View
                  Container(
                    height: 200,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: artistAlbums.length,
                      separatorBuilder: (context, index) => SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final album = artistAlbums[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AlbumDetailPage(
                                  albumId: album['id'],
                                ),
                              ),
                            );
                          },
                          child: Card(
                            child: SingleChildScrollView(
                              child: Container(
                                width: 150,
                                child: Column(
                                  children: [
                                    Image.network(album['images'][0]['url']),
                                    SizedBox(height: 5),
                                    Text(album['name']),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // About Section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'About',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                            artistData['images'][0]['url'],
                          ),
                          radius: 60,
                        ),
                        SizedBox(height: 10),
                        Text(
                          artistRanking,
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Related Genres: ${artistData['genres'].join(', ')}', // Display related genres
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Info: ${artistData['name'] ?? 'No information available'}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSongsList() {
    return ListView.builder(
      itemCount: artistSongs.length,
      itemBuilder: (context, index) {
        final track = artistSongs[index];
        return ListTile(
          title: Text(track['name']),
          subtitle: Text(track['album']['name']),
          trailing: IconButton(
            icon: Icon(Icons.play_circle_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MusicDetailPage(
                    title: track['name'],
                    description: artistData['name'],
                    color: Colors.amber,
                    img: artistData['images'][0]['url'],
                    songUrl: track['id'],
                    playlistId: widget.artistId,
                    trackType: "artist",
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAlbumsList() {
    return ListView.builder(
      itemCount: artistAlbums.length,
      itemBuilder: (context, index) {
        final album = artistAlbums[index];
        return ListTile(
          title: Text(album['name']),
          trailing: IconButton(
            icon: Icon(Icons.playlist_play),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AlbumDetailPage(
                    albumId: album['id'],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
