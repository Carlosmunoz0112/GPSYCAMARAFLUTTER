import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.teal, // Cambiado a un color teal
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página Principal'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CameraScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.orange, // Cambiado a un color naranja
                minimumSize: const Size(150, 50), // Tamaño del botón
              ),
              child: const Text(
                'Cámara',
                style: TextStyle(fontSize: 18), // Tamaño del texto
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LocationScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green, // Cambiado a un color verde
                minimumSize: const Size(150, 50), // Tamaño del botón
              ),
              child: const Text(
                'Geolocalización',
                style: TextStyle(fontSize: 18), // Tamaño del texto
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _takePicture() async {
    // Solicitar permiso de cámara
    var cameraStatus = await Permission.camera.status;
    if (cameraStatus.isDenied) {
      await Permission.camera.request();
    }

    // Tomar la foto si se concede el permiso
    if (await Permission.camera.isGranted) {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);

      setState(() {
        _imageFile = image != null ? File(image.path) : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Asociamos el GlobalKey al Scaffold
      appBar: AppBar(
        title: const Text('Pantalla de Cámara'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _takePicture,
            style: ElevatedButton.styleFrom(
              primary: Colors.blue, // Cambiado a un color azul
              minimumSize: const Size(150, 50), // Tamaño del botón
            ),
            child: const Text(
              'Tomar Foto',
              style: TextStyle(fontSize: 18), // Tamaño del texto
            ),
          ),
          if (_imageFile != null)
            Column(
              children: [
                const SizedBox(height: 20),
                const Text('La foto tomada es:'),
                Image.file(_imageFile!),
              ],
            ),
        ],
      ),
    );
  }
}

class LocationScreen extends StatelessWidget {
  const LocationScreen({Key? key});

  Future<void> _getLocation(BuildContext context) async {
    // Solicitar permiso de ubicación
    var status = await Permission.location.status;
    if (status.isDenied) {
      // Si los permisos están denegados, solicitarlos
      var result = await Permission.location.request();
      if (result.isDenied) {
        // Si el usuario deniega los permisos, mostrar un mensaje
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Se requieren permisos de ubicación para obtener la información de ubicación.'),
        ));
        return;
      }
    }

    // Obtener la ubicación si se concede el permiso
    if (await Permission.location.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        final String locationInfo =
            'Latitud: ${position.latitude}, Longitud: ${position.longitude}';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(locationInfo),
        ));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error: no se puede obtener la ubicación.'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantalla de Geolocalización'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => _getLocation(context),
            style: ElevatedButton.styleFrom(
              primary: Colors.purple, // Cambiado a un color morado
              minimumSize: const Size(150, 50), // Tamaño del botón
            ),
            child: const Text(
              'Obtener Geolocalización',
              style: TextStyle(fontSize: 18), // Tamaño del texto
            ),
          ),
        ],
      ),
    );
  }
}
