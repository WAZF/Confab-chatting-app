//Packages
import 'package:flutter/material.dart';

//Pages
import '../pages/chats_page.dart';
import '../pages/users_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  int _currentPage = 0;
  final List<Widget> _pages = [
    ChatsPage(),
    UsersPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return _buildUI();
  }

  Widget _buildUI() {
  return Scaffold(
    body: _pages[_currentPage],
    bottomNavigationBar: _buildCurvedBottomNavigationBar(),
  );
}
Widget _buildCurvedBottomNavigationBar() {
  return ClipRRect(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(30.0),
      topRight: Radius.circular(30.0),
    ),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey, // Customize background color here
      ),
      child: BottomNavigationBar(
        currentIndex: _currentPage,
        onTap: (_index) {
          setState(() {
            _currentPage = _index;
          });
        },
        selectedItemColor: Color.fromARGB(255, 164, 64, 221), // Color for the selected item
        unselectedItemColor: Colors.grey, // Color for unselected items
        items: [
          BottomNavigationBarItem(
            label: "Chats",
            icon: Icon(
              Icons.chat_rounded,
            ),
          ),
          BottomNavigationBarItem(
            label: "Users",
            icon: Icon(
              Icons.supervisor_account,
            ),
          ),
        ],
      ),
    ),
  );
}


}
