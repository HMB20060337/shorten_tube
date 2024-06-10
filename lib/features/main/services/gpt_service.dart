import 'dart:developer';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Gpt {
  Future<String?> post(String text) async {

    log("soru: $text");
    String apiKey = Hive.box('apiKey').values.first;
    final model =
        GenerativeModel(model: "gemini-1.5-flash-latest", apiKey: apiKey);

    final response = await model.generateContent([
      Content.text(
          "[$text] metninden, video içeriğindeki önemli anları özetleyen bir JSON oluşturun. JSON, {'start': x:xx:xx,xx, 'end': x:xx:xx,xx, 'summary': özet} formatında olmalıdır. Özet double quotes içermemelidir. Yanıt sadece JSON stringi içermelidir."),
    ]);
    if (response.text != null) {
      log("response: ${response.text!}");
    }

    return response.text;
  }
  String replaceTurkishChars(String input) {
    Map<String, String> turkishChars = {
      'ç': 'c', 'Ç': 'C',
      'ğ': 'g', 'Ğ': 'G',
      'ı': 'i', 'I': 'I',
      'ö': 'o', 'Ö': 'O',
      'ş': 's', 'Ş': 'S',
      'ü': 'u', 'Ü': 'U',
    };

    String output = input;
    turkishChars.forEach((turkishChar, englishChar) {
      output = output.replaceAll(turkishChar, englishChar);
    });

    return output;
  }

  Future<List<String>> processLongText(String longText) async {
    List<String> parts =
        splitTextIntoChunks(longText, 15000); // 2048 tokens per chunk
    List<String> summaries = [];

    for (String part in parts) {
      String? summary;
      try{ summary = await post(part);}catch(e){
        log(e.toString());
      return [];}
      if (summary != null) {
        summaries.add(summary);
      }
    }

    return summaries;
  }

  List<String> splitTextIntoChunks(String text, int maxTokens) {
    List<String> chunks = [];
    int startIndex = 0;

    while (startIndex < text.length) {
      int endIndex = (startIndex + maxTokens < text.length)
          ? startIndex + maxTokens
          : text.length;
      chunks.add(text.substring(startIndex, endIndex));
      startIndex += maxTokens;
    }

    return chunks;
  }
}
