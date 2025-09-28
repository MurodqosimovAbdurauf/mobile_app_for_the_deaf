import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:characters/characters.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Visual Speech App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: VisualSpeechPage(),
    );
  }
}

class VisualSpeechPage extends StatefulWidget {
  @override
  _VisualSpeechPageState createState() => _VisualSpeechPageState();
}

class _VisualSpeechPageState extends State<VisualSpeechPage>
    with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _spokenText = '';
  late Ticker _ticker;
  final int particleCount = 350;
  List<Particle> particles = [];
  Timer? _restartTimer;

  // Til tanlash uchun:
  final List<String> _languages = ['ENG', 'UZB'];
  int _selectedLanguageIndex = 0;

  String get _localeId {
    // Tilga qarab speech_to_text localeId o'zgartiriladi
    return _selectedLanguageIndex == 0 ? 'en-GB' : 'uz-UZ';
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    final rnd = Random();
    particles = List.generate(
      particleCount,
          (_) => Particle(
        position: Offset(rnd.nextDouble() * 400, rnd.nextDouble() * 400),
        velocity: Offset(rnd.nextDouble() * 2 - 1, rnd.nextDouble() * 2 - 1),
      ),
    );
    _ticker = createTicker((_) {
      setState(() {
        for (var p in particles) {
          p.update();
        }
      });
    })
      ..start();
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' && _isListening) {
          _restartTimer = Timer(const Duration(milliseconds: 100), _startListening);
        }
      },
      onError: (error) {
        print('Speech recognition error: $error');
      },
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) async {
          String resultText = val.alternates.isNotEmpty
              ? val.alternates.first.recognizedWords.trim()
              : val.recognizedWords.trim();

          setState(() {
            _spokenText = resultText;
          });

          if (resultText.isNotEmpty) {
            String letter = resultText.characters.last.toUpperCase();
            List<Offset> points = await getPointsFromText(letter);
            setTextShape(points);
          }
        },
        listenMode: stt.ListenMode.confirmation,
        partialResults: true,
        localeId: _localeId,  // <-- tanlangan til asosida
      );
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
    _restartTimer?.cancel();
  }

  void _toggleListening() {
    _isListening ? _stopListening() : _startListening();
  }

  void _clearText() {
    setState(() {
      _spokenText = '';
    });
  }

  Future<List<Offset>> getPointsFromText(String text) async {
    if (text.isEmpty) return [];

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 140, color: Colors.black),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final dx = (370 - textPainter.width) / 2;
    final dy = (200 - textPainter.height) / 2;
    final offset = Offset(dx, dy);
    textPainter.paint(canvas, offset);

    final picture = recorder.endRecording();
    final img = await picture.toImage(370, 200);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.rawRgba);

    List<Offset> points = [];
    if (byteData != null) {
      for (int y = 0; y < img.height; y += 4) {
        for (int x = 0; x < img.width; x += 4) {
          final index = (y * img.width + x) * 4;
          final r = byteData.getUint8(index);
          final g = byteData.getUint8(index + 1);
          final b = byteData.getUint8(index + 2);
          final a = byteData.getUint8(index + 3);
          if (a > 0 && (r + g + b) < 600) {
            points.add(Offset(x.toDouble(), y.toDouble()));
          }
        }
      }
    }
    return points;
  }

  void setTextShape(List<Offset> points) {
    setState(() {
      for (int i = 0; i < particles.length; i++) {
        if (i < points.length) {
          particles[i].target = points[i];
          particles[i].isInShape = true;
        } else {
          particles[i].target = null;
          particles[i].isInShape = false;
        }
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        for (var p in particles) {
          p.target = null;
        }
      });
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _speech.stop();
    _restartTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visual Speech'),
        backgroundColor: Colors.blueAccent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ToggleButtons(
              borderRadius: BorderRadius.circular(12),
              selectedBorderColor: Colors.white,
              fillColor: Colors.white24,
              selectedColor: Colors.white,
              color: Colors.white70,
              constraints: BoxConstraints(minWidth: 80, minHeight: 36),
              isSelected: List.generate(
                  _languages.length, (index) => index == _selectedLanguageIndex),
              onPressed: (index) {
                if (_selectedLanguageIndex != index) {
                  setState(() {
                    _selectedLanguageIndex = index;
                    if (_isListening) {
                      _stopListening();
                      _startListening();
                    }
                  });
                }
              },
              children: _languages
                  .map((lang) => Text(lang, style: TextStyle(fontSize: 16)))
                  .toList(),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background2.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: screenSize.height * 0.4,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: ParticlePainter(particles),
                    child: Container(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    alignment: Alignment.topLeft,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green, width: 2),
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white.withOpacity(0.8),
                      boxShadow: [BoxShadow(blurRadius: 5, color: Colors.blueGrey)],
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        _spokenText,
                        style: const TextStyle(fontSize: 25, color: Colors.black),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _clearText,
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    ),
                    ElevatedButton.icon(
                      onPressed: _toggleListening,
                      icon: Icon(_isListening ? Icons.stop : Icons.mic),
                      label: Text(_isListening ? 'Stop' : 'Start'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 180),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Particle {
  Offset position;
  Offset velocity;
  Offset? target;
  bool isInShape = false;
  double opacity = 0.1;

  Particle({
    required this.position,
    required this.velocity,
    this.target,
    this.isInShape = false,
  });

  void update() {
    const double speedFactor = 0.1;
    const double opacityStep = 0.05;

    if (target != null) {
      final dx = target!.dx - position.dx;
      final dy = target!.dy - position.dy;
      position = position.translate(dx * speedFactor, dy * speedFactor);
    } else {
      position = position.translate(velocity.dx, velocity.dy);
      if (position.dx < 0 || position.dx > 400) velocity = Offset(-velocity.dx, velocity.dy);
      if (position.dy < 0 || position.dy > 400) velocity = Offset(velocity.dx, -velocity.dy);
    }

    if (isInShape) {
      opacity += opacityStep;
      if (opacity > 1) opacity = 1;
    } else {
      opacity -= opacityStep;
      if (opacity < 0.1) opacity = 0.1;
    }
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var p in particles) {
      paint.color = Colors.lightBlue.withOpacity(p.opacity);
      canvas.drawCircle(p.position, 1.7, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}
