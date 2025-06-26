import 'dart:async';
import 'dart:convert';
import 'dart:io'; // For File operations
import 'description_screen.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'; // For getting directory paths
import 'package:path/path.dart'
    show join, basename; // For joining path components
import 'package:http/http.dart' as http;

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
      print("¡No se encontraron cámaras!");
      return;
    }

    _controller = CameraController(widget.cameras[0], ResolutionPreset.medium);

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    await _initializeControllerFuture;
    try {
      final XFile image = await _controller.takePicture();
      setState(() => _imageFile = image);

      // Enviar imagen al backend
      final response = await _uploadImage(image.path);
      if (response != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DescriptionScreen(
              imagePath: image.path,
              styleName: response['styleName'] ?? 'Estilo desconocido',
              description: response['description'] ?? 'No disponible',
              techniques:
                  (response['techniques'] as List<dynamic>?)
                      ?.map(
                        (tech) =>
                            {
                                  'title':
                                      (tech['title'] ?? 'Técnica desconocida')
                                          .toString(),
                                  'subtitle':
                                      (tech['subtitle'] ?? 'No disponible')
                                          .toString(),
                                }
                                as Map<String, String>,
                      )
                      .toList() ??
                  [],
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DescriptionScreen(
              imagePath: image.path,
              styleName: 'Error',
              description: 'No se puedo procesar la imagen.',
              techniques: [],
            ),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future<Map<String, dynamic>?> _uploadImage(String imagePath) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:8000/predict'), // Ajusta la URL si usas IP
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imagePath,
        filename: basename(imagePath),
      ),
    );

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        return Map<String, dynamic>.from(jsonDecode(responseBody));
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error al enviar: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Toma una foto')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                CameraPreview(_controller),
                if (_imageFile != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: 100,
                        height: 150,
                        child: Image.file(
                          File(_imageFile!.path),
                          fit: BoxFit.cover,
                        ),
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
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
