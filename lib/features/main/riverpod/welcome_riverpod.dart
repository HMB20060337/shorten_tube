import 'dart:convert';

import 'package:ai_youtube/features/main/screens/welcome.dart';
import 'package:ai_youtube/features/main/services/gpt_service.dart';
import 'package:ai_youtube/features/main/services/youtube_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grock/grock.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:xml/xml.dart';

final welcomeRiverpod = ChangeNotifierProvider((ref) => WelcomeNotifier());

class WelcomeNotifier extends ChangeNotifier {
  TextEditingController controller = TextEditingController();
  TextEditingController linkController = TextEditingController();

  var ytService = YtService();
  var gptService = Gpt();
  var box = Hive.box('db');
  Map<List<String>, String> formatMetni(String girdi) {
    Map<List<String>, String> temp = {};
    var jsonStr = cleanJsonString(girdi);
    var tempMap = jsonDecode(jsonStr);
    for (var element in tempMap) {
      var start = element['start'];
      var end = element['end'];
      var summary = element['summary'];
      temp.addAll({
        [start, end]: summary
      });
    }

    return temp;
  }

  String cleanJsonString(String input) {
    // JSON içeriğini belirliyor
    int startIndex = input.indexOf('[');
    int endIndex = input.lastIndexOf(']') + 1;

    // JSON kısmını ayırıyor ve geri döndürüyor
    return input.substring(startIndex, endIndex);
  }

  String formatSure(String sure) {
    // ":" karakterlerini koruyarak süreyi dönüştür
    return sure.replaceAll(RegExp(r'(?<=\d)(?=(\d\d\d)+\b)'), ',');
  }

  List<String> xmlToList(String xmlString) {
    final XmlDocument document = XmlDocument.parse(xmlString);
    final List<XmlNode> texts = document.findAllElements('text').toList();

    List<String> subtitleList = [];

    for (final text in texts) {
      String start = text.getAttribute('start')!;
      String end =
          (double.parse(start) + double.parse(text.getAttribute('dur')!))
              .toString();

      start = Duration(microseconds: (double.parse(start) * 1000000).toInt())
          .toString();
      end = Duration(microseconds: (double.parse(end) * 1000000).toInt())
          .toString();
      // ignore: deprecated_member_use
      final String content = text.text;

      subtitleList.add('$start - $end - $content');
    }

    return subtitleList;
  }

  Future<void> func(BuildContext context) async {
    var url = linkController.text;
    var str = "";
    if (url != "") {
      Grock.dialog(
          barrierDismissible: false,
          builder: (_) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          });
      await ytService.service(url).then((val) async {
        if (val.first == "") {
          FocusScope.of(context).unfocus();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Video Altyazıları Alınamadı\nLinkin doğru olduğundan ve\nVideonun altyazı içerdiğinden emin olun'),
              duration: const Duration(seconds: 5),
              margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height - 150,
                  left: 16.0,
                  right: 16.0),
              behavior:
                  SnackBarBehavior.floating, // Snackbar'ın gösterim süresi
            ),
          );
          Navigator.pop(context);
          FocusScope.of(context).unfocus();
          return;
        } else {
          try {
            var key = 0;
            await box.add([true, val.last]).then((value) {
              Navigator.pop(context);
              key = value;
            });

            for (final subtitle in xmlToList(val.first as String)) {
              str = "$str $subtitle";
            }
            gptService.processLongText(str).then((value) {
              if (value.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                        "Bir Hata Oluştu.\nDaha Sonra Tekrar Deneyiniz."),
                    duration: const Duration(seconds: 5),
                    margin: EdgeInsets.only(
                        bottom: 100.h - 150, left: 16.0, right: 16.0),
                    behavior: SnackBarBehavior
                        .floating, // Snackbar'ın gösterim süresi
                  ),
                );
                box.put(key, [false, val.last, {}, url]);
                return;
              }
              Map<List<String>, String> temp = {};
              for (var element in value) {
                temp.addAll(formatMetni(element));
              }
              box.put(key, [false, val.last, temp, url]);
            });
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
                duration: const Duration(seconds: 5),
                margin: EdgeInsets.only(
                    bottom: 100.h - 150, left: 16.0, right: 16.0),
                behavior:
                    SnackBarBehavior.floating, // Snackbar'ın gösterim süresi
              ),
            );
            return;
          }
        }
      });
    }
  }
}
