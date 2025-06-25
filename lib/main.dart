import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'camera.dart';
import 'description_screen.dart';

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
      child: Text('Home Screen', style: TextStyle(fontSize: 24)),
    );
  }
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  Future<void> _openCamera(BuildContext context) async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No cameras found on this device.')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CameraScreen(cameras: cameras)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final picker = ImagePicker();
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            // Identificar (abrir cámara)
            ElevatedButton.icon(
              onPressed: () => _openCamera(context),
              icon: const Icon(Icons.camera_alt, size: 34, color: Colors.white),
              label: const Text('Identificar',
                  style: TextStyle(fontSize: 20, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.all(20),
                minimumSize: const Size(300, 100),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),

            // Subir (galería → DescriptionScreen)
            ElevatedButton.icon(
              onPressed: () async {
                final XFile? pickedFile =
                    await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  // Datos de ejemplo; luego vendrán de tu back
                  const fakeDesc =
                      'El impresionismo es un movimiento pictórico surgido en Francia a finales del siglo XIX que busca captar la impresión visual de un instante...';
                  final fakeTechniques = [
                    {
                      'title': 'Pintura al aire libre (plein air)',
                      'subtitle':
                          'Trabajar sobre el motivo directamente, captando la luz cambiante en exteriores.'
                    },
                    {
                      'title': 'Pinceladas sueltas y fragmentadas',
                      'subtitle':
                          'Trazos cortos y visibles que sugieren formas sin difuminar en exceso, aportando dinamismo.'
                    },
                    {
                      'title': 'Color roto (“broken color”)',
                      'subtitle':
                          'Manchas de pigmento puro yuxtapuestas que el ojo fusiona ópticamente a distancia.'
                    },
                  ];

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DescriptionScreen(
                        imagePath: pickedFile.path,
                        styleName: 'Impresionista',
                        description: fakeDesc,
                        techniques: fakeTechniques,
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.upload, size: 34, color: Colors.white),
              label: const Text('Subir',
                  style: TextStyle(fontSize: 20, color: Colors.white)),
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
            icon:
                Icon(Icons.camera_alt, size: _selectedIndex == 1 ? 40 : 25),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.text_snippet,
                size: _selectedIndex == 2 ? 40 : 25),
            label: '',
          ),
        ],
      ),
    );
  }
}
