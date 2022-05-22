import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:rxdart/rxdart.dart';



class Songs extends StatefulWidget {
  const Songs({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<Songs> createState() => _SongsState();
}

class _SongsState extends State<Songs> {

  //определяем аудио плагин
  final OnAudioQuery _audioQuery = OnAudioQuery();
  //плеер
  final AudioPlayer _audioPlayer  = AudioPlayer();

  //переменные
  List<SongModel> songs = [];
  String currentSongTitle = '';
  int currentIndex = 0;

  bool isPlayerViewVisible = false;

  // метод для установки видимости игрока
  void _changePlayerViewVisibility(){
    setState(() {
      isPlayerViewVisible = !isPlayerViewVisible;
    });
  }

  //поток состояний продолжительности
  Stream<DurationState> get _durationStateStream =>
      Rx.combineLatest2<Duration, Duration?, DurationState>(
          _audioPlayer.positionStream, _audioPlayer.durationStream, (position, duration) => DurationState(
          position: position, total: duration?? Duration.zero
      ));

  //запрос на разрешение у initStateMethod
  @override
  void initState() {
    super.initState();
    requestStoragePermission();

    //обновление текущего индекса воспроизводимой песни
    _audioPlayer.currentIndexStream.listen((index) {
      if(index != null){
        _updateCurrentPlayingSongDetails(index);
      }
    });
  }

  //уничтожить плеер , когда закончится трек
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(isPlayerViewVisible){
      return Scaffold(
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 56.0, right: 20.0, left: 20.0),
            child: Column(
              children: <Widget>[
                //кнопка выхода
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(
                      child: InkWell(
                        onTap: _changePlayerViewVisibility,
                        //скрывает плеер
                        child:  Container(
                          padding: const EdgeInsets.all(10.0),
                          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white70,),
                        ),
                      ),
                    ),

                  ],
                ),

                //картинка
                Container(
                    width: 300,
                    height: 300,
                    margin: const EdgeInsets.only(top: 50, bottom: 30),
                    child: Image.asset("assets/darkTheme.jpg")

                ),
                //слайдер
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.zero,
                      margin: const EdgeInsets.only(top: 120, bottom: 2.0),
                      child: StreamBuilder<DurationState>(
                        stream: _durationStateStream,
                        builder: (context, snapshot){
                          final durationState = snapshot.data;
                          final progress = durationState?.position?? Duration.zero;
                          final total = durationState?.total ?? Duration.zero;

                          return ProgressBar(
                            progress: progress,
                            total: total,
                            barHeight: 5.0,
                            progressBarColor: Colors.red,
                            thumbColor:  Colors.red,
                            timeLabelTextStyle: const TextStyle(
                              fontSize: 0,
                            ),
                            onSeek: (duration){
                              _audioPlayer.seek(duration);
                            },
                          );
                        },
                      ),
                    ),

                    //позиция
                    StreamBuilder<DurationState>(
                      stream: _durationStateStream,
                      builder: (context, snapshot){
                        final durationState = snapshot.data;
                        final progress = durationState?.position?? Duration.zero;
                        final total = durationState?.total ?? Duration.zero;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Flexible(
                              child: Text(
                                progress.toString().split(".")[0],
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                total.toString().split(".")[0],
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                Flexible(
                  child: Text(
                    currentSongTitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  flex: 5,
                ),


                //кнопки плеера
                Container(
                  margin: const EdgeInsets.only(top: 50, bottom: 20),
                  child: Row(
                    mainAxisAlignment:  MainAxisAlignment.spaceAround,
                    children: [
                      Flexible(
                        child: InkWell(
                          onTap: (){
                            _audioPlayer.setShuffleModeEnabled(true);
                            notification(context, "Shuffling enabled");
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            child: const Icon(Icons.shuffle, color: Colors.red,),
                          ),
                        ),
                      ),

                      Flexible(
                        //облдасть, которая реагирует на прикосновение
                        child: InkWell(
                          onTap: (){
                            if(_audioPlayer.hasPrevious){
                              _audioPlayer.seekToPrevious();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            child: const Icon(
                              Icons.skip_previous,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),


                      Flexible(
                        child: InkWell(
                          onTap: (){
                            if(_audioPlayer.playing){
                              _audioPlayer.pause();
                            }else{
                              if(_audioPlayer.currentIndex != null){
                                _audioPlayer.play();
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20.0),
                            child: StreamBuilder<bool>(
                              stream: _audioPlayer.playingStream,
                              builder: (context, snapshot){
                                bool? playingState = snapshot.data;
                                if(playingState != null && playingState){
                                  return const Icon(Icons.pause_circle_outline, size: 40, color: Colors.red,);
                                }
                                return const Icon(Icons.play_arrow_outlined, size: 40, color: Colors.red,);
                              },
                            ),
                          ),
                        ),
                      ),


                      Flexible(
                        child: InkWell(
                          onTap: (){
                            if(_audioPlayer.hasNext){
                              _audioPlayer.seekToNext();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            child: const Icon(Icons.skip_next, color: Colors.red,),
                          ),
                        ),
                      ),
                      Flexible(
                        child: InkWell(
                          onTap: (){
                            _audioPlayer.loopMode == LoopMode.one ? _audioPlayer.setLoopMode(LoopMode.all) : _audioPlayer.setLoopMode(LoopMode.one);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            child: StreamBuilder<LoopMode>(
                              stream: _audioPlayer.loopModeStream,
                              //каждый build метод может вызываться в каждом кадре
                              builder: (context, snapshot){
                                final loopMode = snapshot.data;
                                if(LoopMode.one == loopMode){
                                  return const Icon(Icons.repeat_one, color: Colors.red,);
                                }
                                return const Icon(Icons.repeat, color: Colors.redAccent,);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                ),


                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      //переход к плейлисту
                      Flexible(
                        child: InkWell(
                          onTap: (){_changePlayerViewVisibility();},
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            child: const Icon(Icons.list_alt, color: Colors.red,),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        // Здесь мы берем значение из объекта MyHomePage, который был создан
        // метод App.build и используем его для установки заголовка панели приложений.
        title: Text(widget.title),
        elevation: 20,
      ),
      body: FutureBuilder<List<SongModel>>(
        future: _audioQuery.querySongs(
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        ),
        builder: (context, item){
          //индикатор загрузки контента
          if(item.data == null){
            return const Center(child: CircularProgressIndicator(),);
          }
          //песни не найдены
          //является ли строка пустой
          if(item.data!.isEmpty){
            return const Center(child: Text("No Found's"),);
          }
          songs.clear();
          songs = item.data!;
          return ListView.builder(
            //количество скаченных треков
              itemCount: item.data!.length,
              itemBuilder: (context, index){

                return ListTile(
                  title: Text(item.data![index].title),
                  subtitle: Text(item.data![index].artist??"No Artist"),
                  trailing: const Icon(Icons.more_vert),
                  leading: const CircleAvatar(
                    child:Icon(Icons.music_note),

                  ),
                  onTap: () async {
                    // показываем вид игрока
                    _changePlayerViewVisibility();

                    notification(context, "Playing:  " + item.data![index].title);
                    // Попытаться загрузить аудио из источника и отловить все ошибки.
                    //  String? uri = item.data![index].uri;
                    // await _player.setAudioSource(AudioSource.uri(Uri.parse(uri!)));
                    await _audioPlayer.setAudioSource(
                        createPlaylist(item.data!),
                        initialIndex: index
                    );
                    await _audioPlayer.play();
                  }
                );
              }
          );
        },
      ),
    );
  }
  //всплывающие уведомление
  void notification (BuildContext context, String text){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
    ));
  }

  void requestStoragePermission() async {
    //только если платформа не является веб-сайтом, потому что веб-сайт не имеет разрешений
    if(!kIsWeb){
      bool permissionStatus = await _audioQuery.permissionsStatus();
      if(!permissionStatus){
        await _audioQuery.permissionsRequest();
      }
      //вызов сборки
      setState(() { });
    }
  }

  //создание плейлиста
  ConcatenatingAudioSource createPlaylist(List<SongModel> songs) {
    List<AudioSource> sources = [];
    for (var song in songs){
      sources.add(AudioSource.uri(Uri.parse(song.uri!)));
    }
    return ConcatenatingAudioSource(children: sources);
  }

  //обновить информацию о воспроизводимой песне
  void _updateCurrentPlayingSongDetails(int index) {
    setState(() {
      if(songs.isNotEmpty){
        currentSongTitle = songs[index].title;
        currentIndex = index;
      }
    });
  }

}
//класс продолжительности
class DurationState{
  DurationState({this.position = Duration.zero, this.total = Duration.zero});
  Duration position, total;
}