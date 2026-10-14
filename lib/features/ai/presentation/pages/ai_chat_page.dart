
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:service_hub_ai/core/service/service_locator.dart';
import 'package:service_hub_ai/core/theme/app_colors.dart';

import 'package:service_hub_ai/features/ai/presentation/bloc/ai_bloc.dart';
import 'package:service_hub_ai/features/ai/presentation/bloc/ai_event.dart';
import 'package:service_hub_ai/features/ai/presentation/bloc/ai_state.dart';
import 'package:service_hub_ai/features/ai/presentation/models/chat_message.dart';

import 'package:service_hub_ai/features/ai/presentation/widgets/chat_bubble.dart';
import 'package:service_hub_ai/features/ai/presentation/widgets/chat_input_bar.dart';
import 'package:service_hub_ai/features/ai/presentation/widgets/suggested_service_card.dart';

import 'package:service_hub_ai/features/location/domain/usecases/get_current_location.dart';

class AiChatPage extends StatelessWidget {
  const AiChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AiBloc>(
      create: (_) => sl<AiBloc>(),
      child: const _AiChatView(),
    );
  }
}

class _AiChatView extends StatefulWidget {
  const _AiChatView();

  @override
  State<_AiChatView> createState() => _AiChatViewState();
}

class _AiChatViewState extends State<_AiChatView> {
  final TextEditingController _messageController =
      TextEditingController();

  final ScrollController _scrollController = ScrollController();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isListening = false;
  bool _speechAvailable = false;
  bool _speechInitialized = false;
  bool _speechMessageSent = false;
  bool _isSearchingStaff = false;
  bool _isSubmittingServiceRequest = false;

  String _lastRecognizedText = '';
  String? _pendingServiceName;

  // Prevent duplicate submissions for the same unavailable service.
  final Set<String> _submittedServiceRequests = {};

  final List<ChatMessage> _messages = [
    const ChatMessage(
      text: 'Hi! What do you need help with today?',
      isAi: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _speech.stop();
    super.dispose();
  }

  // ---------------- SPEECH ----------------

  Future<void> _initializeSpeech() async {
    if (_speechInitialized) return;

    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          debugPrint('Speech status: $status');

          if (!mounted) return;

          if (status == 'done' || status == 'notListening') {
            if (_isListening) {
              setState(() => _isListening = false);
            }
          }
        },
        onError: (error) {
          debugPrint('Speech error: ${error.errorMsg}');

          if (!mounted) return;

          setState(() => _isListening = false);

          if (error.errorMsg == 'error_speech_timeout' ||
              error.errorMsg == 'error_no_match') {
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Speech error: ${error.errorMsg}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );

      if (!mounted) return;

      setState(() {
        _speechAvailable = available;
        _speechInitialized = true;
      });
    } catch (e) {
      debugPrint('Speech initialization error: $e');

      if (!mounted) return;

      setState(() {
        _speechAvailable = false;
        _speechInitialized = true;
      });
    }
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _stopListening();
      return;
    }

    if (!_speechInitialized) {
      await _initializeSpeech();
    }

    if (!_speechAvailable) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Speech recognition is not available on this device.',
          ),
        ),
      );
      return;
    }

    _lastRecognizedText = '';
    _speechMessageSent = false;
    _messageController.clear();

    if (!mounted) return;

    setState(() => _isListening = true);

    try {
      await _speech.listen(
        onResult: (result) {
          if (!mounted) return;

          final recognizedText = result.recognizedWords.trim();
          if (recognizedText.isEmpty) return;

          _lastRecognizedText = recognizedText;

          _messageController.value = TextEditingValue(
            text: recognizedText,
            selection: TextSelection.collapsed(
              offset: recognizedText.length,
            ),
          );

          if (result.finalResult) {
            _sendFinalSpeech();
          }
        },
        listenOptions: stt.SpeechListenOptions(
          listenFor: const Duration(minutes: 1),
          pauseFor: const Duration(seconds: 2),
          partialResults: true,
          cancelOnError: false,
          listenMode: stt.ListenMode.dictation,
        ),
      );
    } catch (e) {
      debugPrint('Listen error: $e');

      if (!mounted) return;

      setState(() => _isListening = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not start microphone: $e'),
        ),
      );
    }
  }

  Future<void> _stopListening() async {
    try {
      await _speech.stop();
    } catch (e) {
      debugPrint('Stop speech error: $e');
    }

    if (!mounted) return;
    setState(() => _isListening = false);
  }

  void _sendFinalSpeech() {
    if (_speechMessageSent) return;

    final recognizedText = _lastRecognizedText.trim();
    if (recognizedText.isEmpty) return;

    _speechMessageSent = true;
    _sendMessage(recognizedText);
  }

  // ---------------- SEND MESSAGE ----------------

  void _sendMessage([String? message]) {
    final text = (message ?? _messageController.text).trim();

    if (text.isEmpty) return;

    if (_isListening) {
      _speech.stop();
    }

    setState(() {
      _isListening = false;
      _pendingServiceName = null;
      _isSearchingStaff = false;

      _messages.add(
        ChatMessage(
          text: text,
          isAi: false,
        ),
      );

      _messageController.clear();
    });

    context.read<AiBloc>().add(
          IdentifyServiceRequested(text),
        );

    _scrollToBottom();
  }

  // ---------------- CONFIRM SERVICE ----------------

  Future<void> _confirmService() async {
    final serviceName = _pendingServiceName;

    if (serviceName == null ||
        serviceName.trim().isEmpty ||
        _isSearchingStaff) {
      return;
    }

    setState(() => _isSearchingStaff = true);

    try {
      final position = await sl<GetCurrentLocation>()();

      if (!mounted) return;

      context.read<AiBloc>().add(
            ConfirmServiceRequested(
              latitude: position.latitude,
              longitude: position.longitude,
              serviceName: serviceName.trim(),
              radiusKm: 10,
            ),
          );

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      final error = e.toString().toLowerCase();
      String message;

      if (error.contains('permanently denied')) {
        message =
            'Location permission is permanently denied. Please enable it in your app settings.';
      } else if (error.contains('permission denied')) {
        message =
            'Location permission is required to find nearby staff.';
      } else if (error.contains('service is disabled')) {
        message = 'Please turn on your phone GPS and try again.';
      } else {
        message = 'Could not get your location. Please try again.';
        debugPrint('Get current location error: $e');
      }

      setState(() {
        _isSearchingStaff = false;
        _messages.add(
          ChatMessage(
            text: message,
            isAi: true,
          ),
        );
      });

      _scrollToBottom();
    }
  }

  // ---------------- REQUEST UNAVAILABLE SERVICE ----------------

  void _requestService(ChatMessage message) {
    final requestedService = message.requestedService?.trim();

    if (requestedService == null ||
        requestedService.isEmpty ||
        _isSubmittingServiceRequest ||
        _submittedServiceRequests.contains(requestedService)) {
      return;
    }

    context.read<AiBloc>().add(
          SubmitServiceRequestRequested(
            requestedService: requestedService,
            description: '',
          ),
        );
  }

  // ---------------- BLOC STATES ----------------

  void _handleState(AiState state) {
    if (!mounted) return;

    if (state is ServiceIdentified) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: state.reply,
            isAi: true,
            requestedService: state.requestedService,
            canRequestService: state.canRequestService,
          ),
        );

        if (state.requiresConfirmation &&
            state.serviceName != null) {
          _pendingServiceName = state.serviceName;
        } else {
          _pendingServiceName = null;
        }
      });

      _scrollToBottom();
    } else if (state is ServiceRequestSubmitting) {
      setState(() {
        _isSubmittingServiceRequest = true;
      });
    } else if (state is ServiceRequestSubmitted) {
      setState(() {
        _isSubmittingServiceRequest = false;
        _submittedServiceRequests.add(state.requestedService);

        _messages.add(
          ChatMessage(
            text: state.message,
            isAi: true,
          ),
        );
      });

      _scrollToBottom();
    } else if (state is NearbyStaffLoaded) {
      final response = state.response;
      final rawStaff = response['staff'];

      final staffList = rawStaff is List
          ? rawStaff
              .whereType<Map>()
              .map(
                (item) => Map<String, dynamic>.from(item),
              )
              .toList()
          : <Map<String, dynamic>>[];

      setState(() {
        _isSearchingStaff = false;
        _pendingServiceName = null;

        if (staffList.isNotEmpty) {
          _messages.add(
            ChatMessage(
              text:
                  'I found ${staffList.length} nearby staff member(s).',
              isAi: true,
              staff: staffList,
            ),
          );
        } else {
          _messages.add(
            const ChatMessage(
              text: 'No nearby staff were found for this service.',
              isAi: true,
            ),
          );
        }
      });

      _scrollToBottom();
    } else if (state is AiError) {
      setState(() {
        _isSearchingStaff = false;
        _isSubmittingServiceRequest = false;

        _messages.add(
          ChatMessage(
            text: state.message,
            isAi: true,
          ),
        );
      });

      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 20,
        title: const Row(
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primary,
              size: 22,
            ),
            SizedBox(width: 10),
            Text(
              'ServiceHub AI',
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
      body: BlocConsumer<AiBloc, AiState>(
        listener: (context, state) {
          _handleState(state);
        },
        builder: (context, state) {
          final isLoading = state is AiLoading ||
              state is ServiceRequestSubmitting;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];

                    final serviceAlreadySubmitted =
                        message.requestedService != null &&
                        _submittedServiceRequests.contains(
                          message.requestedService!.trim(),
                        );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ChatBubble(message: message),

                        if (message.isAi &&
                            message.canRequestService &&
                            message.requestedService != null &&
                            !serviceAlreadySubmitted)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 12,
                              top: 4,
                              bottom: 12,
                            ),
                            child: ElevatedButton.icon(
                              onPressed: _isSubmittingServiceRequest
                                  ? null
                                  : () => _requestService(message),
                              icon: _isSubmittingServiceRequest
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.add_task),
                              label: Text(
                                _isSubmittingServiceRequest
                                    ? 'Submitting...'
                                    : 'Request this service',
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),

              if (isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'ServiceHub AI is thinking...',
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (_pendingServiceName != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    8,
                  ),
                  child: SuggestedServiceCard(
                    serviceName: _pendingServiceName!,
                    isSearching: _isSearchingStaff,
                    onConfirm: _confirmService,
                  ),
                ),

              ChatInputBar(
                controller: _messageController,
                isListening: _isListening,
                isLoading: isLoading,
                onMicPressed: _toggleListening,
                onSendPressed: _sendMessage,
              ),
            ],
          );
        },
      ),
    );
  }
}
