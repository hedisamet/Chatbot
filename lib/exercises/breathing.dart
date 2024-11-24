import 'package:flutter/material.dart';
import 'package:wellbeingGuide/patient/home_page.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class BreathingExercisePage extends StatelessWidget {
  const BreathingExercisePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Video de Respiration',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal[300],
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
      ),
      body: Center(
        child: RotatedBox(
          quarterTurns: MediaQuery.of(context).orientation == Orientation.landscape ? 1 : 0,
          child: Container(
            width: double.infinity,
            child: HtmlWidget(
              '''
              <iframe width="100%" height="100%" src="https://www.youtube.com/embed/l68RrTZQdlk" frameborder="0" allowfullscreen></iframe>
              ''',
            ),
          ),
        ),
      ),
    );
  }
}
