import 'dart:convert';
import 'package:apollodemo1/pages/music_Detail_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

// In SongListPage:

class SongListPage extends StatefulWidget {
  final List<Map<String, dynamic>> trackDetails;
  final List<String>? trackIds; // Make trackIds optional
  final String selectedMood;
  SongListPage({
    required this.trackDetails,
    required this.trackIds, // Make trackIds optional
    required this.selectedMood,
  });

  @override
  _SongListPageState createState() => _SongListPageState();
}

class _SongListPageState extends State<SongListPage> {
  List<Map<String, dynamic>> songs = [];

  @override
  void initState() {
    super.initState();
    // Check if trackIds is provided, if so, fetch song details
    if (widget.trackIds != null) {
      fetchTrackDetails();
    }
  }

  Future<String> getAccessToken() async {
    try {
      // Replace 'YOUR_CLIENT_ID' and 'YOUR_CLIENT_SECRET' with your actual Spotify credentials
      final clientId = '5d01e47fab0844c9b7f5c7ed4cf12718';
      final clientSecret = '34fa810e6c054630939ea51cd226d2ec';

      final credentials = base64.encode(utf8.encode('$clientId:$clientSecret'));
      final response = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'grant_type=client_credentials',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final accessToken = data['access_token'];
        return accessToken;
      } else {
        throw Exception('Failed to obtain Spotify access token');
      }
    } catch (e) {
      print('Error getting access token: $e');
      return '';
    }
  }

  Future<void> fetchTrackDetails() async {
    try {
      final accessToken = await getAccessToken();

      for (String trackId in widget.trackIds!) {
        final url = Uri.parse('https://api.spotify.com/v1/tracks/$trackId');
        final response = await http.get(
          url,
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print(data);
          final song = {
            'songUrl': data['id'],
            'name': data['name'],
            'artists': data['artists'].map((artist) => artist['name']).toList(),
            'imageUrl': data['album']['images'][0]['url'],
          };
          setState(() {
            songs.add(song); // Add the song to the list
          });
        } else {
          print('Error fetching track details: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error fetching track details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Builder(
          // Use a Builder to access the context of the Scaffold
          builder: (BuildContext context) {
            return Text(' ${widget.selectedMood.toUpperCase()}');
          },
        ),
      ),
      body: ListView.builder(
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];
          return Card(
            child: ListTile(
              leading: Image.network(song['imageUrl'], width: 60, height: 60),
              title: Text('${song['name']}'),
              subtitle: Text('${song['artists'].join(", ")}'),
              trailing: IconButton(
                icon: Icon(Icons.play_arrow),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MusicDetailPage(
                        title: song['name'],
                        description: song['artists'].join(
                            ", "), // You can set an appropriate description.
                        color: Colors.amber, // Set the desired color.
                        img: song['imageUrl'],
                        songUrl: song['songUrl'], // Pass the Spotify track ID.
                        trackType: 'emoplaylist',
                        playlistId: widget.selectedMood,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
