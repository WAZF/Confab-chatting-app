import 'package:flutter/material.dart';

class CustomListViewTileWithActivity extends StatelessWidget {
  final double height;
  final String title;
  final String subtitle;
  final String imagePath;
  final bool isActive;
  final bool isActivity;
  final String activityText;
  final Function onTap;

  const CustomListViewTileWithActivity({
    required this.height,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.isActive,
    required this.isActivity,
    required this.activityText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        height: height,
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.white, // White background color
        ),
        child: Row(
          children: [
            // Your avatar or image widget
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(imagePath),
                ),
              ),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            Spacer(),
            // Your activity indicator widget (isActive, isActivity, activityText)
            if (isActive || isActivity)
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? Colors.green : Colors.blue,
                ),
              ),
            SizedBox(width: 5),
            if (isActivity)
              Text(
                activityText,
                style: TextStyle(fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}
