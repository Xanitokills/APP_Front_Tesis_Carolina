import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart' as p;
import 'camera.dart'; // Asegúrate de tener este archivo
import 'description_screen.dart'; // Asegúrate de tener este archivo

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Pantalla de inicio', style: TextStyle(fontSize: 24)),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _openCamera(BuildContext context) async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontraron cámaras en este dispositivo.'),
        ),
      );
      return;
    }
    final XFile? photo = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CameraScreen(cameras: cameras)),
    );
    if (photo != null) {
      await _uploadImage(photo.path);
    }
  }

  Future<void> _uploadImage(String imagePath) async {
    // Mostrar loader
    showDialog(
      context: context,
      barrierDismissible: false, // Evita que el usuario cierre el loader
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.purple,
            strokeWidth: 6.0,
          ),
        );
      },
    );

    HttpClient client = HttpClient();
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) =>
            true; // Permitir certificados autofirmados
    client.connectionTimeout = const Duration(seconds: 30);

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://sntps2jn-8001.brs.devtunnels.ms/predict/'),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imagePath,
        filename: p.basename(imagePath),
      ),
    );

    try {
      print('Enviando solicitud a: ${request.url}');
      var response = await request.send();
      print('Status code: ${response.statusCode}');
      var responseBody = await response.stream.bytesToString();
      print('Respuesta completa: $responseBody');

      // Cerrar loader
      Navigator.of(context, rootNavigator: true).pop();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        // Convertir List<String> a List<Map<String, String>>
        final techniquesList = (data['tecnicas'] as String?)?.split(', ') ?? [];
        final techniquesMapped = techniquesList
            .map(
              (tech) => {
                'title': tech,
                'subtitle':
                    '', // Opcional, puedes dejarlo vacío o agregar más lógica
              },
            )
            .toList();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DescriptionScreen(
              imagePath: imagePath,
              styleName: data['nombre'] ?? 'Estilo desconocido',
              description: data['descripcion'] ?? 'No disponible',
              techniques: techniquesMapped,
            ),
          ),
        );
      } else if (response.statusCode == 400) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DescriptionScreen(
              imagePath: imagePath,
              styleName: 'Error',
              description:
                  'No se pudo procesar la imagen. Código: ${response.statusCode} - $responseBody',
              techniques: [],
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DescriptionScreen(
              imagePath: imagePath,
              styleName: 'Error',
              description:
                  'No se pudo procesar la imagen. Código: ${response.statusCode} - $responseBody',
              techniques: [],
            ),
          ),
        );
      }
    } catch (e) {
      // Cerrar loader en caso de error
      Navigator.of(context, rootNavigator: true).pop();
      print('Excepción al enviar a ${request.url}: $e');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DescriptionScreen(
            imagePath: imagePath,
            styleName: 'Error',
            description: 'Excepción: $e',
            techniques: [],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ElevatedButton.icon(
              onPressed: () => _openCamera(context),
              icon: const Icon(Icons.camera_alt, size: 34, color: Colors.white),
              label: const Text(
                'Identificar',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.all(20),
                minimumSize: const Size(300, 100),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final XFile? pickedFile = await _picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (pickedFile != null) {
                  await _uploadImage(pickedFile.path);
                }
              },
              icon: const Icon(Icons.upload, size: 34, color: Colors.white),
              label: const Text(
                'Subir',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[300],
                padding: const EdgeInsets.all(20),
                minimumSize: const Size(300, 100),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(5, 30, 5, 0),
      children: List.generate(9, (i) {
        return GestureDetector(
          onTap: () => debugPrint('test$i'),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 3),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: i.isEven ? Colors.purple[300] : Colors.orange[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://images.joseartgallery.com/127006/impressionism-art-style.jpg',
                      width: 200,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SizedBox(height: 9),
                      Text(
                        'Barroco',
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '5/24/2025',
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 9),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({
    super.key,
    this.initialIndex = 0, // 0=Home, 1=Search, 2=Profile
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    SearchScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
        backgroundColor: Colors.pink[400],
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: _selectedIndex == 0 ? 40 : 25),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt, size: _selectedIndex == 1 ? 40 : 25),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.text_snippet, size: _selectedIndex == 2 ? 40 : 25),
            label: '',
          ),
        ],
      ),
    );
  }
}
