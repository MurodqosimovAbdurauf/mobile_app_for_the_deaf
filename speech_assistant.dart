import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class SpeechAssistantPage extends StatefulWidget {
  @override
  _SpeechAssistantPageState createState() => _SpeechAssistantPageState();
}

class _SpeechAssistantPageState extends State<SpeechAssistantPage> {
  late stt.SpeechToText _speech;
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _textController = TextEditingController();

  bool _isListening = false;
  bool _isSpeaking = false; // <= Yangi flag
  String _recognizedText = '';
  List<String> _responses = [];

  String _languageCode = 'en-GB';
  String _voiceGender = 'female';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _configureTts() async {
    await _flutterTts.setLanguage(_languageCode);

    if (_languageCode == 'en-GB') {
      if (_voiceGender == 'male') {
        await _flutterTts.setVoice({
          "name": "en-GB-language",
          "locale": "en-GB",
        });
        await _flutterTts.setPitch(0.6);
        await _flutterTts.setSpeechRate(0.7);
      } else {
        await _flutterTts.setVoice({
          "name": "Google UK English Female",
          "locale": "en-GB",
        });
        await _flutterTts.setPitch(1.1);
        await _flutterTts.setSpeechRate(0.7);
      }
    } else if (_languageCode == 'uz-UZ') {
      if (_voiceGender == 'male') {
        await _flutterTts.setVoice({
          "name": "uz-UZ-male",
          "locale": "uz-UZ",
        });
        await _flutterTts.setPitch(0.6);
        await _flutterTts.setSpeechRate(0.7);
      } else {
        await _flutterTts.setVoice({
          "name": "uz-UZ-female",
          "locale": "uz-UZ",
        });
        await _flutterTts.setPitch(1.1);
        await _flutterTts.setSpeechRate(0.7);
      }
    }
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => debugPrint('Status: $status'),
      onError: (error) => debugPrint('Error: $error'),
    );

    if (available && !_isSpeaking) {
      setState(() => _isListening = true);
      _speech.listen(
        localeId: _languageCode,
        onResult: (val) {
          if (!_isSpeaking) {
            setState(() {
              _recognizedText = val.recognizedWords;
              _responses = _generateResponses(_recognizedText);
            });
          }
        },
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
      );
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  void _toggleListening() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  List<String> _generateResponses(String input) {
    input = input.toLowerCase();
    if (input.contains('how are you')) {
      return ['Fine', 'Not good', 'I feel great'];
    }
    else if (input.contains('hello') || input.contains('hi')) {
      return ['Hi there!', 'Hello!', 'Good to see you!'];
    } else if (input.contains('how are you')) {
      return ['I\'m fine, thanks!', 'Doing well, how about you?'];
    } else if (input.contains('what is your name')) {
      return ['I\'m your assistant!', 'You can call me whatever you like.'];
    } else if (input.contains('thank you') || input.contains('thanks')) {
      return ['You\'re welcome!', 'No problem!', 'Anytime!'];
    } else if (input.contains('please')) {
      return ['Of course!', 'Sure!', 'No problem!'];
    } else if (input.contains('sorry')) {
      return ['It\'s okay!', 'No worries!', 'Don\'t worry about it!'];
    } else if (input.contains('goodbye') || input.contains('bye')) {
      return ['Goodbye!', 'Take care!', 'See you soon!'];
    } else if (input.contains('yes')) {
      return ['Yes!', 'Absolutely!', 'Of course!'];
    } else if (input.contains('no')) {
      return ['No.', 'Not really.', 'Unfortunately not.'];
    } else if (input.contains('ok') || input.contains('okay')) {
      return ['Okay!', 'Sounds good!', 'Got it!'];
    } else if (input.contains('what time is it')) {
      return ['I\'m not sure, please check your phone or watch.'];
    } else if (input.contains('what day is it')) {
      return ['Today is a great day!', 'Let me check for you.'];
    } else if (input.contains('what are you doing')) {
      return ['Just helping you out!', 'Waiting for your message.','Nothing'];
    } else if (input.contains('who are you')) {
      return ['I\'m an assistant to help with communication.'];
    } else if (input.contains('can you help me')) {
      return ['Yes, I can help!', 'Sure, what do you need?'];
    } else if (input.contains('I need help')) {
      return ['I\'m here to help!', 'What can I do for you?'];
    } else if (input.contains('how old are you')) {
      return ['I don\'t have an age.', 'I\'m timeless!'];
    } else if (input.contains('do you speak')) {
      return ['Yes, I can understand and reply.'];
    } else if (input.contains('where are you from')) {
      return ['I\'m from the digital world!'];
    } else if (input.contains('good morning')) {
      return ['Good morning!', 'Have a great day!'];
    } else if (input.contains('good afternoon')) {
      return ['Good afternoon!', 'Hope your day is going well!'];
    } else if (input.contains('good evening')) {
      return ['Good evening!', 'How was your day?'];
    } else if (input.contains('good night')) {
      return ['Good night!', 'Sleep well!'];
    } else if (input.contains('how was your day')) {
      return ['Pretty good, thank you!', 'It was nice!'];
    } else if (input.contains('I love you')) {
      return ['That\'s sweet!', 'Love you too!'];
    } else if (input.contains('I miss you')) {
      return ['I miss you too!', 'Hope to see you soon!'];
    } else if (input.contains('what is that')) {
      return ['Can you point to it?', 'Please describe it.'];
    } else if (input.contains('where is it')) {
      return ['Over there?', 'Let me help you find it.'];
    } else if (input.contains('come here')) {
      return ['I\'m coming!', 'On my way!'];
    } else if (input.contains('go there')) {
      return ['Okay!', 'I will go.'];
    } else if (input.contains('sit down')) {
      return ['Okay, sitting.', 'Sure!'];
    } else if (input.contains('stand up')) {
      return ['Standing now!', 'Got it!'];
    } else if (input.contains('wait')) {
      return ['Okay, I will wait.', 'Sure, take your time.'];
    } else if (input.contains('hurry up')) {
      return ['I\'ll be quick!', 'Coming fast!'];
    } else if (input.contains('what happened')) {
      return ['I\'m not sure.', 'Can you explain?'];
    } else if (input.contains('are you okay')) {
      return ['Yes, I\'m fine!', 'All good, thank you!'];
    } else if (input.contains('do you understand')) {
      return ['Yes, I understand.', 'I get it!'];
    } else if (input.contains('I don\'t understand')) {
      return ['Let me explain.', 'No problem, I\'ll repeat.'];
    } else if (input.contains('repeat please')) {
      return ['Sure, here it is again.', 'Let me say that again.'];
    } else if (input.contains('slow down')) {
      return ['Okay, speaking slowly.', 'Got it.'];
    } else if (input.contains('what do you want')) {
      return ['Just to help!', 'I want to assist you.'];
    } else if (input.contains('do you like me')) {
      return ['Of course!', 'Yes, you\'re great!'];
    } else if (input.contains('I am hungry')) {
      return ['Let\'s get some food!', 'Time to eat!'];
    } else if (input.contains('I am thirsty')) {
      return ['Drink some water!', 'Let\'s get something to drink.'];
    } else if (input.contains('I am tired')) {
      return ['You should rest.', 'Take a break!'];
    } else if (input.contains('I am happy')) {
      return ['That\'s great!', 'I\'m happy for you!'];
    } else if (input.contains('I am sad')) {
      return ['I\'m here for you.', 'Don’t worry, things will get better.'];
    } else if (input.contains('I am angry')) {
      return ['Take a deep breath.', 'Let’s calm down.'];
    } else if (input.contains('let\'s go')) {
      return ['Yes, let\'s move!', 'Ready when you are!'];
    } else if (input.contains('come with me')) {
      return ['Sure!', 'Let\'s go together.'];
    } else if (input.contains('do you want to eat')) {
      return ['Yes, let’s eat!', 'I’m hungry too.'];
    } else if (input.contains('do you want to drink')) {
      return ['Yes, let’s get something to drink!'];
    } else if (input.contains('do you want to go')) {
      return ['Yes, let’s go!', 'Where to?'];
    } else if (input.contains('what are you doing')) {
      return ['Just waiting for you!', 'Listening.'];
    } else if (input.contains('I\'m fine')) {
      return ['Great to hear!', 'Glad you’re okay!'];
    } else if (input.contains('where are you')) {
      return ['I’m right here!', 'Next to you!'];
    } else if (input.contains('can you repeat')) {
      return ['Sure!', 'Here it is again.'];
    } else if (input.contains('open the door')) {
      return ['Okay!', 'Opening now.'];
    } else if (input.contains('close the door')) {
      return ['Got it!', 'Closing now.'];
    } else if (input.contains('what do you think')) {
      return ['I think it’s great!', 'Interesting question.'];
    } else if (input.contains('do you agree')) {
      return ['Yes, I agree.', 'I think so too.'];
    } else if (input.contains('tell me more')) {
      return ['Sure!', 'Here’s more info.'];
    } else if (input.contains('what did you say')) {
      return ['Let me repeat.', 'Here it is again.'];
    } else if (input.contains('nice to meet you')) {
      return ['Nice to meet you too!', 'Pleasure to meet you!'];
    } else if (input.contains('see you later')) {
      return ['See you!', 'Talk to you later!'];
    } else if (input.contains('take care')) {
      return ['You too!', 'Stay safe!'];
    } else if (input.contains('be careful')) {
      return ['Thanks!', 'I will!'];
    } else if (input.contains('good job')) {
      return ['Thank you!', 'You did well too!'];
    } else if (input.contains('well done')) {
      return ['Appreciate it!', 'Thanks a lot!'];
    } else if (input.contains('congratulations')) {
      return ['Thanks!', 'Yay!'];
    } else if (input.contains('do you know')) {
      return ['Maybe!', 'What is it about?'];
    } else if (input.contains('what is your favorite')) {
      return ['Hard to choose!', 'I like many things.'];
    } else if (input.contains('what do you mean')) {
      return ['Let me explain.', 'I mean...'];
    } else if (input.contains('really')) {
      return ['Yes!', 'It’s true!'];
    } else if (input.contains('I am busy')) {
      return ['Alright!', 'Talk later!'];
    } else if (input.contains('I have to go')) {
      return ['Okay, take care!', 'See you!'];
    } else if (input.contains('just a moment')) {
      return ['Sure!', 'I’ll wait.'];
    } else if (input.contains('do you want to play')) {
      return ['Yes!', 'Let’s play!'];
    } else if (input.contains('what is your favorite color')) {
      return ['I like blue!', 'Colors are fun!'];
    } else if (input.contains('tell me a joke')) {
      return ['Why don’t skeletons fight each other? They don’t have the guts.'];
    }
    else if (input.contains('salom') || input.contains('hi')) {
      return ['salom!', 'Salom, qanday yuribsiz?', 'Sizni ko‘rib xursandman!','valeykum assalom'];
    } else if (input.contains('qandaysiz')) {
      return ['Yaxshiman, rahmat!', 'Yaxshi, sizchi?'];
    } else if (input.contains('isming nima')) {
      return ['Ismimni ayta olmayman', 'Sizga aytolmayman'];
    } else if (input.contains('rahmat')) {
      return ['Arzimaydi!', 'Muammo yo‘q!', 'Har doim yordamga tayyorman!'];
    } else if (input.contains('iltimos')) {
      return ['Albatta!', 'Bo‘ladi!', 'Hech gap emas!'];
    } else if (input.contains('kechirasiz')) {
      return ['Mayli!', 'Hechqisi yo‘q!', 'Xavotir olmang!'];
    } else if (input.contains('xayr') || input.contains('salomat bo‘ling')) {
      return ['Xayr!', 'Omon bo‘ling!', 'Ko‘rishguncha!'];
    } else if (input.contains('ha')) {
      return ['Ha!', 'Albatta!', 'Shubhasiz!'];
    } else if (input.contains('yo‘q')) {
      return ['Yo‘q.', 'Unchalik emas.', 'Afsuski yo‘q.'];
    } else if (input.contains('ok') || input.contains('mayli')) {
      return ['Mayli!', 'Yaxshi!', 'Tushundim!'];
    } else if (input.contains('soat nechchi')) {
      return ['Aniq emas, iltimos telefon yoki soatingizni tekshiring.'];
    } else if (input.contains('bugun qaysi kun')) {
      return ['Bugun ajoyib kun!', 'Tekshirib ko‘ray.'];
    } else if (input.contains('nima qilayapsan')) {
      return ['Sizga yordam beryapman!', 'Xabaringizni kutyapman.', 'Hech narsa.'];
    } else if (input.contains('sen kimsan')) {
      return ['Men aloqa uchun yordamchiman.'];
    } else if (input.contains('yordam bera olasanmi')) {
      return ['Ha, yordam bera olaman!', 'Albatta, nima kerak?'];
    } else if (input.contains('menga yordam kerak')) {
      return ['Yordam berishga tayyorman!', 'Nima qilay?'];
    } else if (input.contains('yoshing nechida')) {
      return ['Yoshimni nima qilasiz.', 'Men abadiyman!'];
    } else if (input.contains('gapira olasanmi')) {
      return ['Ha, tushunaman va javob bera olaman.','gapirish men uchun qiyin'];
    } else if (input.contains('qayerdansan')) {
      return ['shu yerdaman','kochadaman'];
    } else if (input.contains('xayrli tong')) {
      return ['Xayrli tong!', 'Yaxshi kun bo‘lsin!'];
    } else if (input.contains('xayrli kun')) {
      return ['Xayrli peshin!', 'Kuningiz yaxshi o‘tyaptimi?'];
    } else if (input.contains('xayrli kech')) {
      return ['Xayrli kech!', 'Kuningiz qanday o‘tdi?'];
    } else if (input.contains('xayrli tun')) {
      return ['Xayrli tun!', 'Shirin uxlang!'];
    } else if (input.contains('kunning qanday o‘tdi')) {
      return ['Yaxshi o‘tdi, rahmat!', 'Ajoyib edi!'];
    } else if (input.contains('men seni yaxshi ko‘raman')) {
      return ['Bu juda yoqimli!', 'Men ham sizni yaxshi ko‘raman!'];
    } else if (input.contains('sog‘indim')) {
      return ['Men ham sog‘indim!', 'Yaqinda ko‘rishamiz!'];
    } else if (input.contains('bu nima')) {
      return ['Ko‘rsatib bera olasizmi?', 'Iltimos, ta’riflab bering.'];
    } else if (input.contains('qayerda')) {
      return ['U yerda emasmi?', 'Topishga yordam beraman.'];
    } else if (input.contains('bu yerga kel')) {
      return ['Kelyapman!', 'Yo‘lga tushdim!'];
    } else if (input.contains('u yerga bor')) {
      return ['Mayli!', 'Boraman.'];
    } else if (input.contains('o‘tir')) {
      return ['Mayli, o‘tiray.', 'Bo‘ldi!'];
    } else if (input.contains('tur')) {
      return ['Turdim!', 'Tushundim!'];
    } else if (input.contains('kut')) {
      return ['Mayli, kutaman.', 'Shoshilmay turing.'];
    } else if (input.contains('tezroq')) {
      return ['Tez bo‘laman!', 'Shoshilyapman!'];
    } else if (input.contains('nima bo‘ldi')) {
      return ['Aniq emas.', 'Tushuntirib bera olasizmi?'];
    } else if (input.contains('yaxshimisiz')) {
      return ['Ha, yaxshiman!', 'Hammasi joyida, rahmat!'];
    } else if (input.contains('tushunyapsanmi')) {
      return ['Ha, tushunyapman.', 'Tushundim!'];
    } else if (input.contains('tushunmadim')) {
      return ['Tushuntiraman.', 'Muammo yo‘q, qaytaraman.'];
    } else if (input.contains('qaytaring')) {
      return ['Bo‘ladi, yana aytaman.', 'Qaytaramiz.'];
    } else if (input.contains('sekinroq')) {
      return ['Mayli, sekinroq gapiraman.', 'Tushundim.','hop'];
    } else if (input.contains('nima xohlaysan')) {
      return ['Faqat yordam bermoqchiman!', 'Sizga yordam bermoqchiman.'];
    } else if (input.contains('meni yoqtirasanmi')) {
      return ['Albatta!', 'Ha, siz zo‘rsiz!'];
    } else if (input.contains('och qoldim')) {
      return ['Oziq-ovqat olaylik!', 'Ovqatlanish vaqti!'];
    } else if (input.contains('chanqadim')) {
      return ['Suv iching!', 'Ichimlik olib kelaylik.'];
    } else if (input.contains('charchadim')) {
      return ['Dam olishingiz kerak.', 'Biroz dam oling!'];
    } else if (input.contains('hursandman')) {
      return ['Zo‘r-ku!', 'Men ham xursandman!'];
    } else if (input.contains('xafa bo‘ldim')) {
      return ['Men siz bilanman.', 'Xavotir olmang, hammasi yaxshi bo‘ladi.'];
    } else if (input.contains('jahlim chiqdi')) {
      return ['Chuqur nafas oling.', 'Tinchlanamiz.'];
    } else if (input.contains('ketdik')) {
      return ['Ha, ketdik!', 'Tayyorman!'];
    } else if (input.contains('birga yur')) {
      return ['Albatta!', 'Birga boramiz.'];
    } else if (input.contains('ovqat yeysanmi')) {
      return ['Ha, yeylik!', 'Men ham ochman.'];
    } else if (input.contains('ichasanmi')) {
      return ['Ha, nimadir ichamiz!'];
    } else if (input.contains('borasanmi')) {
      return ['Ha, boramiz!', 'Qayerga?'];
    } else if (input.contains('nimadir qilyapsanmi')) {
      return ['Faqat sizni kutyapman!', 'Tinglayapman.'];
    } else if (input.contains('yaxshiman')) {
      return ['Ajoyib!', 'Yaxshi ekan!'];
    } else if (input.contains('qayerdasan')) {
      return ['Mana shu yerdaman!', 'Yonimda!'];
    } else if (input.contains('qaytaring iltimos')) {
      return ['Bo‘ldi!', 'Yana bir bor aytaman.'];
    } else if (input.contains('eshikni och')) {
      return ['Mayli!', 'Ochilyapti.'];
    } else if (input.contains('eshikni yop')) {
      return ['Tushundim!', 'Yopilyapti.'];
    } else if (input.contains('nima deb o‘ylaysan')) {
      return ['Menimcha zo‘r!', 'Qiziqarli savol.'];
    } else if (input.contains('rozi bo‘ldingmi')) {
      return ['Ha, roziyman.', 'Men ham shunday o‘ylayman.'];
    } else if (input.contains('ko‘proq ayt')) {
      return ['Bo‘ladi!', 'Yana ma’lumot beraman.'];
    } else if (input.contains('nima deding')) {
      return ['Qaytaray.', 'Yana aytaman.'];
    } else if (input.contains('tanishganimdan xursandman')) {
      return ['Men ham xursandman!', 'Tanishganimdan mamnunman!'];
    } else if (input.contains('ko‘rishamiz')) {
      return ['Ko‘rishguncha!', 'Keyinroq gaplashamiz!'];
    } else if (input.contains('o‘zingni ehtiyot qil')) {
      return ['Siz ham!', 'Salomat bo‘ling!'];
    } else if (input.contains('ehtiyot bo‘l')) {
      return ['Rahmat!', 'Bo‘ladi!'];
    } else if (input.contains('zo‘r ish')) {
      return ['Rahmat!', 'Siz ham yaxshi ishladingiz!'];
    } else if (input.contains('barakalla')) {
      return ['Rahmat!', 'Katta rahmat!'];
    } else if (input.contains('tabriklayman')) {
      return ['Rahmat!', 'Ura!'];
    } else if (input.contains('bilasanmi')) {
      return ['Balki!', 'Nima haqida?'];
    } else if (input.contains('eng yoqtirganing nima')) {
      return ['Tanlash qiyin!', 'Ko‘p narsani yoqtiraman.'];
    } else if (input.contains('nima demoqchisan')) {
      return ['Tushuntiraman.', 'Ya’ni...'];
    } else if (input.contains('rostmi')) {
      return ['Ha!', 'To‘g‘ri!'];
    } else if (input.contains('bandman')) {
      return ['Mayli!', 'Keyin gaplashamiz!'];
    } else if (input.contains('ketishim kerak')) {
      return ['Mayli, o‘zingizni ehtiyot qiling!', 'Ko‘rishguncha!'];
    } else if (input.contains('bir daqiqa')) {
      return ['Bo‘ladi!', 'Kutaman.'];
    } else if (input.contains('o‘ynaymizmi')) {
      return ['Ha!', 'O‘ynaylik!'];
    } else if (input.contains('sevimli ranging nima')) {
      return ['Ko‘k rangni yoqtiraman!', 'Ranglar qiziqarli!'];
    } else if (input.contains('hazil ayt')) {
      return ['Nega skeletlar bir-biri bilan urushmaydi? Chunki ular jasoratga ega emas.'];
    }

    return ['Can you say that again?', 'I am not sure.', 'Let me think...'];
  }

  Future<void> _speak(String message) async {
    _stopListening(); // Pause listening during speech
    _isSpeaking = true;

    await _configureTts();
    await _flutterTts.speak(message);

    // Wait until speech is finished
    _flutterTts.setCompletionHandler(() async {
      _isSpeaking = false;
      if (!_isListening) {
        await _startListening();
      }
    });
  }

  void _speakFromInput() {
    final input = _textController.text.trim();
    if (input.isNotEmpty) {
      _speak(input);
    }
  }

  void _changeLanguage(String langCode) {
    setState(() {
      _languageCode = langCode;
    });
  }

  void _changeVoice(String gender) {
    setState(() {
      _voiceGender = gender;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Speech Assistant'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background2.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                height: 240,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  border: Border.all(color: Colors.deepPurple),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _recognizedText,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ToggleButtons(
                    isSelected: [_languageCode == 'en-GB', _languageCode == 'uz-UZ'],
                    onPressed: (index) {
                      _changeLanguage(index == 0 ? 'en-GB' : 'uz-UZ');
                    },
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('ENG'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('UZ'),
                      ),
                    ],
                  ),
                  ToggleButtons(
                    isSelected: [_voiceGender == 'male', _voiceGender == 'female'],
                    onPressed: (index) {
                      _changeVoice(index == 0 ? 'male' : 'female');
                    },
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('BOY'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('GIRL'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Select a response:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                children: _responses.map((response) {
                  return ElevatedButton(
                    onPressed: () => _speak(response),
                    child: Text(response),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'Enter text to speak',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _speakFromInput,
                icon: const Icon(Icons.volume_up),
                label: const Text('Speak'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(40),
                ),
              ),
              const SizedBox(height: 140),
              ElevatedButton.icon(
                onPressed: _toggleListening,
                icon: Icon(_isListening ? Icons.stop : Icons.mic),
                label: Text(_isListening ? 'Stop Listening' : 'Start Listening'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(40),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    _flutterTts.stop();
    _textController.dispose();
    super.dispose();
  }
}
