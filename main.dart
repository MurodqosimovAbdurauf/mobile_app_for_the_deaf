import 'package:flutter/material.dart';
import 'visual_speech_page.dart'; // <-- Visual Speech sahifani import qilyapmiz
import 'speech_assistant.dart'; //Speech assistant sahifani import qilyabmiz
import 'video_lessons_page.dart'; // video darsliklar sahifasi
import 'device.dart';//qurilmaga ulaniosh qismi
void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Assistant App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/background.jpg',
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withOpacity(0.3)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Column(
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        height: 300,
                      ),
                      SizedBox(height: 10),
                      Text(
                        '',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  CustomNavButton(
                    label: "🎥 Video Tutorials",
                    color: Colors.blueAccent,
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => VideoLessonsPage()));
                    },
                  ),
                  SizedBox(height: 16),
                  CustomNavButton(
                    label: "🎙 Speech Assistant",
                    color: Colors.teal,
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => SpeechAssistantPage()));
                    },
                  ),
                  SizedBox(height: 16),
                  CustomNavButton(
                    label: "🔌 Connect to Device",
                    color: Colors.purple,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SpeechApp()),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  CustomNavButton(
                    label: "👁️ Visual Speech",
                    color: Colors.redAccent,
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => VisualSpeechPage()));
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomNavButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const CustomNavButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}



class ConnectPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connect to Device')),
      body: Center(child: Text('Bu yerda qurilmaga ulaniladi')),
    );
  }
}
