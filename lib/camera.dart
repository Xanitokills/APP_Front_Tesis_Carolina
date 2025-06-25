import 'dart:async';
import 'dart:io'; // For File operations
import 'description_screen.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'; // For getting directory paths
import 'package:path/path.dart' show join; // For joining path components

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({super.key, required this.cameras});

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  XFile? _imageFile; // To store the taken picture

  @override
  void initState() {
    super.initState();
    // Ensure there's at least one camera
    if (widget.cameras.isEmpty) {
      // Handle the case where no cameras are available
      print("No cameras found!");
      // You might want to show a message to the user or navigate back
      return;
    }

    // Initialize the camera controller with the first available camera
    _controller = CameraController(
      widget.cameras[0], // Use the first camera
      ResolutionPreset
          .medium, // You can choose other presets like high, max, etc.
    );

    // Initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
  await _initializeControllerFuture;
  try {
    final XFile image = await _controller.takePicture();
    setState(() => _imageFile = image);

    // Datos de ejemplo — luego vendrán de tu back
    const fakeDescription = 'El impresionismo es un movimiento pictórico surgido...';
    final fakeTechniques = [
      {
        'title': 'Pintura al aire libre (plein air)',
        'subtitle': 'Trabajar sobre el motivo directamente...'
      },
      {
        'title': 'Pinceladas sueltas y fragmentadas',
        'subtitle': 'Trazos cortos y visibles que sugieren formas...'
      },
      {
        'title': 'Color roto (“broken color”)',
        'subtitle': 'Manchas de pigmento puro yuxtapuestas...'
      },
    ];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DescriptionScreen(
          imagePath: image.path,
          styleName: 'Impresionista',
          description: fakeDescription,
          techniques: fakeTechniques,
        ),
      ),
    );
  } catch (e) {
    print(e);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                CameraPreview(_controller),
                if (_imageFile != null)
                // Display the taken picture
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: 100,
                        height: 150,
                        child: Image.file(File(_imageFile!.path),
                            fit: BoxFit.cover),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: FloatingActionButton(
                    onPressed: _takePicture,
                    child: const Icon(Icons.camera_alt),
                  ),
                ),
              ],
            );
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}