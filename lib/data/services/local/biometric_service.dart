import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:just_audio/just_audio.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final AudioPlayer _soundPlayer = AudioPlayer();

  //Checks if the device is capable of biometric authentication and if any biometrics (fingerprint, face) are enrolled.
  Future<bool> isBiometricsAvailable() async {
    try {
      //Check if the device hardware supports biometrics
      final isHardwareAvailable = await _localAuth.canCheckBiometrics;

      //Check if the device has any biometrics enrolled
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      //check if there are any enrolled biometrics
      final enrolledBiometrics = await _localAuth.getAvailableBiometrics();
      final hasEnrolled = enrolledBiometrics.isNotEmpty;

      return (isHardwareAvailable || isDeviceSupported) && hasEnrolled;
    } on PlatformException catch (e) {
      print("Error checking biometrics: $e");
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please verify your identity to continue',
        biometricOnly: true,
      );

      if (didAuthenticate) {
        _playSuccessSound();
      }

      return didAuthenticate;
    } on PlatformException catch (e) {
      print("Authentication error: ${e.code}");
      return false;
    }
  }

  Future<void> _playSuccessSound() async {
    try {
      await _soundPlayer.setAsset("assets/biometric_success.mp3");
      await _soundPlayer.play();
    } catch (e) {
      //silent fail
    }
  }

  void dispose() {
    _soundPlayer.dispose();
  }

}
