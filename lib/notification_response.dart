/// Response data when a notification is tapped
class AudioNotificationResponse {
  /// The title of the notification
  final String title;

  /// The body text of the notification
  final String body;

  /// The audio URL that was playing
  final String url;

  /// When the notification was created
  final DateTime timestamp;

  AudioNotificationResponse({
    required this.title,
    required this.body,
    required this.url,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'AudioNotificationResponse(title: $title, body: $body, url: $url, timestamp: $timestamp)';
  }
}
