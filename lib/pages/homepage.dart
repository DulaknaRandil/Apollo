import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:apollodemo1/home_screen/home_screen.dart';
import 'package:apollodemo1/json/spotify.dart';
import 'package:apollodemo1/main.dart';
import 'package:apollodemo1/model/song_data_model.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tflite_v2/tflite_v2.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CameraImage? cameraImage;
  CameraController? cameraController;
  String output = '';
  final user = FirebaseAuth.instance.currentUser!;
  String selectedMood = '';
  List<String> spotifyTrackIds = [];
  List<SongData> songDatas = [];
  List<SongData> songList = [];
  dynamic camera;
  loadcamera() {
    cameraController = CameraController(
        kIsWeb ? cameras![0] : cameras![1], ResolutionPreset.medium);
    cameraController!.initialize().then((value) {
      if (!mounted) {
        return;
      } else {
        setState(() {
          cameraController!.startImageStream((imageStream) {
            cameraImage = imageStream;
            runModel();
          });
        });
      }
    });
  }

  runModel() async {
    if (cameraImage != null) {
      var predictions = await Tflite.runModelOnFrame(
        bytesList: cameraImage!.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        imageHeight: cameraImage!.height,
        imageWidth: cameraImage!.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 2,
        threshold: 0.1,
        asynch: true,
      );
      for (var element in predictions!) {
        setState(() {
          output = element['label'].replaceAll(RegExp(r'^\d+\s+'), '');
        });
      }
    }
  }

  loadModel() async {
    await Tflite.loadModel(
      model: 'assets/model.tflite',
      labels: 'assets/labels.txt',
    );
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  void initState() {
    super.initState();
    intiializeSongs();

    loadModel();
    if (!kIsWeb) {
      // If not running on the web, start the camera
      loadcamera();
    }

    // Load the CSV data when the widget initializes
  }

  void intiializeSongs() async {
    List<SongData> songList =
        await readAndParseJsonAsset("assets/csvjson.json");
    print("${songList[0].mood}");
  }

  Future<List<SongData>> readAndParseJsonAsset(String assetPath) async {
    try {
      String content = await rootBundle.loadString(assetPath);
      List<dynamic> jsonList = json.decode(content);

      // Create a list of SongData objects
      songList = jsonList.map((json) => SongData.fromJson(json)).toList();

      return songList;
    } catch (e) {
      throw Exception("Error reading and parsing JSON asset: $e");
    }
  }

  Map<String, List<String>> moodToIdsMap = {};

  Future<void> fetchSpotifyTrackIds(String mood) async {
    print(mood);
    List<String> moodSongIds = songList
        .where((song) => song.mood.toLowerCase() == mood.toLowerCase())
        .map((song) => song.id.toString())
        .toList();
    print(moodSongIds.length);
    setState(() {
      selectedMood = mood;
      output = mood;
      spotifyTrackIds = moodSongIds;
    });
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

  Future<void> fetchSpotifyTracks(String mood) async {
    try {
      final accessToken =
          await getAccessToken(); // Get your Spotify access token here

      final url =
          Uri.parse('https://api.spotify.com/v1/search?q=$mood&type=track');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tracks = data['tracks']['items'];

        List<Map<String, dynamic>> trackDetails = [];
        for (var track in tracks) {
          final trackId = track['id'];
          final trackName = track['name'];
          final artists =
              track['artists'].map((artist) => artist['name']).toList();
          final trackImageUrl = track['album']['images'][0]['url'];

          trackDetails.add({
            'id': trackId,
            'name': trackName,
            'artists': artists,
            'imageUrl': trackImageUrl,
          });
        }

        // Pass trackDetails to the new method
        _navigateToSongListPage(trackDetails);
      } else {
        print('Error fetching Spotify tracks: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching Spotify tracks: $e');
    }
  }

  void _navigateToSongListPage(List<Map<String, dynamic>> trackDetails) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SongListPage(
          trackDetails: trackDetails,
          trackIds: spotifyTrackIds,
          selectedMood: selectedMood,
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchTrackDetails(
      List<String> trackIds) async {
    List<Map<String, dynamic>> trackDetails = [];

    try {
      final accessToken =
          await getAccessToken(); // Get your Spotify access token here

      for (String trackId in trackIds) {
        final url = Uri.parse('https://api.spotify.com/v1/tracks/$trackId');
        final response = await http.get(
          url,
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final trackName = data['name'];
          final artists =
              data['artists'].map((artist) => artist['name']).toList();
          final trackImageUrl = data['album']['images'][0]['url'];

          trackDetails.add({
            'id': trackId,
            'name': trackName,
            'artists': artists,
            'imageUrl': trackImageUrl,
          });
        } else {
          print('Error fetching track details: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error fetching track details: $e');
    }

    return trackDetails;
  }

  void _navigateToHomeScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ),
    );
  }

  @override
  dispose() {
    // Dispose of resources here
    cameraController?.stopImageStream();
    cameraController?.dispose();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(
          const Duration(milliseconds: 500)); // Delay for resource cleanup
      await Tflite.close(); // Close TensorFlow Lite interpreter
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // appBar: AppBar(
      //   backgroundColor: Colors.black,
      //   actions: [
      //     IconButton(
      //         onPressed: signUserOut,
      //         icon: const Icon(
      //           Icons.logout,
      //           color: Colors.amber,
      //         )),
      //   ],
      // ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hey...!',
              style: const TextStyle(fontSize: 45, color: Colors.white),
            ),
            SizedBox(height: 10), // Adjust this value as needed

            Text(
              'Tell me your mood',
              style: const TextStyle(fontSize: 40, color: Colors.white),
            ),
            Column(
              children: [
                if (!kIsWeb) // Only show camera-related UI on Android
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.amber, // Amber color
                          width: 5, // Width of the border
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black, // Amber color
                            width: 3, // Width of the border
                          ),
                        ),
                        child: ClipOval(
                          child: Container(
                            height: 300,
                            width: 300,
                            child: !cameraController!.value.isInitialized
                                ? Container()
                                : AspectRatio(
                                    aspectRatio:
                                        cameraController!.value.aspectRatio,
                                    child: CameraPreview(cameraController!),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    /*  Text(
                  output,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ), */
                  ),
              ],
            ),
            SizedBox(height: 5),
            if (kIsWeb) // Show mood buttons only on the web
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  MoodButton(
                    emoji: '😊',
                    mood: 'happy',
                    onMoodSelected: _handleMoodSelected,
                  ),
                  MoodButton(
                    emoji: '😢',
                    mood: 'sad',
                    onMoodSelected: _handleMoodSelected,
                  ),
                  MoodButton(
                    emoji: '😌',
                    mood: 'calm',
                    onMoodSelected: _handleMoodSelected,
                  ),
                  MoodButton(
                    emoji: '🚀',
                    mood: 'energetic',
                    onMoodSelected: _handleMoodSelected,
                  ),
                ],
              ),
            SizedBox(height: 20),
            Text(
              kIsWeb
                  ? 'Selected Mood: $selectedMood'
                  : 'Selected Mood: $output',
              style: TextStyle(fontSize: 25, color: Colors.white),
            ),
            SizedBox(
              height: 30,
            ),
            if (output.isNotEmpty || kIsWeb)
              Column(
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.amber),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                      ),
                    ),
                    onPressed: () {
                      fetchSpotifyTracks(
                        kIsWeb ? selectedMood : output.toLowerCase(),
                      ); // Fetch and navigate to SongListPage
                      _handleMoodSelected(output.toLowerCase());
                    },
                    child: Text('View Songs',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                        )),
                  ),
                ],
              ),
            SizedBox(
              height: 35,
            ),
            Text(
              'Continue with Homepage',
              style: TextStyle(fontSize: 25, color: Colors.white),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
              ),
              onPressed: () {
                _navigateToHomeScreen();
              },
              child: Text(
                'Continue',
                style: TextStyle(fontSize: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMoodSelected(String mood) {
    fetchSpotifyTrackIds(mood);
  }
}

class MoodButton extends StatelessWidget {
  final String emoji;
  final String mood;
  final Function(String) onMoodSelected;

  MoodButton({
    required this.emoji,
    required this.mood,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onMoodSelected(mood);
      },
      child: Column(
        children: [
          Text(
            emoji,
            style: TextStyle(fontSize: 100, color: Colors.amber),
          ),
          Text(
            mood,
            style: TextStyle(fontSize: 30, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
