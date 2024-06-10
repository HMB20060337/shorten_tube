import 'dart:developer';
import 'package:ai_youtube/features/main/repositories/summaries_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Summaries extends ConsumerStatefulWidget {
  const Summaries(this.summariesModel, {super.key});
  final SummariesModel summariesModel;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SummariesState();
}

class _SummariesState extends ConsumerState<Summaries> {
  late YoutubePlayerController _controller;
  late TextEditingController _idController;
  late TextEditingController _seekToController;
  Duration parseDuration(String timeString) {
    // Zaman stringini saat, dakika, saniye ve milisaniyelere ayırıyoruz
    List<String> parts = timeString.split(':');
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);

    // Saniye ve milisaniye kısmını virgülden ayırıyoruz
    List<String> secParts = parts[2].split('.');
    int seconds = int.parse(secParts[0]);

    // Duration nesnesini oluşturuyoruz
    return Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    );
  }
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String twoDigitHours = twoDigits(duration.inHours.remainder(24));

    return "${twoDigitHours}:${twoDigitMinutes}:${twoDigitSeconds}";
  }

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId:
          YoutubePlayer.convertUrlToId(widget.summariesModel.youtubeLink)!,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    );
    _idController = TextEditingController();
    _seekToController = TextEditingController();
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    _idController.dispose();
    _seekToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.width / 16 * 9,
              child: Stack(
                children: [
                  YoutubePlayer(
                    controller: _controller,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: Colors.blueAccent,
                    topActions: <Widget>[
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          _controller.metadata.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.settings,
                          color: Colors.white,
                          size: 25.0,
                        ),
                        onPressed: () {
                          log('Settings Tapped!');
                        },
                      ),
                    ],
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50.0),
                      child: Row(
                        children: [
                          Expanded(child: GestureDetector(
                            onDoubleTap: () {
                              _controller.seekTo(_controller.value.position -
                                  const Duration(seconds: 10));
                            },
                          )),
                          const SizedBox(
                            width: 150,
                          ),
                          Expanded(child: GestureDetector(
                            onDoubleTap: () {
                              _controller.seekTo(_controller.value.position +
                                  const Duration(seconds: 10));
                            },
                          ))
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: widget.summariesModel.summaries.length,
                  padding: const EdgeInsets.only(top: 10),
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        var durat = parseDuration(widget
                            .summariesModel.summaries.keys
                            .toList()[index]
                            .first);
                        log(durat.toString());

                        _controller.seekTo(durat);
                      },
                      title: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${formatDuration(parseDuration(widget
                                  .summariesModel.summaries.keys
                                  .toList()[index]
                                  .first))} - ${formatDuration(parseDuration(widget
                                  .summariesModel.summaries.keys
                                  .toList()[index]
                                  .last))}",
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                  color:
                                      const Color.fromARGB(255, 31, 54, 182)),
                            ),

                            const SizedBox(
                                height:
                                    10), // İsteğe bağlı, metinler arasındaki boşluğu ayarlar
                            Text(
                              widget.summariesModel.summaries.values
                                  .toList()[index],
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}
