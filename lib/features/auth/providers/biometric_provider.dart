import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/local/biometric_service.dart';


final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

final biometricProvider = FutureProvider<bool>((ref) async {
  final biometricService = ref.read(biometricServiceProvider);
  
  // First check if biometrics are available
  final isAvailable = await biometricService.isBiometricsAvailable();
  if (!isAvailable) {
    throw Exception('Biometrics not available or not enrolled');
  }
  
  // Then attempt authentication
  final isAuthenticated = await biometricService.authenticateWithBiometrics();
  return isAuthenticated;
});