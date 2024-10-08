
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:timeago/timeago.dart' as timeago;

//Providers
import '../providers/authentication_provider.dart';
import '../providers/chats_page_provider.dart';

//Services
import '../services/navigation_service.dart';

//Pages
import '../pages/chat_page.dart';
import '../pages/user_profile.dart';

//Widgets
import '../widgets/top_bar.dart';
import '../widgets/custom_list_view_tiles.dart';

//Models
import '../models/chat.dart';
import '../models/chat_user.dart';
import '../models/chat_message.dart';

class ChatsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ChatsPageState();
  }
}

class _ChatsPageState extends State<ChatsPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late NavigationService _navigation;
  late ChatsPageProvider _pageProvider;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    _navigation = GetIt.instance.get<NavigationService>();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChatsPageProvider>(
          create: (_) => ChatsPageProvider(_auth),
        ),
      ],
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
  return Builder(
    builder: (BuildContext _context) {
      _pageProvider = _context.watch<ChatsPageProvider>();
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: _deviceWidth * 0.03,
          vertical: _deviceHeight * 0.02,
        ),
        height: _deviceHeight * 0.98,
        width: _deviceWidth * 0.97,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TopBar(
              'Chats',
              secondaryAction: Consumer<AuthenticationProvider>(
                builder: (context, authProvider, _) {
                  return FutureBuilder<String?>(
                    future: authProvider.getCurrentUserImageURL(),
                    builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(); // Show a loading indicator while fetching the image URL
                      } else {
                        if (snapshot.hasData && snapshot.data != null) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserPage(), // Replace with your UserProfile page
                                ),
                              );
                            },
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(snapshot.data!), // Use the retrieved URL
                              radius: 15,
                            ),
                          );
                        } else {
                          return Text('No Image'); // Placeholder if no image URL available
                        }
                      }
                    },
                  );
                },
              ),
            ),
            _chatsList(),
          ],
        ),
      );
    },
  );
}



  Widget _chatsList() {
    List<Chat>? _chats = _pageProvider.chats;
    return Expanded(
      child: (() {
        if (_chats != null) {
          if (_chats.length != 0) {
            return ListView.builder(
              itemCount: _chats.length,
              itemBuilder: (BuildContext _context, int _index) {
                return _chatTile(
                  _chats[_index],
                );
              },
            );
          } else {
            return Center(
              child: Text(
                "No Chats Found.",
                style: TextStyle(color: Colors.white),
              ),
            );
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        }
      })(),
    );
  }

  Widget _chatTile(Chat _chat) {
    List<ChatUser> _recipients = _chat.recepients();
    bool _isActive = _recipients.any((_user) => _user.wasRecentlyActive());
    String _lastMessageContent = "";
    String _timestamp = "";

    if (_chat.messages.isNotEmpty) {
      _lastMessageContent = _chat.messages.last.type != MessageType.TEXT
          ? "Media Attachment"
          : _chat.messages.last.content;

      _timestamp = _chat.messages.last.sentTime != null
          ? timeago.format(_chat.messages.last.sentTime!,
              locale: 'en_short') // 'en_short' for short time descriptions
          : "";
    }

    return GestureDetector(
      
      onTap: () {
        _navigation.navigateToPage(
          ChatPage(chat: _chat),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(10),
          leading: CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(_chat.imageURL()),
          ),
          title: Text(
            _chat.title(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            _lastMessageContent,
            style: TextStyle(fontSize: 14),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isActive)
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                ),
              SizedBox(width: 5),
              if (_chat.activity)
                Text(
                  _timestamp,
                  style: TextStyle(fontSize: 12),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
