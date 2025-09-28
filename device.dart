import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speech to ESP32',
      home: SpeechApp(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SpeechApp extends StatefulWidget {
  @override
  _SpeechAppState createState() => _SpeechAppState();
}

class _SpeechAppState extends State<SpeechApp> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '';
  String _manualText = '';
  String _language = 'uz-UZ'; // Default: Uzbek
  String esp32Url = "http://10.156.139.99/"; // ESP32 IP manzili

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          print('Speech status: $status');
          if (status == 'done' || status == 'notListening') {
            if (_isListening) {
              _speech.listen(
                onResult: _onSpeechResult,
                localeId: _language,
                listenMode: stt.ListenMode.dictation,
              );
            }
          }
        },
        onError: (error) {
          print('Speech error: $error');
          if (_isListening) {
            Future.delayed(const Duration(seconds: 1), () {
              if (_isListening) {
                _speech.listen(
                  onResult: _onSpeechResult,
                  localeId: _language,
                  listenMode: stt.ListenMode.dictation,
                );
              }
            });
          }
        },
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: _onSpeechResult,
          localeId: _language,
          listenMode: stt.ListenMode.dictation,
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _onSpeechResult(dynamic result) {
    setState(() {
      _text = result.recognizedWords;
    });
    if (result.recognizedWords.isNotEmpty) {
      sendToESP32(result.recognizedWords);
    }
  }

  Future<void> sendToESP32(String message) async {
    try {
      await http.post(
        Uri.parse(esp32Url),
        headers: {'Content-Type': 'text/plain'},
        body: message,
      );
    } catch (e) {
      print('ESP32 ga yuborishda xatolik: $e');
    }
  }

  void stopDevice() {
    sendToESP32("STOP_DEVICE");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background2.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 150),
                // STT Matn chiqarish (ramkali ekran ko'rinishida)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.4),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  height: 150,
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Text(
                      _text.isEmpty ? 'Speech will appear here' : _text,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.greenAccent,
                        fontFamily: 'Courier',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Start/Stop va Stop Device tugmalari
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(

                      label: Text(_isListening ? "Stop" : "Start"),
                      onPressed: _listen,
                    ),
                    ElevatedButton(
                      onPressed: stopDevice,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white38),
                      child: const Text("Stop Device"),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                // Qo'lda text kiritish va Send tugmasi
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (val) => _manualText = val,
                        decoration: const InputDecoration(
                          labelText: "Enter text manually",
                          filled: true,
                          fillColor: Colors.white70,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (_manualText.isNotEmpty) {
                          sendToESP32(_manualText);
                        }
                      },
                      child: const Text("Send"),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ENG/UZB tugmasi tepada o'ng burchakda
          Positioned(
            top: 40,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _language = _language == 'en-US' ? 'uz-UZ' : 'en-US';
                });
              },
              child: Text(_language == 'en-US' ? 'ENG' : 'UZB'),
            ),
          ),
        ],
      ),
    );
  }
}
