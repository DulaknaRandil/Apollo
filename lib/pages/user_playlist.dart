import 'dart:math';

import 'package:apollodemo1/pages/music_Detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserPlaylistsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    // Function to handle creating a new playlist
    Color getRandomGradientColor() {
      final Random random = Random();
      final int red = random.nextInt(256);
      final int green = random.nextInt(256);
      final int blue = random.nextInt(256);

      // Exclude colors that are similar to the icon colors
      if ((red > 200 && green > 200) || (red < 50 && green < 50)) {
        return getRandomGradientColor(); // Recursively try again
      }

      return Color.fromARGB(255, red, green, blue);
    }

    void _createPlaylist() {
      TextEditingController playlistNameController = TextEditingController();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Create Playlist'),
            content: TextField(
              controller: playlistNameController,
              decoration: InputDecoration(
                hintText: 'Playlist Name',
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Create'),
                onPressed: () {
                  // Save the new playlist to Firestore
                  FirebaseFirestore.instance
                      .collection('user_playlists')
                      .doc(user?.uid)
                      .collection('playlists')
                      .add({
                    'name': playlistNameController.text,
                    'songs': [], // Initialize with an empty array of songs
                  }).then((value) {
                    Navigator.of(context).pop(); // Close the dialog
                  });

                  // You may want to handle errors here
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'User Playlists',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _createPlaylist,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('user_playlists')
            .doc(user?.uid)
            .collection('playlists')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            print('Data not available yet');
            return Center(
                child: CircularProgressIndicator(
              color: Colors.amber,
            ));
          }

          final playlists = snapshot.data!.docs;

          if (playlists.isEmpty) {
            // If the document doesn't exist, create it
            print('No playlists found, creating the document');
            FirebaseFirestore.instance
                .collection('user_playlists')
                .doc(user?.uid)
                .set({});

            return Center(
              child: Text('No playlists available.'),
            );
          }

          print('Playlists found, count: ${playlists.length}');

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of boxes per row
              crossAxisSpacing: 8.0, // Spacing between boxes horizontally
              mainAxisSpacing: 8.0, // Spacing between boxes vertically
            ),
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              final playlistName = playlist['name'];

              // Determine the icon based on playlist name
              Widget leadingIcon;
              switch (playlistName.toLowerCase()) {
                case 'happy':
                  leadingIcon =
                      Icon(Icons.tag_faces, color: Colors.amber, size: 50);
                  break;
                case 'sad':
                  leadingIcon = Icon(Icons.sentiment_very_dissatisfied,
                      color: Colors.blue, size: 50);
                  break;
                case 'energetic':
                  leadingIcon =
                      Icon(Icons.flash_on, color: Colors.red, size: 50);
                  break;
                case 'calm':
                  leadingIcon =
                      Icon(Icons.local_florist, color: Colors.green, size: 50);
                  break;
                default:
                  leadingIcon =
                      Icon(Icons.music_note, color: Colors.amber, size: 50);
                  break;
              }

              // Generate a random gradient color for each card, excluding similar colors to the icon
              final Color startColor = getRandomGradientColor();
              final Color endColor = getRandomGradientColor();

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaylistSongsPage(
                        playlistName: playlistName,
                        playlistId: playlist.id,
                        songIds: playlist['songs'],
                        user: user,
                      ),
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 5,
                  margin: EdgeInsets.all(10),
                  color: startColor,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [startColor, endColor],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        leadingIcon,
                        SizedBox(height: 8),
                        Text(
                          playlistName,
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

Color primary = Colors.amber;

class PlaylistSongsPage extends StatelessWidget {
  final String playlistName;
  final String playlistId;
  final List<dynamic> songIds;
  final User? user;

  PlaylistSongsPage({
    required this.playlistName,
    required this.playlistId,
    required this.songIds,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          playlistName,
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (choice) {
              if (choice == 'Rename') {
                _showRenameDialog(context);
              } else if (choice == 'Delete') {
                _showDeleteDialog(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return {'Rename', 'Delete'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchSongsForPlaylist(songIds),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.amber,
              ),
            );
          }

          final songs = snapshot.data!;

          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              final songId = song['songId'];
              final songImage = song['songImage'];
              final songName = song['songName'];
              final artistName = song['artistName'];

              return ListTile(
                leading: Image.network(songImage),
                title: Text(
                  songName,
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                subtitle: Text(
                  artistName,
                  style: TextStyle(fontSize: 20, color: Colors.grey.shade400),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MusicDetailPage(
                              title: songName,
                              description: artistName,
                              img: songImage,
                              songUrl: songId,
                              color: primary,
                              playlistId: playlistId,
                              trackType: "userplaylist",
                            ),
                          ),
                        );
                        // Implement logic to play the song
                      },
                      icon: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _showMoreActionsDialog(context, song);
                      },
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showMoreActionsDialog(BuildContext context, Map<String, dynamic> song) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('More Actions'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete Song'),
                onTap: () {
                  Navigator.of(context).pop(); // Close the dialog
                  _deleteSongFromPlaylist(song);
                },
              ),
              // Add more actions as needed
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteSongFromPlaylist(Map<String, dynamic> song) {
    FirebaseFirestore.instance
        .collection('user_playlists')
        .doc(user?.uid)
        .collection('playlists')
        .doc(playlistId)
        .update({
      'songs': FieldValue.arrayRemove([song['songId']])
    }).then((_) {
      print('Song deleted successfully.');
      // You may want to refresh the page or update the state here
    }).catchError((error) {
      print('Error deleting song: $error');
      // Handle errors here
    });
  }

  Future<List<Map<String, dynamic>>> fetchSongsForPlaylist(
      List<dynamic> songIds) async {
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

      List<Map<String, dynamic>> songs = [];

      for (final songId in songIds) {
        final trackUrl = 'https://api.spotify.com/v1/tracks/$songId';

        final trackResponse = await http.get(
          Uri.parse(trackUrl),
          headers: {'Authorization': 'Bearer $accessToken'},
        );

        if (trackResponse.statusCode == 200) {
          final Map<String, dynamic> trackData =
              json.decode(trackResponse.body);
          final String songImage = trackData['album']['images'][0]['url'];
          final String songName = trackData['name'];
          final String artistName = trackData['artists'][0]['name'];

          songs.add({
            'songId': songId,
            'songImage': songImage,
            'songName': songName,
            'artistName': artistName,
          });
        }
      }

      return songs;
    } else {
      throw Exception('Failed to load songs');
    }
  }

  void _showRenameDialog(BuildContext context) {
    TextEditingController playlistNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rename Playlist'),
          content: TextField(
            controller: playlistNameController,
            decoration: InputDecoration(
              hintText: 'New Playlist Name',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                // Update the playlist name in Firestore
                FirebaseFirestore.instance
                    .collection('user_playlists')
                    .doc(user?.uid)
                    .collection('playlists')
                    .doc(playlistId)
                    .update({'name': playlistNameController.text}).then(
                        (value) {
                  print('Playlist renamed successfully.');
                  Navigator.of(context).pop(); // Close the dialog
                }).catchError((error) {
                  print('Error renaming playlist: $error');
                  // Handle errors here
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Playlist?'),
          content: Text('Are you sure you want to delete this playlist?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                // Delete the playlist from Firestore
                FirebaseFirestore.instance
                    .collection('user_playlists')
                    .doc(user?.uid)
                    .collection('playlists')
                    .doc(playlistId)
                    .delete()
                    .then((value) {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).pop(); // Close the playlist page
                }).catchError((error) {
                  print("Error deleting playlist: $error");
                  // Handle errors here
                });
              },
            ),
          ],
        );
      },
    );
  }
}
