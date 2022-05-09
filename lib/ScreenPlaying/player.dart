import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';




class Player extends StatefulWidget {
  const Player({Key? key,  required this.audioPlayer, required this.songmodel}) : super(key: key);
  //передат песню на экран
  final SongModel songmodel;
  // чтобы не создавать аудиоплеер каждый раз
  // и множество включенных трекво не играли сразу
  final AudioPlayer audioPlayer;

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {

  Duration _duration = const Duration();
  // воспроизведение с последней точки
  Duration _position = const Duration();



  bool _isPlsying = false;

  // переопределяем функцию
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    playSong();
  }

  void  playSong() {
   try{
     // widget.audioPlayer - для того, чтобы не пригрывалось несколько треков сразу
     widget.audioPlayer.setAudioSource(
         AudioSource.uri(
             Uri.parse(widget.songmodel.uri!)
         )
     );
     widget.audioPlayer.play();
     _isPlsying = true;
   } on Expanded{
     log("Cannot parsing song");
   }


   //прослушиваем поток
    widget.audioPlayer.durationStream.listen((d) {
      setState(() {
        _duration = d!;
      });
    });
    widget.audioPlayer.positionStream.listen((p) {
      setState(() {
        _position = p;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //кнопка назад
            IconButton(onPressed: () {
              Navigator.pop(context);
            },
              icon: Icon(Icons.arrow_back),
            ),
            
            Center(
              child:Column(
                children: [
                  const CircleAvatar(
                    radius: 120.0,
                    child: Icon(
                      Icons.music_note_outlined,
                      size: 80.0,
                    ),
                  ),
                  const SizedBox(
                    height: 50.0,
                  ),
                   Text(
                  widget.songmodel.displayNameWOExt,
                  overflow: TextOverflow.fade,
                    maxLines: 1,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30.0,
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                   Text(
                    widget.songmodel.artist.toString(),
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    style: TextStyle(
                      //fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  const SizedBox(
                    height: 250.0,
                  ),

                  Row(
                    children: [
                      Text(
                        _position.toString().split(".")[0]
                      ),
                      Expanded(
                          child: Slider(
                            max: _duration.inSeconds.toDouble(),
                            min: const Duration(seconds: 0)
                                .inSeconds
                                .toDouble(),
                              value: _position.inSeconds.toDouble(),
                              onChanged: (value){
                                setState(() {
                                  changeSlider(value.toInt());
                                  value = value;
                                });
                              },
                           ),
                         ),
                      Text(
                        _duration.toString().split(".")[0]
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: (){
                          setState(() {
                            if(_isPlsying){
                              widget.audioPlayer.seekToPrevious();
                            }
                          });
                        },
                        icon: Icon(
                          Icons.skip_previous,
                          size: 40,
                        ),
                      ),
                      IconButton(
                        onPressed: (){
                          setState(() {
                            if (_isPlsying){
                              widget.audioPlayer.pause();
                            }
                            else{
                              widget.audioPlayer.play();
                            }
                            _isPlsying = !_isPlsying;
                          });
                        },
                        icon: Icon(
                          _isPlsying ? Icons.pause_circle_outline:Icons.play_arrow_outlined,
                          size: 40,
                          color: Colors.red[600],
                        ),
                      ),
                      IconButton(
                        onPressed: (){
                          setState(() {
                            if(_isPlsying){
                              widget.audioPlayer.seekToNext();
                            }
                          });
                        },
                        icon: Icon(
                          Icons.skip_next,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      ),
    );
  }
  void changeSlider(int seconds){
    Duration duration = Duration(seconds: seconds);
    widget.audioPlayer.seek(duration);
  }
}
