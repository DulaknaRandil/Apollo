import 'package:apollodemo1/auth/user_profile.dart';
import 'package:apollodemo1/json/songs_json.dart';
import 'package:apollodemo1/pages/auth_page.dart';
import 'package:apollodemo1/pages/homepage.dart';
import 'package:apollodemo1/pages/login_or_register.dart';
import 'package:apollodemo1/pages/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:page_transition/page_transition.dart';

import '../pages/album_detail_page.dart';
import '../pages/playlist_detail_page.dart';
import 'album_page.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String selectedGenre = ""; // Add this line
  List<Map<String, dynamic>>? selectedPlaylistTracks;
  List<Map<String, dynamic>>? selectedCategoryPlaylists;
  List<Map<String, dynamic>> playlists = [];
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  String? profileImage;
  String? uName;
  String? eMail;

  @override
  Future<List<Map<String, dynamic>>> fetchPlaylistsFromApi(String genre) async {
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
      final accessToken = authData['access_token'];

      String playlistsUrl = "";
      if (genre == 'Featured') {
        playlistsUrl = 'https://api.spotify.com/v1/browse/featured-playlists';
      } else {
        playlistsUrl =
            'https://api.spotify.com/v1/browse/categories/$genre/playlists';
      }

      final playlistsResponse = await http.get(
        Uri.parse(playlistsUrl),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (playlistsResponse.statusCode == 200) {
        final Map<String, dynamic> playlistsData =
            json.decode(playlistsResponse.body);
        final List<dynamic> playlistItems = playlistsData['playlists']['items'];

        return playlistItems.map<Map<String, dynamic>>((playlistItem) {
          return {
            'name': playlistItem['name'],
            'imageUrl': playlistItem['images'][0]['url'],
            'id': playlistItem['id'],
          };
        }).toList();
      }
    }

    return [];
  }

  List<Map<String, dynamic>> getSongsForGenre(String genre) {
    // Filter the 'songs' list to get tracks for the selected genre
    List<Map<String, dynamic>> selectedGenreTracks = [];

    for (var song in songs) {
      List<dynamic> songTracks = song['songs'];
      for (var track in songTracks) {
        if (track['genre'] == genre) {
          selectedGenreTracks.add(track);
        }
      }
    }

    return selectedGenreTracks;
  }

  Future<List<Map<String, dynamic>>> fetchPlaylistsForCategory(
      String category) async {
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
      final accessToken = authData['access_token'];

      final chartsUrl = '$category';
      //'https://api.spotify.com/v1/browse/categories/toplists/playlists';
      //'https://api.spotify.com/v1/browse/new-releases';
      final chartsResponse = await http.get(
        Uri.parse(chartsUrl),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (chartsResponse.statusCode == 200) {
        final Map<String, dynamic> chartsData =
            json.decode(chartsResponse.body);
        final List<dynamic> chartItems = chartsData['playlists']['items'];

        // Print the charts data
        print("Top Spotify Global Charts:");
        for (var chartItem in chartItems) {
          print('Name: ${chartItem['name']}');
          print('Image URL: ${chartItem['images'][0]['url']}');
          print('ID: ${chartItem['id']}');
          print('-----------------------------------');
        }

        return chartItems.map<Map<String, dynamic>>((chartItem) {
          return {
            'name': chartItem['name'],
            'imageUrl': chartItem['images'][0]['url'],
            'id': chartItem['id'],
          };
        }).toList();
      }
    }

    return [];
  }

  Future<void> _fetchUserPlaylists() async {
    final clientId = '5d01e47fab0844c9b7f5c7ed4cf12718';
    final clientSecret = '34fa810e6c054630939ea51cd226d2ec';

    try {
      final tokenResponse = await _getAccessToken(clientId, clientSecret);

      final token = tokenResponse['access_token'];
      final playlists = await _getUserPlaylists(token);

      setState(() {
        this.playlists = playlists;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<Map<String, dynamic>> _getAccessToken(
      String clientId, String clientSecret) async {
    final url = Uri.parse('https://accounts.spotify.com/api/token');
    final credentials =
        Base64Encoder().convert('$clientId:$clientSecret'.codeUnits);

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'client_credentials',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to obtain access token');
    }
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  Future<List<Map<String, dynamic>>> _getUserPlaylists(
      String accessToken) async {
    final url = Uri.parse(
        'https://api.spotify.com/v1/users/zz6athiu53yfw6zg7vlxxenrw/playlists');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['items']);
    } else {
      throw Exception('Failed to fetch user playlists');
    }
  }

  void getProfilePhoto() async {
    setState(() {
      var _isLoading = true;
    });
    try {
      User? user = FirebaseAuth.instance.currentUser;
      final db = FirebaseFirestore.instance;

      if (user != null) {
        DocumentSnapshot documentSnapshot =
            await db.collection('users').doc(user.uid).get();
        Map<String, dynamic> userData =
            documentSnapshot.data() as Map<String, dynamic>;
        profileImage = userData['profileImage'];
        eMail = userData['emailAddress'];
        uName = userData['firstName'];
        setState(() {});
        print(profileImage);
      } else {
        setState(() {});
        print("User not signed in");
      }
    } catch (e) {
      setState(() {});
      print("Error getting user information: $e");
    }
  }

  // Add this line
  int activeMenu1 = 0;
  int activeMenu2 = 2;
  Color primary = Colors.amber;

  @override
  void initState() {
    super.initState();
    fetchPlaylistsFromApi(song_type_1[0]["genre"]!).then((playlists) {
      setState(() {
        selectedPlaylistTracks = playlists;
      });
    });
    fetchPlaylistsForCategory(song_type_2[2]["category"]!).then((playlists) {
      setState(() {
        selectedCategoryPlaylists = playlists;
      });
    });
    _fetchUserPlaylists();
    getCurrentUserInfo();
    getProfilePhoto();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: getAppBar(),
      body: getBody(),
      endDrawer: Drawer(
        backgroundColor: Colors.black,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              accountName: Text(
                nameController.text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              accountEmail: Text(
                emailController.text,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: profileImage != null
                    ? NetworkImage(profileImage!)
                    : null, // If profileImage is null, do not set the backgroundImage
              ),
            ),
            ListTile(
              title: Text(
                'Profile',
                style: TextStyle(color: Colors.amber),
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()));
                // Navigate to the profile page or perform the corresponding action
                // Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
              },
            ),
            ListTile(
              title: Text(
                'Check Mood',
                style: TextStyle(color: Colors.amber),
              ),
              onTap: () {
                // Navigate to the mood-check page or perform the corresponding action
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomePage()));
              },
            ),
            ListTile(
              title: Text(
                'Log Out',
                style: TextStyle(color: Colors.amber),
              ),
              onTap: () {
                // Call the method to sign out the user
                signUserOut();
                // Navigate to the login or register page or perform any other actions
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AuthPage()),
                );
                // Add this line ));
                // For example, you might want to clear authentication tokens, etc.
              },
            ),
          ],
        ),
      ),
    );
  }

  void getCurrentUserInfo() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        nameController.text = user.displayName ?? "No Name";
        emailController.text = user.email ?? "No Email";
      } else {
        print("User not signed in");
      }
    } catch (e) {
      print("Error getting user information: $e");
    }
  }

  AppBar getAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      title: Padding(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Explore",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.only(left: 30, top: 20),
                  child: Row(
                    children: List.generate(song_type_1.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 25),
                        child: GestureDetector(
                          onTap: () async {
                            var selectedGenre = song_type_1[index]["genre"];
                            final selectedGenreTracks =
                                await fetchPlaylistsFromApi(selectedGenre!);

                            setState(() {
                              activeMenu1 = index;
                              selectedPlaylistTracks = selectedGenreTracks;
                            });

                            print("Selected Genre: $selectedGenre");
                            print(
                                "Selected Genre Tracks: $selectedGenreTracks");

                            /* Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SpotifyScreen(
                                  selectedPlaylistName: song_type_1[index]
                                      ["name"]!,
                                  selectedGenre: selectedGenre,
                                  selectedPlaylistTracks:
                                      selectedGenreTracks, // Pass the selected genre
                                ),
                              ),
                            ); */
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song_type_1[index]["name"]!,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: activeMenu1 == index
                                      ? primary
                                      : Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              activeMenu1 == index
                                  ? Container(
                                      width: 10,
                                      height: 3,
                                      decoration: BoxDecoration(
                                          color: primary,
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                    )
                                  : Container()
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              if (selectedPlaylistTracks != null &&
                  selectedPlaylistTracks!.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Row(
                      children: selectedPlaylistTracks!.map((playlist) {
                        final playlistId = playlist["id"];
                        final playlistName = playlist["name"];
                        final playlistImageUrl = playlist["imageUrl"];

                        if (playlistId == null ||
                            playlistName == null ||
                            playlistImageUrl == null) {
                          return const SizedBox
                              .shrink(); // Skip invalid playlists
                        }

                        return Padding(
                          padding: const EdgeInsets.only(right: 30),
                          child: GestureDetector(
                            onTap: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlaylistDetailPage(
                                    genre: selectedGenre,
                                    playlistId: playlist['id'],
                                    playlistName: playlist['name'],
                                    playlistImageUrl: playlist['imageUrl'],
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(playlist['imageUrl']),
                                      fit: BoxFit.cover,
                                    ),
                                    color: primary,
                                    borderRadius:
                                        BorderRadiusDirectional.circular(10),
                                  ),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  playlist['name'],
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.only(left: 30, top: 20),
                  child: Row(
                    children: List.generate(song_type_2.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 25),
                        child: GestureDetector(
                          onTap: () async {
                            final selectedCategory =
                                song_type_2[index]["category"]!;
                            final selectedCategoryPlaylists =
                                await fetchPlaylistsForCategory(
                                    selectedCategory);

                            setState(() {
                              activeMenu2 = index;
                              this.selectedCategoryPlaylists =
                                  selectedCategoryPlaylists;
                            });

                            // Handle selected category playlists
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song_type_2[index]["name"],
                                style: TextStyle(
                                  fontSize: 15,
                                  color: activeMenu2 == index
                                      ? primary
                                      : Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              activeMenu2 == index
                                  ? Container(
                                      width: 10,
                                      height: 3,
                                      decoration: BoxDecoration(
                                          color: primary,
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                    )
                                  : Container()
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              // ...
              SizedBox(
                height: 15,
              ),
              // Display the selected playlists in a horizontal scroll view
              if (selectedCategoryPlaylists != null &&
                  selectedCategoryPlaylists!.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Row(
                      children: selectedCategoryPlaylists!.map((playlist) {
                        final playlistId = playlist["id"];
                        final playlistName = playlist["name"];
                        final playlistImageUrl = playlist["imageUrl"];

                        if (playlistId == null ||
                            playlistName == null ||
                            playlistImageUrl == null) {
                          return const SizedBox
                              .shrink(); // Skip invalid playlists
                        }

                        return Padding(
                          padding: const EdgeInsets.only(right: 30),
                          child: GestureDetector(
                            onTap: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlaylistDetailPage(
                                    genre: selectedGenre,
                                    playlistId: playlist['id'],
                                    playlistName: playlist['name'],
                                    playlistImageUrl: playlist['imageUrl'],
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(playlist['imageUrl']),
                                      fit: BoxFit.cover,
                                    ),
                                    color: primary,
                                    borderRadius:
                                        BorderRadiusDirectional.circular(10),
                                  ),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  playlist['name'],
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ...
}
