import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../../core/theme/app_colors.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _messageController =
      TextEditingController();

  // ============================================================
  // SPEECH TO TEXT
  // ============================================================

  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isListening = false;
  bool _speechAvailable = false;
  bool _speechInitialized = false;

  // Latest useful speech result.
  String _lastRecognizedText = '';

  // Prevent duplicate speech messages.
  bool _speechMessageSent = false;

  // ============================================================
  // CHAT MESSAGES
  // ============================================================

  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text: 'Hi! What do you need help with today?',
      isAi: true,
    ),
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _initializeSpeech();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _messageController.dispose();
    _speech.stop();
    super.dispose();
  }

  // ============================================================
  // INITIALIZE SPEECH
  // ============================================================

  Future<void> _initializeSpeech() async {
    if (_speechInitialized) {
      return;
    }

    try {
      final available = await _speech.initialize(
        // --------------------------------------------------------
        // SPEECH STATUS
        // --------------------------------------------------------

        onStatus: (status) {
          debugPrint('Speech status: $status');

          // IMPORTANT:
          //
          // We DON'T send the message from here.
          //
          // The finalResult callback handles sending.
          //
          // This avoids waiting for "done" and prevents duplicate
          // messages.

          if (status == 'done' || status == 'notListening') {
            if (!mounted) return;

            if (_isListening) {
              setState(() {
                _isListening = false;
              });
            }
          }
        },

        // --------------------------------------------------------
        // SPEECH ERROR
        // --------------------------------------------------------

        onError: (error) {
          debugPrint(
            'Speech error: ${error.errorMsg}',
          );

          if (!mounted) return;

          if (_isListening) {
            setState(() {
              _isListening = false;
            });
          }

          // These can happen normally when speech ends without
          // producing a usable result.
          //
          // Don't show an error SnackBar for them.

          if (error.errorMsg == 'error_speech_timeout' ||
              error.errorMsg == 'error_no_match') {
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Speech error: ${error.errorMsg}',
              ),
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

      debugPrint(
        'Speech recognition available: $_speechAvailable',
      );
    } catch (e) {
      debugPrint(
        'Speech initialization error: $e',
      );

      if (!mounted) return;

      setState(() {
        _speechAvailable = false;
        _speechInitialized = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not initialize microphone: $e',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // START / STOP LISTENING
  // ============================================================

  Future<void> _toggleListening() async {
    // ----------------------------------------------------------
    // STOP CURRENT LISTENING
    // ----------------------------------------------------------

    if (_isListening) {
      await _stopListening();
      return;
    }

    // ----------------------------------------------------------
    // INITIALIZE IF NEEDED
    // ----------------------------------------------------------

    if (!_speechInitialized) {
      await _initializeSpeech();
    }

    // ----------------------------------------------------------
    // CHECK AVAILABILITY
    // ----------------------------------------------------------

    if (!_speechAvailable) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Speech recognition is not available on this device.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    // ----------------------------------------------------------
    // RESET SPEECH DATA
    // ----------------------------------------------------------

    _lastRecognizedText = '';
    _speechMessageSent = false;

    // ----------------------------------------------------------
    // CLEAR PREVIOUS TEXT
    // ----------------------------------------------------------

    _messageController.clear();

    // ----------------------------------------------------------
    // START LISTENING
    // ----------------------------------------------------------

    if (!mounted) return;

    setState(() {
      _isListening = true;
    });

    try {
      await _speech.listen(
        // ------------------------------------------------------
        // SPEECH RESULT
        // ------------------------------------------------------

        onResult: (result) {
          if (!mounted) return;

          final recognizedText =
              result.recognizedWords.trim();

          // Ignore empty results.
          if (recognizedText.isEmpty) {
            return;
          }

          // Save latest useful speech.
          _lastRecognizedText = recognizedText;

          // ====================================================
          // PERFORMANCE FIX
          // ====================================================
          //
          // DON'T use setState() here.
          //
          // Updating the TextEditingController directly updates
          // the TextField without rebuilding the complete page
          // for every partial speech result.
          //

          _messageController.value = TextEditingValue(
            text: recognizedText,
            selection: TextSelection.collapsed(
              offset: recognizedText.length,
            ),
          );

          // ----------------------------------------------------
          // FINAL RESULT
          // ----------------------------------------------------

          if (result.finalResult) {
            debugPrint(
              'Final speech result received.',
            );

            // Send immediately.
            _sendFinalSpeech();
          }
        },

        // ------------------------------------------------------
        // LISTEN FOR UP TO 1 MINUTE
        // ------------------------------------------------------

        listenFor: const Duration(
          minutes: 1,
        ),

        // ------------------------------------------------------
        // ALLOW PAUSES
        // ------------------------------------------------------
        //
        // Reduced from 5 seconds to 2 seconds so the message
        // doesn't wait too long after the user finishes speaking.
        //

        pauseFor: const Duration(
          seconds: 2,
        ),

        // ------------------------------------------------------
        // PARTIAL RESULTS
        // ------------------------------------------------------

        partialResults: true,

        // ------------------------------------------------------
        // DON'T CANCEL ON ERROR
        // ------------------------------------------------------

        cancelOnError: false,

        // ------------------------------------------------------
        // DICTATION MODE
        // ------------------------------------------------------

        listenMode: stt.ListenMode.dictation,
      );
    } catch (e) {
      debugPrint(
        'Listen error: $e',
      );

      if (!mounted) return;

      setState(() {
        _isListening = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not start microphone: $e',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // STOP LISTENING
  // ============================================================

  Future<void> _stopListening() async {
    debugPrint(
      'Stopping speech recognition...',
    );

    try {
      await _speech.stop();
    } catch (e) {
      debugPrint(
        'Stop speech error: $e',
      );
    }

    if (!mounted) return;

    setState(() {
      _isListening = false;
    });

    // IMPORTANT:
    //
    // Don't call _sendFinalSpeech() here.
    //
    // speech_to_text can deliver the final result after stop()
    // is called.
    //
    // onResult handles the final message.
  }

  // ============================================================
  // SEND FINAL SPEECH
  // ============================================================

  void _sendFinalSpeech() {
    // Prevent duplicate messages.
    if (_speechMessageSent) {
      return;
    }

    final text = _lastRecognizedText.trim();

    // Nothing recognized.
    if (text.isEmpty) {
      return;
    }

    debugPrint(
      'Sending final speech: $text',
    );

    // Mark as sent BEFORE sending.
    _speechMessageSent = true;

    _sendMessage(text);
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  void _sendMessage([String? message]) {
    final text =
        (message ?? _messageController.text).trim();

    // ----------------------------------------------------------
    // EMPTY MESSAGE
    // ----------------------------------------------------------

    if (text.isEmpty) {
      return;
    }

    // ----------------------------------------------------------
    // STOP MICROPHONE
    // ----------------------------------------------------------

    if (_isListening) {
      _speech.stop();

      if (mounted) {
        setState(() {
          _isListening = false;
        });
      }
    }

    // ----------------------------------------------------------
    // ADD USER MESSAGE
    // ----------------------------------------------------------

    if (!mounted) return;

    setState(() {
      _messages.add(
        _ChatMessage(
          text: text,
          isAi: false,
        ),
      );

      _messageController.clear();
    });

    debugPrint(
      'User message sent: $text',
    );

    // ==========================================================
    // GROQ WILL COME HERE
    // ==========================================================
    //
    // Later:
    //
    // User message
    //       ↓
    //     Groq AI
    //       ↓
    // Understand intent
    //       ↓
    // Ask missing information
    //       ↓
    // Get user location
    //       ↓
    // Find real nearby staff
    //       ↓
    // Show staff
    //       ↓
    // User selects staff
    //       ↓
    // Create booking
    //
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,

      // ========================================================
      // APP BAR
      // ========================================================

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

      // ========================================================
      // BODY
      // ========================================================

      body: Column(
        children: [
          // ======================================================
          // CHAT
          // ======================================================

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                20,
              ),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];

                return _ChatBubble(
                  message: message,
                );
              },
            ),
          ),

          // ======================================================
          // INPUT
          // ======================================================

          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                16,
              ),
              child: Row(
                children: [
                  // =================================================
                  // TEXT FIELD
                  // =================================================

                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.06,
                        ),
                        borderRadius:
                            BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withValues(
                            alpha: 0.1,
                          ),
                        ),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        textInputAction:
                            TextInputAction.send,
                        maxLines: 4,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: _isListening
                              ? 'Listening...'
                              : 'Tell me what you need...',
                          hintStyle: TextStyle(
                            color: _isListening
                                ? AppColors.primary
                                : Colors.white.withValues(
                                    alpha: 0.45,
                                  ),
                          ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) {
                          _sendMessage();
                        },
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // =================================================
                  // MICROPHONE
                  // =================================================

                  AnimatedContainer(
                    duration:
                        const Duration(milliseconds: 200),
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _isListening
                          ? Colors.redAccent
                          : AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening
                                  ? Colors.redAccent
                                  : AppColors.primary)
                              .withValues(alpha: 0.25),
                          blurRadius:
                              _isListening ? 24 : 18,
                          spreadRadius:
                              _isListening ? 4 : 2,
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _toggleListening,
                      icon: Icon(
                        _isListening
                            ? Icons.mic_rounded
                            : Icons.mic_none_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // =================================================
                  // SEND
                  // =================================================

                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: 0.08,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        _sendMessage();
                      },
                      icon: const Icon(
                        Icons.arrow_upward_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// CHAT MESSAGE
// ================================================================

class _ChatMessage {
  final String text;
  final bool isAi;

  const _ChatMessage({
    required this.text,
    required this.isAi,
  });
}

// ================================================================
// CHAT BUBBLE
// ================================================================

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;

  const _ChatBubble({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isAi
          ? Alignment.centerLeft
          : Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 320,
        ),
        margin: const EdgeInsets.only(
          bottom: 14,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: message.isAi
              ? Colors.white.withValues(
                  alpha: 0.06,
                )
              : AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(
              message.isAi ? 4 : 18,
            ),
            bottomRight: Radius.circular(
              message.isAi ? 18 : 4,
            ),
          ),
          border: message.isAi
              ? Border.all(
                  color: Colors.white.withValues(
                    alpha: 0.08,
                  ),
                )
              : null,
        ),
        child: Text(
          message.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}