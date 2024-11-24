import 'package:flutter/material.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AlertDialog(
      title: Text('Settings'), // change title
      content: Text('Customize your app experience using the settings below:'),
      actions: <Widget>[
        ListTile(
          title: Text('Language:'),
          trailing: Text(
            'English',
            style: TextStyle(color: Colors.blueAccent),
          ),
        ),
        ListTile(
          title: Text('Text Size:'),
          trailing: Text(
            'Regular',
            style: TextStyle(color: Colors.blueAccent),
          ),
        ),
        ListTile(
          title: Text('Text to Speech:'),
          trailing: Text(
            'Off',
            style: TextStyle(color: Colors.blueAccent),
          ),
        ),
        // ListTile(
        //   title: Text('Privacy:'),
        //   trailing: ElevatedButton(
        //     onPressed: () {
        //       null;
        //     },
        //     child: Text('Delete Account'),
        //     style: ElevatedButton.styleFrom(
        //         backgroundColor: Colors.red),
        //   ),
        // ),
      ],
    );
  }
}
