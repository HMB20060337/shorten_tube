import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YtService {
  var yt = YoutubeExplode();

  Future<List<Object>> service(String url) async {
    String? title;
    String? trSubtitle;
    try {
      var video = await yt.videos.get(url);
      title = video.title;
      var subtitles = await yt.videos.closedCaptions.getManifest(video.id);
      ClosedCaptionTrackInfo? trSubtitleInfo;

      trSubtitleInfo = subtitles.tracks.first.autoTranslate('tr');
      trSubtitle = await yt.videos.closedCaptions.getSubTitles(trSubtitleInfo);
    } catch (e) {
      return ['', ''];
    }

    return [trSubtitle, title];
  }
}
