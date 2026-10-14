
class ChatMessage {
  final String text;
  final bool isAi;
  final List<Map<String, dynamic>> staff;

  // New fields for unavailable services.
  final String? requestedService;
  final bool canRequestService;

  const ChatMessage({
    required this.text,
    required this.isAi,
    this.staff = const [],
    this.requestedService,
    this.canRequestService = false,
  });
}
