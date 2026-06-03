import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import "login_page.dart";
import '../../../core/widgets/_loading_screen.dart';
import '../../../routes/route_names.dart';
import '../widgets/_biometric_error_screen.dart';
import '../providers/biometric_provider.dart';
import '../providers/auth_provider.dart';

class BiometricGate extends ConsumerWidget {
  const BiometricGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);

    return authAsync.when(
      loading: () => const LoadingScreen(message: "Initializing..."),
      
      error: (error, stack) {
        return const BiometricErrorScreen(
          message: "Failed to check authentication state. Please restart the app.",
          allowRetry: false,
        );
      },
      
      data: (user) {
        if (user == null) {
          return const LoginPage();
        }
        
        final biometricAsync = ref.watch(biometricProvider);
        
        return biometricAsync.when(
          loading: () => const LoadingScreen(message: "Verifying identity..."),
          
          error: (error, stack) {
            return BiometricErrorScreen(
              message: _getBiometricErrorMessage(error.toString()),
              allowRetry: true,
            );
          },
          
          data: (isAuthenticated) {
            if (!isAuthenticated) {
              return const BiometricErrorScreen(
                message: "Biometric authentication failed. Please try again.",
                allowRetry: true,
              );
            }
            
            //Navigate to home
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go(RouteNames.home);
            });
            
            // Show loading while navigating
            return const LoadingScreen(message: "Loading your podcasts...");
          },
        );
      },
    );
  }

  String _getBiometricErrorMessage(String error) {
    final errorStr = error.toString();
    if (errorStr.contains('NotAvailable') || errorStr.contains('not available')) {
      return "Biometric authentication is not available on this device.";
    }
    if (errorStr.contains('NotEnrolled') || errorStr.contains('not enrolled')) {
      return "No biometrics are enrolled on this device.";
    }
    if (errorStr.contains('Lockout') || errorStr.contains('locked out')) {
      return "Too many failed attempts. Biometric temporarily locked.";
    }
    return "Biometric authentication failed. Please try again.";
  }
}