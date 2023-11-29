import 'package:apollodemo1/pages/album_detail_page.dart';
import 'package:apollodemo1/pages/music_Detail_page.dart';
import 'package:apollodemo1/pages/playlist_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../pages/artist_page.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchQuery = '';
  List<dynamic> searchResults = [];

  Future<void> performSearch() async {
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

      final String searchUrl =
          'https://api.spotify.com/v1/search?q=$searchQuery&type=track,artist,album,playlist';

      final searchResponse = await http.get(
        Uri.parse(searchUrl),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (searchResponse.statusCode == 200) {
        final Map<String, dynamic> searchData =
            json.decode(searchResponse.body);
        setState(() {
          searchResults = searchData['tracks']['items'] +
              searchData['artists']['items'] +
              searchData['albums']['items'] +
              searchData['playlists']['items'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Search',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          TextField(
            cursorColor: Colors.amber,
            style: TextStyle(color: Colors.white),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            onSubmitted: (_) {
              performSearch();
            },
            decoration: InputDecoration(
              hintText: 'Search for songs, artists, albums, playlists',
              hintStyle: TextStyle(color: Colors.white60),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.amber,
              ),
              filled: true, // Add a filled background
              fillColor: Colors.grey.shade900, // Adjust the opacity and color
              border: OutlineInputBorder(
                // Add a border
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none, // Remove the border's side
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final result = searchResults[index];
                final String resultType = result['type'];
                final String resultId = result['id'];
                final String resultName = result['name'];
                final List<dynamic>? images = result['images'];

                IconData icon;
                String imageUrl = '';
                String artistName = '';

                if (resultType == 'track') {
                  icon = Icons.music_note;
                  final List<dynamic>? artists = result['artists'];
                  if (artists != null && artists.isNotEmpty) {
                    artistName = artists[0]['name'];
                  }
                  final Map<String, dynamic>? album = result['album'];
                  if (album != null) {
                    final List<dynamic>? albumImages = album['images'];
                    if (albumImages != null && albumImages.isNotEmpty) {
                      imageUrl = albumImages[0]['url'];
                    }
                  }
                } else if (resultType == 'artist') {
                  icon = Icons.person;
                } else if (resultType == 'album') {
                  icon = Icons.album;
                } else if (resultType == 'playlist') {
                  icon = Icons.playlist_play;
                } else {
                  icon = Icons.error;
                }

                if (images != null && images.isNotEmpty) {
                  imageUrl = images[0]['url'];
                }

                // Check if this is the first item of a new result type, and display a title accordingly
                if (index == 0 ||
                    resultType != searchResults[index - 1]['type']) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _getResultSubtitle(resultType),
                          style: TextStyle(
                            color: Colors.white, // Customize the title color
                            fontSize: 24, // Customize the title font size
                            fontWeight: FontWeight
                                .bold, // Customize the title font weight
                          ),
                        ),
                      ),
                      Divider(
                        // Add a Divider
                        color: Colors.amber, // Customize the divider color
                        thickness: 2.0, // Customize the divider thickness
                      ),
                      ListTile(
                        // Display the search result
                        title: Text(
                          resultName,
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          artistName,
                          style: TextStyle(color: Colors.grey.shade400),
                        ),
                        leading: imageUrl.isNotEmpty
                            ? resultType == 'artist'
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(imageUrl),
                                    radius: 20,
                                  )
                                : Image.network(
                                    imageUrl,
                                    width: 40,
                                    height: 40,
                                  )
                            : Icon(icon),
                        onTap: () {
                          if (resultType == 'artist') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ArtistPage(
                                  artistId: resultId,
                                  artistName: artistName,
                                  artistImage: imageUrl,
                                ),
                              ),
                            );
                          } else if (resultType == 'album') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AlbumDetailPage(
                                  albumId: resultId,
                                ),
                              ),
                            );
                          } else if (resultType == 'playlist') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlaylistDetailPage(
                                  playlistId: resultId,
                                  playlistImageUrl: imageUrl,
                                  playlistName: resultName,
                                  genre: resultType,
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MusicDetailPage(
                                  title: resultName,
                                  description: artistName,
                                  color: Colors.amber,
                                  img: imageUrl,
                                  songUrl: resultId,
                                  playlistId: '',
                                  trackType: '',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  );
                } else {
                  // Display the search result without a title
                  return ListTile(
                    title: Text(
                      resultName,
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      artistName,
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                    leading: imageUrl.isNotEmpty
                        ? resultType == 'artist'
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(imageUrl),
                                radius: 20,
                              )
                            : Image.network(
                                imageUrl,
                                width: 40,
                                height: 40,
                              )
                        : Icon(icon),
                    onTap: () {
                      if (resultType == 'artist') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ArtistPage(
                              artistId: resultId,
                              artistImage: imageUrl,
                              artistName: artistName,
                            ),
                          ),
                        );
                      } else if (resultType == 'album') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AlbumDetailPage(
                              albumId: resultId,
                            ),
                          ),
                        );
                      } else if (resultType == 'playlist') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlaylistDetailPage(
                              playlistId: resultId,
                              playlistImageUrl: imageUrl,
                              playlistName: resultName,
                              genre: resultType,
                            ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MusicDetailPage(
                              title: resultName,
                              description: artistName,
                              color: Colors.amber,
                              img: imageUrl,
                              songUrl: resultId,
                              playlistId: '',
                              trackType: "",
                            ),
                          ),
                        );
                      }
                    },
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }

  String _getResultSubtitle(String resultType) {
    switch (resultType) {
      case 'track':
        return 'Songs';
      case 'artist':
        return 'Artists';
      case 'album':
        return 'Albums';
      case 'playlist':
        return 'Playlists';
      default:
        return 'Other';
    }
  }
}
