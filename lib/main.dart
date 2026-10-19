
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_hub_ai/core/notification/notification_service.dart';
import 'package:service_hub_ai/core/service/service_locator.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/auth_gate.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('STARTUP 1: Flutter initialized');

  try {
    // Initialize Firebase
    debugPrint('STARTUP 2: Initializing Firebase');

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint('STARTUP 3: Firebase initialized');

    // Register dependencies
    setupDependencies();

    debugPrint('STARTUP 4: Dependencies registered');

    // Initialize Firebase Cloud Messaging
    try {
      final notificationService = sl<NotificationService>();

      await notificationService.initialize();

      debugPrint('STARTUP 4A: Notifications initialized');
    } catch (e, stackTrace) {
      debugPrint('NOTIFICATION INIT ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);
    }

    // Start the application
    runApp(const ServiceHubApp());

    debugPrint('STARTUP 5: runApp called');
  } catch (e, stackTrace) {
    debugPrint('STARTUP ERROR: $e');
    debugPrintStack(stackTrace: stackTrace);
    rethrow;
  }
}

class ServiceHubApp extends StatelessWidget {
  const ServiceHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ServiceHub',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.blue,
        ),
        home: const AuthGate(),
      ),
    );
  }
}
