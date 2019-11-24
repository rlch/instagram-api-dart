import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  print('hello');
}

class InstagramAPI {
  /// URL for getting Instagram User Access Tokens
  static const API_URL = 'https://api.instagram.com/';

  /// URL for getting Instagram user profiles and media
  static const GRAPH_URL = 'https://graph.instagram.com/';

  /// Your Instagram app's ID
  final String app_id;

  /// Your OAuth Redirect URI.
  /// The user will be redirected to [redirect_uri] after authorization.
  final String redirect_uri;

  /// Your Instagram app secret.
  final String app_secret;

  /// Access token initialized by [exchangeCodeForToken].
  String access_token;
  int user_id;

  /// Redirect your user to [authURI], store the code in the redirected URI to exchange for a token using [exchangeCodeForToken].
  get authURI =>
      API_URL +
      'oauth/authorize?app_id=$app_id&redirect_uri=${Uri.encodeFull(redirect_uri)}&scope=user_profile,user_media&response_type=code';

  /// Exchanges [code] for an an access token and user ID.
  Future<void> exchangeCodeForToken(String code) async {
    await http.post(API_URL + 'oauth/access_token', body: {
      'app_id': app_id,
      'app_secret': app_secret,
      'grant_type': 'authorization_code',
      'redirect_uri': redirect_uri,
      'code': code,
    }).then((res) {
      final tokenRes = json.decode(res.body);
      access_token = tokenRes['access_token'];
      user_id = tokenRes['user_id'];
    });
  }

  /// Helper function for GET requests to the Graph API.
  Future<http.Response> queryEndpoint(String endpoint, List<dynamic> fields) {
    return http.get(GRAPH_URL +
        enumToString(endpoint) +
        '?fields=${fields.join(",")}&access_token=$access_token');
  }

  Future<Map> getMyData(List<UserField> fields) =>
      queryEndpoint('me', fields).then((res) => json.decode(res.body));

  Future<Map> getMyMedia(List<MediaField> fields) =>
      queryEndpoint('me/media', fields).then((res) => json.decode(res.body));

  Future<Map> getUserByID(int user_id, List<UserField> fields) =>
      queryEndpoint(user_id.toString(), fields)
          .then((res) => json.decode(res.body));

  Future<Map> getUserMedia(int user_id, List<UserField> fields) =>
      queryEndpoint(user_id.toString() + '/media', fields)
          .then((res) => json.decode(res.body));

  Future<Map> getMediaByID(int media_id, List<MediaField> fields) =>
      queryEndpoint(media_id.toString(), fields)
          .then((res) => json.decode(res.body));

  /// Get a collection of image/video Media on an album.
  Future<Map> getMediaChildrenByID(int media_id, List<MediaField> fields) =>
      queryEndpoint(media_id.toString() + '/children', fields)
          .then((res) => json.decode(res.body));


  Future<Map> getMediaData(int media_id) {

  }



  InstagramAPI(this.app_id, this.redirect_uri, this.app_secret);
}

// TODO: handle request errors

enum Endpoint { me }

enum UserField {
  /// The user's account type. Can be __BUSINESS__, __CONSUMER__, __CREATOR__
  account_type,
  id,

  /// Number of media (images/videos) on the user.
  media_count,
  username,
}

enum MediaField {
  /// Caption text. Not returnable for Media in albums.
  caption,
  id,

  /// The media's type. Can be __IMAGE__, __VIDEO__, or __CAROUSEL_ALBUM__
  media_type,
  media_url,
  permalink,
  thumbnail_url,

  /// The media's publish date (ISO 8601)
  timestamp,
  username,
}

String enumToString(dynamic enumObject) =>
    enumObject.toString().split('.').last;
