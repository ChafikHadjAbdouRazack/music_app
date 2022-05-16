import 'dart:async';

import 'package:flutter/material.dart';
import 'music.dart';
import 'package:audioplayers/audioplayers.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Music App'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Music> myMusics = [
    Music("J'ai dit non",'Dadju','images/dadju.jpeg','songs/Dadju_J_ai_dit_non.mp3'),
    Music('Comme un nombre','Gims','images/gims.jpeg','songs/01_Comme_une_ombre.mp3')
  ];
  late StreamSubscription positionsub;
  late StreamSubscription stateSub;
  AudioPlayer audioPlayer = AudioPlayer();
  Duration position = Duration(seconds: 0);
  Duration duration = Duration(seconds: 0);
  PlayerState state = PlayerState.STOPPED;
  late Music myCurrentMusic;
  @override
  void initState(){
    super.initState();
    myCurrentMusic = myMusics[0];
    audioPlayerConfiguration();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey[900],
        title: Text(widget.title),
      ),
      backgroundColor: Colors.grey[800],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Card(
              elevation: 9.0,
              child: Container(
                width: MediaQuery.of(context).size.height/2.5,
                child: Image.asset(myCurrentMusic.imagePath),
              ),
            ),
            textWithStyle(myCurrentMusic.title, 1.5),
            textWithStyle(myCurrentMusic.artist, 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                button(Icons.fast_rewind, 30.0, ActionMusic.rewind),
                button(state == PlayerState.PLAYING ? Icons.pause : Icons.play_arrow, 45.0, state == PlayerState.PLAYING  ? ActionMusic.pause : ActionMusic.play ),
                button(Icons.fast_forward, 30.0, ActionMusic.forward)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                textWithStyle('0:0', 0.8),
                textWithStyle('0:22', 0.8),
              ],
            ),
            Slider(
                value: position.inSeconds.toDouble(),
                min: 0.0,
                max: 30.0,
                inactiveColor: Colors.white,
                activeColor: Colors.red,
                onChanged: (double d){
                    setState((){
                      position = Duration(seconds: d.toInt());
                    });
                }
            )
          ],

        ),
      )
    );
  }
  Text textWithStyle(String data,double scale){
    return Text(
      data,
      textScaleFactor: scale,
      style: TextStyle(
        color: Colors.white,
        fontSize: 20.0,
        fontStyle: FontStyle.italic
      ),
    );
  }

  IconButton button(IconData icon,double taille,ActionMusic action){
        return IconButton(
          iconSize: taille,
           color: Colors.white,
            onPressed: (){
              switch(action){
                case ActionMusic.play:
                  play();
                  break;
                case ActionMusic.pause:
                  pause();
                  break;
                case ActionMusic.rewind:
                  break;
                case ActionMusic.forward:
                  break;
              }
            },
            icon: Icon(icon)
        );
  }
  void audioPlayerConfiguration(){
    positionsub = audioPlayer.onAudioPositionChanged.listen((event) {
                setState(
                    ()=>position = event
                );
    });
    stateSub = audioPlayer.onPlayerStateChanged.listen((event) {
      if(event == PlayerState.PLAYING){
        setState( () async {
          duration  =  Duration(seconds: await audioPlayer.getDuration());
        });
      }
      if(event == PlayerState.STOPPED){
        setState((){
          state = PlayerState.STOPPED;
        });
      }
    },onError: (message){
      print("erreur $message");
      setState((){
        state = PlayerState.STOPPED;
        duration = Duration(seconds: 0);
        position = Duration(seconds: 0);
      });
    });
  }

  Future play() async {
    await audioPlayer.play(myCurrentMusic.songUrl,isLocal: true);
    setState(()=>{state = PlayerState.PLAYING});
  }

  Future pause() async {
    await audioPlayer.pause();
    setState( ()=>{ state = PlayerState.PAUSED } );
  }
}
enum ActionMusic {
  play,
  pause,
  rewind,
  forward
}
enum PayerState {
  playing,
  stopped,
  paused
}
