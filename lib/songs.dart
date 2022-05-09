import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geass/ScreenPlaying/player.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';


class Songs extends StatefulWidget {
  const Songs({Key? key}) : super(key: key);

  @override
  State<Songs> createState() => _SongsState();
}

class _SongsState extends State<Songs> {
  final OnAudioQuery _audioQuery = new OnAudioQuery();
  final AudioPlayer _audioPlayer =new AudioPlayer();

  //поверка на целостность музыки
  playSongs(String? uri){
    try{
      _audioPlayer.setAudioSource(AudioSource.uri( Uri.parse(uri!)));
      _audioPlayer.play();
    } on Exception{
      log("Error parsing song");
    }

  }

  @override
  void initState(){
    super.initState();
    requstPermission();
  }

  void requstPermission(){
    Permission.storage.request();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Geass"),
        actions: [
          IconButton(
              onPressed: (){},
              icon: const Icon(Icons.search_outlined),
          ),
        ],
      ),
        
        body: FutureBuilder<List<SongModel>>(
          future: _audioQuery.querySongs(
          sortType: null,
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        ),
        builder: (context, item) {
          if (item.data == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (item.data!.isEmpty) {
            return const Center(
              child: Text("Notging found"),
            );
          }
          return ListView.builder(


            //количество скаченных треков
            itemCount: item.data!.length,
            itemBuilder: (context, index){
                 return ListTile(

                  title: Text(item.data![index].title),
                  subtitle: Text(item.data![index].artist ?? "Ben"),
                  trailing: const Icon(Icons.more_horiz),
                  leading:const CircleAvatar(
                    child:Icon(Icons.music_note),
                ),
                  onTap: (){
                   //playSongs(item.data![index].uri);
                    // обработка возращения назад
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context)=>Player(
                              songmodel:item.data![index],
                              audioPlayer: _audioPlayer,
                            ),

                        ),
                    );
                  },
                 );
            },
          );
        },
      ),
    );
  }
}
