import 'dart:async';

import 'package:flutter/material.dart';
import 'musique.dart';
import 'package:audioplayers/audioplayers.dart' ;

void main() {
  runApp(const MyHome());
}

class MyHome extends StatelessWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eric music',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Eso music'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Musique> listeDeMusique = [
    Musique('MAL A LA VIE', 'DIDI B', 'assets/image1.JPG',
        'https://codabee.com/wp-content/uplaods/2018/06/un.mp3'),
    Musique('LARGENT', 'DADJU', 'assets/image1.JPG',
        'https://codabee.com/wp-content/uplaods/2018/06/deux.mp3'),
  ];

  late Musique maMusique;
  late AudioPlayer audioPlayer;
  late StreamSubscription<Duration> positionSub;
  late StreamSubscription<PlayerState> stateSubscription;
  Duration position = const Duration(seconds: 0);
  Duration duree = const Duration(seconds: 10);
  Etat statut = Etat.STOPPED;
  int index = 0;

  @override
  void initState() {
    super.initState();
    maMusique = listeDeMusique[index];
    configurationAudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        centerTitle: true,
        title: const Text(
          'Eso music',
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Colors.grey[800],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Card(
              elevation: 9.5,
              child: Container(
                width: MediaQuery.of(context).size.height / 2.5,
                // height: 10,
                child: Image.asset(maMusique.imagePath),
              ),
            ),
            textAvecStyle(maMusique.titre, 1.5),
            textAvecStyle(maMusique.artiste, 1.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                bouton(Icons.fast_rewind, 35.0, ActionMusique.rewind),
                bouton(
                    (statut == PlayerState.playing)
                        ? Icons.pause
                        : Icons.play_arrow,
                    45.0,
                    (statut == PlayerState.playing)
                        ? ActionMusique.pause
                        : ActionMusique.play),
                bouton(Icons.fast_forward, 35.0, ActionMusique.forward)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                textAvecStyle(formDuration(position), 0.8),
                textAvecStyle(formDuration(duree), 0.8)
              ],
            ),
            Slider(
                value: position.inSeconds.toDouble(),
                inactiveColor: Colors.white,
                activeColor: Colors.red,
                min: 0.0,
                max: duree.inSeconds.toDouble(),
                onChanged: (double d) {
                  setState(() {
                   audioPlayer.seek(d as Duration);
                  });
                })
          ],
        ),
      ),
    );
  }

  // ma fonction pour les textes
  Text textAvecStyle(String data, double scale) {
    return Text(
      data,
      // ignore: deprecated_member_use
      textScaleFactor: scale,
      textAlign: TextAlign.center,
      style: const TextStyle(
          color: Colors.white, fontSize: 15.0, fontStyle: FontStyle.italic),
    );
  }

  //fonction bouton
  IconButton bouton(IconData icone, double taille, ActionMusique action) {
    return IconButton(
      iconSize: taille,
      color: Colors.white,
      icon: Icon(icone),
      onPressed: () {
        switch (action) {
          case ActionMusique.play:
            play();
            break;
          case ActionMusique.pause:
            pause();
            break;
          case ActionMusique.rewind:
            rewind();
            break;
          case ActionMusique.forward:
            forward();
            break;
        }
      },
    );
  }

  

  //fonction de configuration de l'audio
  void configurationAudioPlayer() {
    audioPlayer = AudioPlayer();
    // si la position de l'audio change il mettra à jour mon slider
    positionSub = audioPlayer.onPositionChanged.listen((pos) {
      setState(() => position = pos);
    });

    stateSubscription = audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == Etat.PLAYING) {
        setState(() {
          // duree = audioPlayer.duration!;
        });
      } else if (state == Etat.STOPPED) {
        setState(() {
          statut = Etat.STOPPED;
          duree = const Duration(seconds: 0);
          position = const Duration(seconds: 0);
        });
      }
    }, onError: (message) {
      print('error: $message');
      setState(() {
        statut = Etat.STOPPED;
        duree = const Duration(seconds: 0);
        position = const Duration(seconds: 0);
      });
    });
    // Écoute de l'événement onDurationChanged pour obtenir la durée de la piste audio
  audioPlayer.onDurationChanged.listen((Duration duration) {
    setState(() {
      duree = duration;
    });
  });
  }

  Future play() async {
    await audioPlayer.play(UrlSource(maMusique.urlSong));
    setState(() {
      statut = Etat.PLAYING;
    });
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() {
      statut = Etat.PAUSED;
    });
  }

  void forward(){
    if(index == listeDeMusique.length -1){
      index = 0;
    } else{
      index++;
    }
    maMusique = listeDeMusique[index];
    audioPlayer.stop();
    configurationAudioPlayer();
    play();
  }
  void rewind(){
    if(position > const Duration(seconds: 3)){
      audioPlayer.seek(0.0 as Duration);
    }else{
      if (index == 0){
        index = listeDeMusique.length - 1;
      }else{
        index--;
      }
    maMusique = listeDeMusique[index];
    audioPlayer.stop();
    configurationAudioPlayer();
    play();
    }
  
  }

  String formDuration(Duration duree){
    return duree.toString().split('.').first;
  }

}


//fonction action musique
enum ActionMusique {
  play,
  pause,
  rewind,
  forward,
}

enum Etat {
  PLAYING,
  STOPPED,
  PAUSED,
}
