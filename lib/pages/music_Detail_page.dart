import 'dart:convert';
import 'dart:io';

import 'package:antdesign_icons/antdesign_icons.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

class MusicDetailPage extends StatefulWidget {
  String title;
  String description;
  Color color;
  String img;
  String songUrl;
  String playlistId;
  String trackType;
  MusicDetailPage({
    Key? key,
    required this.title,
    required this.description,
    required this.color,
    required this.img,
    required this.songUrl,
    required this.playlistId,
    required this.trackType,
  }) : super(key: key);

  @override
  State<MusicDetailPage> createState() => _MusicDetailPageState();
}

class _MusicDetailPageState extends State<MusicDetailPage> {
  late String artistName = '';
  late String albumArtUrl = '';
  List<String> playlists = ['Happy', 'Sad', 'Energetic', 'Calm'];
  bool enableAds = true; // Set to true to enable ads by default

  List<Map<String, dynamic>> playlistTracks = [];
  int currentTrackIndex = 0;
  User? user = FirebaseAuth.instance.currentUser;
  Color primary = Colors.amber;
  final String clientId = '5d01e47fab0844c9b7f5c7ed4cf12718';
  final String clientSecret = '34fa810e6c054630939ea51cd226d2ec';

  final String authUrl = 'https://accounts.spotify.com/api/token';

  late AudioPlayer _audioPlayer;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  String? selectedPlaylist;

  String formatTime(int seconds) {
    return '${Duration(seconds: seconds)}'.split('.')[0].padLeft(8, '0');
  }

  InterstitialAd? _interstitialAd;

// TODO: replace this test ad unit with your own ad unit.
  final adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/8691691433';

  /// Loads an interstitial ad.
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          _interstitialAd = ad;
          showInterstitialAd();
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

// Method to show the loaded interstitial ad
  void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      debugPrint('InterstitialAd is not loaded yet.');
    }
  }

// Method to dispose of the interstitial ad
  void disposeInterstitialAd() {
    _interstitialAd?.dispose();
  }

  Future<List<Map<String, dynamic>>> fetchTracksByType(
      String trackId, String trackType) async {
    print(trackId);
    print(trackType);
    String apiUrl = '';
    switch (trackType) {
      case 'album':
        apiUrl = 'https://api.spotify.com/v1/albums/$trackId/tracks';
        break;
      case 'artist':
        apiUrl =
            'https://api.spotify.com/v1/artists/$trackId/top-tracks?country=US';
        break;
      case 'playlist':
        apiUrl = 'https://api.spotify.com/v1/playlists/$trackId/tracks';
        break;
      case 'userplaylist':
        print(trackId);
        // Fetch playlistId from Firestore
        final playlistSnapshot = await FirebaseFirestore.instance
            .collection('user_playlists')
            .doc(user?.uid)
            .collection('playlists')
            .doc(trackId)
            .get();

        if (playlistSnapshot.exists) {
          final List<dynamic> songIds = playlistSnapshot['songs'];

          // Obtain the access token
          final authResponse = await http.post(
            Uri.parse(authUrl),
            headers: {
              'Authorization':
                  'Basic ${base64Encode(utf8.encode("$clientId:$clientSecret"))}',
            },
            body: {'grant_type': 'client_credentials'},
          );

          if (authResponse.statusCode == 200) {
            final Map<String, dynamic> authData =
                json.decode(authResponse.body);
            final String accessToken = authData['access_token'];

            // Fetch song details from Spotify API for each songId
            final List<Map<String, dynamic>> spotifyTracks = [];
            for (var songId in songIds) {
              final songResponse = await http.get(
                Uri.parse('https://api.spotify.com/v1/tracks/$songId'),
                headers: {'Authorization': 'Bearer $accessToken'},
              );

              if (songResponse.statusCode == 200) {
                final Map<String, dynamic> songData =
                    json.decode(songResponse.body);
                final Map<String, dynamic> trackData = {
                  'id': songData['id'],
                  'name': songData['name'],
                  'artist': songData['artists'][0]['name'],
                  'image': songData['album']['images'][0]['url'],
                };
                spotifyTracks.add(trackData);
              }
            }

            // Now, spotifyTracks contains the mapped data for each song in the playlist
            return spotifyTracks;
          }
        } else {
          // Playlist not found in Firestore
          return [];
        }
        break;

      default:
        return [];
    }
    print(apiUrl);
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

      final trackResponse = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (trackResponse.statusCode == 200) {
        final List<Map<String, dynamic>> tracks = [];
        final Map<String, dynamic> trackData = json.decode(trackResponse.body);
        print("Track data:");
        print(trackData);
        try {
          if (trackType == 'artist') {
            for (var item in trackData['tracks']) {
              final Map<String, dynamic> trackData = {
                'id': item['id'],
                'name': item['name'],
                'artist': item['artists'][0]['name'],
                'image': item['album']['images'][0]['url'],
              };
              tracks.add(trackData);
              print(item['name']);
              print("Selected tracks:");
              print(tracks);
            }
          } else if (trackType == 'album') {
            for (var item in trackData['items']) {
              final Map<String, dynamic> trackData = {
                'id': item['id'],
                'name': item['name'],
                'artist': item['artists'][0]['name'],
                'image': widget.img,
              };
              tracks.add(trackData);
              print(item['name']);
              print("Selected tracks:");
              print(tracks);
            }
          } else if (trackType == 'playlist') {
            for (var item in trackData['items']) {
              final Map<String, dynamic> trackData = {
                'id': item['track']['id'],
                'name': item['track']['name'],
                'artist': item['track']['artists'][0]['name'],
                'image': item['track']['album']['images'][0]['url'],
              };
              tracks.add(trackData);
              print(item['track']['name']);
              print("Selected tracks:");
              print(tracks);
            }
          } else {
            print("Error");
          }
        } catch (e) {
          print('error code :' + '$e');
        }

        return tracks;
      }
    }

    return [];
  }

  Future<void> playNextInPlaylist(List<Map<String, dynamic>> tracks) async {
    final currentIndex =
        tracks.indexWhere((track) => track['id'] == widget.songUrl);

    if (currentIndex != -1 && currentIndex < tracks.length - 1) {
      final nextTrack = tracks[currentIndex + 1];
      final nextTrackId = nextTrack['id'];
      final nextSongUrl =
          'https://api.spotify.com/v1/tracks/$nextTrackId'; // Add the Spotify API base URL
      final nextArtistName = nextTrack['artist'];
      final nextSongName = nextTrack['name'];
      final nextImageUrl = nextTrack['image'];

      try {
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

          final trackResponse = await http.get(
            Uri.parse(nextSongUrl),
            headers: {'Authorization': 'Bearer $accessToken'},
          );

          if (trackResponse.statusCode == 200) {
            final Map<String, dynamic> trackData =
                json.decode(trackResponse.body);
            final String audioUrl = trackData['preview_url'];

            if (audioUrl != null && audioUrl.isNotEmpty) {
              await _audioPlayer.setAudioSource(AudioSource.uri(
                Uri.parse(audioUrl),
                tag: MediaItem(
                  id: nextTrackId, // Use nextTrackId as the ID for MediaItem
                  artist: nextArtistName,
                  title: nextSongName,
                  artUri: Uri.parse(nextImageUrl),
                ),
              ));
              await _audioPlayer.play();

              // Update widget.songUrl
              setState(() {
                widget.songUrl = nextTrackId;
                widget.title = nextSongName;
                widget.img = nextImageUrl;
                widget.description = nextArtistName;
              });

              // Update currentIndex after changing the song
              final updatedIndex =
                  tracks.indexWhere((track) => track['id'] == nextSongUrl);
              if (updatedIndex != -1) {
                currentTrackIndex = updatedIndex;
              }

              isPlaying = false;
              setState(() {
                position = Duration.zero;
              });

              if (enableAds) {
                loadInterstitialAd();
              }
            } else {
              print('Error: Preview URL for next track is null or empty');
            }
          } else {
            print(
                'Error fetching next track details: ${trackResponse.statusCode}');
          }
        } else {
          print('Error authenticating: ${authResponse.statusCode}');
        }
      } catch (e) {
        print('Error loading next song: $e');
      }
    } else {
      // Check if there is a next song available before seeking forward
      //if (currentIndex != -1) {
      // If there's no next song, seek forward by 5 seconds
      final newPosition = position + Duration(seconds: 5);
      await _audioPlayer.seek(newPosition);
      // }
    }
  }

  Future<void> playPreviousInPlaylist(List<Map<String, dynamic>> tracks) async {
    final currentIndex =
        tracks.indexWhere((track) => track['id'] == widget.songUrl);

    if (currentIndex > 0) {
      final previousTrack = tracks[currentIndex - 1];
      final previousTrackId = previousTrack['id'];
      final previousSongUrl =
          'https://api.spotify.com/v1/tracks/$previousTrackId';
      final previousArtistName = previousTrack['artist'];
      final previousSongName = previousTrack['name'];
      final previousImageUrl = previousTrack['image'];

      try {
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

          final trackResponse = await http.get(
            Uri.parse(previousSongUrl),
            headers: {'Authorization': 'Bearer $accessToken'},
          );

          if (trackResponse.statusCode == 200) {
            final Map<String, dynamic> trackData =
                json.decode(trackResponse.body);
            final String audioUrl = trackData['preview_url'];

            if (audioUrl != null && audioUrl.isNotEmpty) {
              await _audioPlayer.setAudioSource(AudioSource.uri(
                Uri.parse(audioUrl),
                tag: MediaItem(
                  id: previousTrackId,
                  artist: previousArtistName,
                  title: previousSongName,
                  artUri: Uri.parse(previousImageUrl),
                ),
              ));
              await _audioPlayer.play();

              // Update widget.songUrl
              setState(() {
                widget.songUrl = previousTrackId;
                widget.title = previousSongName;
                widget.img = previousImageUrl;
                widget.description = previousArtistName;
              });

              // Update currentIndex after changing the song
              final updatedIndex =
                  tracks.indexWhere((track) => track['id'] == previousSongUrl);
              if (updatedIndex != -1) {
                currentTrackIndex = updatedIndex;
              }

              isPlaying = false;
              setState(() {
                position = Duration.zero;
              });

              if (enableAds) {
                loadInterstitialAd();
              }
            } else {
              print('Error: Preview URL for previous track is null or empty');
            }
          } else {
            print(
                'Error fetching previous track details: ${trackResponse.statusCode}');
          }
        } else {
          print('Error authenticating: ${authResponse.statusCode}');
        }
      } catch (e) {
        print('Error loading previous song: $e');
      }
    } else {
      // Check if there is a previous song available before seeking backward
      // if (currentIndex != -1) {
      // If there's no previous song, seek backward by 5 seconds
      final newPosition = position - Duration(seconds: 5);
      await _audioPlayer.seek(newPosition);
      //  }
    }
  }

  Future<void> playSong() async {
    final String trackUrl =
        'https://api.spotify.com/v1/tracks/${widget.songUrl}';
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

      final trackResponse = await http.get(
        Uri.parse(trackUrl),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (trackResponse.statusCode == 200) {
        final Map<String, dynamic> trackData = json.decode(trackResponse.body);
        final String audioUrl = trackData['preview_url'];

        try {
          await _audioPlayer.setAudioSource(AudioSource.uri(
            Uri.parse(audioUrl),
            tag: MediaItem(
              id: audioUrl,
              artist: artistName,
              title: widget.title,
              artUri: Uri.parse(widget.img),
            ),
          ));
          await _audioPlayer.play();

          isPlaying = false;
          setState(() {
            position = Duration.zero;
          });

          if (enableAds) {
            loadInterstitialAd();
          }
          playNextInPlaylist(playlistTracks);
        } catch (e) {
          print('Error loading song: $e');
        }
      }
    }
  }

  Future<void> fetchSongDetails() async {
    final String accessToken =
        'https://accounts.spotify.com/api/token'; // Replace with your actual access token
    final String trackUrl =
        'https://api.spotify.com/v1/tracks/${widget.songUrl}';

    final response = await http.get(
      Uri.parse(trackUrl),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> trackData = json.decode(response.body);

      setState(() {
        artistName = trackData['artists'][0]['name'];
        albumArtUrl = trackData['album']['images'][0]['url'];
      });
    } else {
      print('Error fetching song details: ${response.statusCode}');
    }
  }

  void showPlaylistDialog() async {
    String newPlaylistName = "";

    // Fetch existing playlists from Firestore
    List<String> existingPlaylists = await fetchUserPlaylists();

    // Sort playlists with "Happy," "Sad," "Energetic," and "Calm" first
    existingPlaylists.sort((a, b) {
      if (a == 'Happy' || a == 'Sad' || a == 'Energetic' || a == 'Calm') {
        return -1;
      } else if (b == 'Happy' ||
          b == 'Sad' ||
          b == 'Energetic' ||
          b == 'Calm') {
        return 1;
      } else {
        return a.compareTo(b);
      }
    });

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Colors.black,
              title: Text(
                'Add to Playlist',
                style: TextStyle(color: Colors.white),
              ),
              content: Container(
                width: double.minPositive,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Display existing playlists as radio buttons in a ListView
                    Container(
                      height: 200, // Set the height based on your design
                      child: ListView.builder(
                        itemCount: existingPlaylists.length,
                        itemBuilder: (BuildContext context, int index) {
                          return RadioListTile(
                            fillColor: MaterialStateProperty.all(primary),
                            title: Text(
                              existingPlaylists[index],
                              style: TextStyle(color: Colors.white),
                            ),
                            groupValue: selectedPlaylist,
                            value: existingPlaylists[index],
                            onChanged: (value) {
                              setState(() {
                                selectedPlaylist = value;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    // Option to create a new playlist
                    ListTile(
                      leading: Icon(FeatherIcons.plus, color: Colors.white),
                      title: Text(
                        'Create New Playlist',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () async {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: Colors.black,
                              title: Text(
                                'Create New Playlist',
                                style: TextStyle(color: Colors.white),
                              ),
                              content: TextField(
                                decoration: InputDecoration(
                                  labelText: 'Playlist Name',
                                  labelStyle: TextStyle(color: Colors.white),
                                ),
                                onChanged: (value) {
                                  newPlaylistName = value;
                                },
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    if (newPlaylistName.isNotEmpty) {
                                      await saveSongToFirestore(
                                        widget.songUrl,
                                        newPlaylistName,
                                      );
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Text(
                                    'Create',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    if (selectedPlaylist != null) {
                      print('Added to playlist: $selectedPlaylist');
                      await saveSongToFirestore(
                          widget.songUrl, selectedPlaylist!);
                    }
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

// Function to fetch existing playlists from Firestore
  Future<List<String>> fetchUserPlaylists() async {
    try {
      final firestore = FirebaseFirestore.instance;
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print('User is not authenticated.');
        return [];
      }

      CollectionReference playlistCollection =
          firestore.collection('user_playlists');

      QuerySnapshot playlistQuery =
          await playlistCollection.doc(user.uid).collection('playlists').get();

      List<String> playlists =
          playlistQuery.docs.map((doc) => doc['name'].toString()).toList();

      return playlists;
    } catch (error) {
      print('Error fetching user playlists: $error');
      return [];
    }
  }

  Future<List<String>> fetchAvailablePlaylists() async {
    try {
      // Initialize Firestore
      final firestore = FirebaseFirestore.instance;

      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;

      // Check if the user is authenticated
      if (user == null) {
        print('User is not authenticated.');
        return [];
      }

      // Create a reference to the user's playlist collection
      CollectionReference playlistCollection =
          firestore.collection('user_playlists');

      // Fetch all available playlists
      QuerySnapshot playlistQuery =
          await playlistCollection.doc(user.uid).collection('playlists').get();

      List<String> availablePlaylists = [];
      for (QueryDocumentSnapshot playlistDoc in playlistQuery.docs) {
        availablePlaylists.add(playlistDoc['name']);
      }

      return availablePlaylists;
    } catch (error) {
      print('Error fetching playlists from Firestore: $error');
      return [];
    }
  }

  Future<void> saveSongToFirestore(String songId, String playlistName) async {
    try {
      // Initialize Firestore
      final firestore = FirebaseFirestore.instance;

      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;

      // Check if the user is authenticated
      if (user == null) {
        print('User is not authenticated.');
        return;
      }

      // Create a reference to the user's playlist collection
      CollectionReference playlistCollection =
          firestore.collection('user_playlists');

      // Check if the playlist already exists
      QuerySnapshot playlistQuery = await playlistCollection
          .doc(user.uid) // Use the UID of the authenticated user
          .collection('playlists')
          .where('name', isEqualTo: playlistName)
          .get();

      // If the playlist doesn't exist, create it
      if (playlistQuery.docs.isEmpty) {
        await playlistCollection.doc(user.uid).collection('playlists').add({
          'name': playlistName,
          'songs': [songId],
        });
      } else {
        // If the playlist exists, update it by adding the song ID
        DocumentSnapshot playlistDoc = playlistQuery.docs.first;
        List<dynamic> songs = List.from(playlistDoc['songs']);
        songs.add(songId);

        await playlistCollection
            .doc(user.uid)
            .collection('playlists')
            .doc(playlistDoc.id)
            .update({'songs': songs});
      }

      print('Song $songId added to playlist $playlistName in Firestore.');
    } catch (error) {
      print('Error saving song to Firestore: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.positionStream.listen((position) {
      setState(() {
        this.position = position;
      });
    });

    _audioPlayer.durationStream.listen((duration) {
      setState(() {
        this.duration = duration!;
      });
    });
    fetchTracksByType(widget.playlistId, widget.trackType).then((tracks) {
      setState(() {
        playlistTracks = tracks;
      });
    });
    playSong();
    fetchSongDetails();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: getAppBar(),
      body: getBody(),
    );
  }

  AppBar getAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      actions: const [
        IconButton(
          onPressed: null,
          icon: Icon(FeatherIcons.moreVertical, color: Colors.white),
        )
      ],
    );
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: 30,
                  right: 30,
                  top: 0,
                ),
                child: Container(
                  width: size.width - 20,
                  height: size.width - 60,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: widget.color,
                          blurRadius: 10,
                          spreadRadius: 1,
                          offset: Offset(-10, 30))
                    ],
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 30,
                  right: 30,
                  top: 20,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(widget.img), fit: BoxFit.cover),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  width: size.width - 60,
                  height: size.width - 60,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 10,
              right: 10,
            ),
            child: Container(
              width: size.width - 80,
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      // Show a dialog for selecting or creating a playlist.
                      showPlaylistDialog();
                    },
                    icon: Icon(FeatherIcons.folderPlus, color: Colors.white),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        width: 150,
                        child: Text(
                          widget.description,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    //AntIcons.folderAddOutlined,
                    FeatherIcons.moreVertical,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: StreamBuilder<Duration>(
              stream: _audioPlayer.positionStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data ?? Duration.zero;

                // Update the position variable
                position = positionData;

                print('Position: ${positionData.inSeconds}');

                return ProgressBar(
                  progress: position,
                  total: duration,
                  thumbColor: primary,
                  bufferedBarColor: primary,
                  thumbGlowColor: primary.withOpacity(0.8),
                  progressBarColor: primary,
                  onSeek: (position) {
                    _audioPlayer.seek(position);
                  },
                );
              },
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 30,
              right: 30,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatTime(position.inSeconds),
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
                Text(
                  formatTime((duration).inSeconds),
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 25,
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () async {
                    _audioPlayer.shuffle();
                  },
                  icon: Icon(
                    FeatherIcons.shuffle,
                    color: Colors.white.withOpacity(0.8),
                    size: 25,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await playPreviousInPlaylist(playlistTracks);
                  },
                  icon: Icon(
                    FeatherIcons.skipBack,
                    color: Colors.white.withOpacity(0.8),
                    size: 25,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (isPlaying) {
                      _audioPlayer.pause();
                    } else {
                      _audioPlayer.play();
                    }
                    setState(() {
                      isPlaying = !isPlaying;
                    });
                  },
                  iconSize: 50,
                  icon: Container(
                    decoration:
                        BoxDecoration(color: primary, shape: BoxShape.circle),
                    child: Center(
                      child: Icon(
                        isPlaying
                            ? Entypo.controller_paus
                            : Entypo.controller_play,
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await playNextInPlaylist(playlistTracks);
                  },
                  icon: Icon(
                    FeatherIcons.skipForward,
                    color: Colors.white.withOpacity(0.8),
                    size: 25,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    _audioPlayer.setLoopMode(LoopMode.one);
                  },
                  icon: Icon(
                    AntIcons.retweetOutlined,
                    color: Colors.white.withOpacity(0.8),
                    size: 25,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 25,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FeatherIcons.tv,
                color: primary,
                size: 20,
              ),
              SizedBox(
                width: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  "Chromecast is ready",
                  style: TextStyle(color: primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
