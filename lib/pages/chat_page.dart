import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ChatPage extends StatefulWidget {
  final String artistId; // Add artist ID

  ChatPage({
    required this.artistId,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String artistImageURL = '';
  String artistName = '';
  String artistSummary = ''; // Add this variable to store the artist's summary
  TextEditingController _messageController = TextEditingController();
  List<ChatMessage> _messages = [];

  Future<void> fetchArtistDetails() async {
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

        setState(() {
          artistName = artistDetails['name']; // Get the artist's name
          artistImageURL =
              artistDetails['images'][0]['url']; // Get the artist's image URL
        });
      }
    }
  }

  Future<Map<String, String>> fetchLastFmArtistInfo(String artistName) async {
    final String apiKey = '6d16d4bd349f5caf3f3a5f493b273ff2';
    final String lastFmBaseUrl = 'https://ws.audioscrobbler.com/2.0/';
    final String method = 'artist.getinfo';

    final encodedArtistName = Uri.encodeQueryComponent(artistName);

    final Uri uri = Uri.parse(
      '$lastFmBaseUrl?method=$method&artist=$encodedArtistName&api_key=$apiKey&format=json',
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            json.decode(response.body)['artist'];

        final String artistName = responseData['name'] ?? 'Unknown Artist';
        final String artistImageUrl = responseData['image'] != null
            ? responseData['image'].firstWhere(
                (image) => image['size'] == 'large',
                orElse: () => {'#text': ''},
              )['#text']
            : '';

        // Extract the artist's summary
        artistSummary = responseData['bio']['summary'] ?? '';

        // Return the artist information as a map
        return {
          'artistName': artistName,
          'artistImageUrl': artistImageUrl,
          'artistSummary': artistSummary,
        };
      } else {
        // Handle API request error here, e.g., return an error map
        return {
          'artistName': 'Unknown Artist',
          'artistImageUrl': '',
          'artistSummary': '',
        };
      }
    } catch (e) {
      // Handle other exceptions here, e.g., return an error map
      return {
        'artistName': 'Unknown Artist',
        'artistImageUrl': '',
        'artistSummary': '',
      };
    }
  }

  // Implement the method to fetch upcoming shows from another source (e.g., Songkick or Bandsintown)
  Future<void> fetchUpcomingShows() async {
    // Fetch and parse upcoming shows data
    // Populate the `upcomingShows` list with Show objects from your chosen source
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Chat Bot"), // Display artist's name in the app bar
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatMessageWidget(
                  message: message,
                  artistImageURL: artistImageURL,
                );
              },
            ),
          ),
          _buildMessageComposer(),
          Text(
            artistSummary,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ), //
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      height: 70.0,
      color: Colors.white,
      child: Column(
        // Use a Column to display the artist's name and image in the input area
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _messageController,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (messageText) {
                    // You can add any custom logic for text input here
                  },
                  decoration: InputDecoration.collapsed(
                    hintText: "Send a message...",
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  // Handle user messages
                  handleUserMessage(
                      _messageController.text.trim().toLowerCase());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Predefined chatbot responses
  Map<String, String> get chatbotResponses {
    return {
      'hi': 'Hello there!',
      'hello': 'Hello there!',
      'how are you': 'I am just a chatbot, but I am doing fine. How about you?',
      'what is your name': 'I am $artistName.',
      'upcoming shows':
          'Sorry, I don\'t have information about upcoming shows at the moment.',
      'tell me about the artist':
          'The artist is $artistName. You can see their image above.',
      'i am a big fan of yours':
          'Thank for your supporting for my music,hope you all are enjoying',
      'what are your upcoming plans':
          'I have many surprises scheduled for you all,stay tuned.',
      'i love you':
          'I am deeply touched by your kind words and support. Thank you  for loving my music. It means the world to me I am grateful for all my fan\'s love and support, and I\'ll continue to work hard to bring you more music and performances that you\'ll enjoy.',
      'good luck':
          'Thank you very much for your well wishes! I\'ll do my best to continue bringing you great music and performances in the future. Your support means a lot to me, and I look forward to sharing more with you. Take care, and stay tuned for what\'s to come!',
      'take care':
          'You take care as well! Goodbye for now, and thank you for your kind words and support!',
      'bye': 'Goodbye for now, and thank you for your kind words and support.',
      'You are handsome':
          'I appreciate the compliment,. Your heart is pretty as well. Thank You.',
      'you are gorgeous':
          'I appreciate the compliment, Your heart is pretty as well. Thank You.',
      'you are pretty':
          'I appreciate the compliment, Your heart is pretty as well. Thank You.'
      // Add more predefined responses here
    };
  }

  @override
  void initState() {
    super.initState();
    fetchArtistDetails();
    fetchLastFmArtistInfo(artistName);
    // Fetch upcoming shows when the widget is created (you need to implement this)
  }

  // Add a method to handle user messages and display responses
  void handleUserMessage(String message) {
    String response = chatbotResponses[message] ?? 'I don\'t understand that.';

    _messages.add(
      ChatMessage(
        message: message,
        isUserMessage: true, // Indicate that it's a user message
      ),
    );
    _messages.add(
      ChatMessage(
        message: response,
        isUserMessage: false, // Indicate that it's a chatbot message
      ),
    );

    // Update the UI
    setState(() {});

    // Clear the message input field
    _messageController.clear();
  }
}

class ChatMessage {
  final String message;
  final bool isUserMessage;

  ChatMessage({
    required this.message,
    required this.isUserMessage,
  });
}

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final String artistImageURL;

  ChatMessageWidget({required this.message, required this.artistImageURL});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isUserMessage
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isUserMessage)
            CircleAvatar(
              backgroundImage: AssetImage('assets/bot.png'),
              backgroundColor: Colors.black,
              radius: 16,
            ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: message.isUserMessage ? Colors.blue : Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message.message,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
