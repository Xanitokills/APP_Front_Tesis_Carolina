import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'camera.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Home Screen', style: TextStyle(fontSize: 24)),
    );
  }
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});
  Future<void> _openCamera(BuildContext context) async {
    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();

    if (cameras.isEmpty) {
      // Handle the case where no cameras are available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No cameras found on this device.')),
      );
      return;
    }

    // Navigate to the CameraScreen.
    // Ensure you have a CameraScreen widget defined.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(cameras: cameras),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Example'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _openCamera(context),
          child: const Text('Open Camera'),
        ),
      ),
    );
  }
  /*
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Search Screen', style: TextStyle(fontSize: 24)),
    );
  }*/
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Profile Screen', style: TextStyle(fontSize: 24)),
    );
  }
}