import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
//import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
//import 'package:path_provider/path_provider.dart';
//import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
const String cloudinaryUploadPreset = 'authapp';
const String cloudinaryCloudName = 'dfhrq3bbi';




class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final TextEditingController _titleController = TextEditingController();
  CameraController? _cameraController;
  XFile? _capturedImage;
  bool _isUploading = false;
  Position? _currentPosition;
  String? _currentAddress;

@override
void initState() {
  super.initState();
  _initializeCameraAndLocation();
  
}



Future<void> _initializeCameraAndLocation() async {
  // Request both camera and location permissions
  final cameraStatus = await Permission.camera.request();
  final locationStatus = await Permission.locationWhenInUse.request();

  if (!mounted) return;

  // Handle denied permissions
  if (cameraStatus != PermissionStatus.granted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Camera permission denied')),
    );
    return;
  }

  if (locationStatus != PermissionStatus.granted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location permission denied')),
    );
    return;
  }

  // Initialize camera
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  _cameraController = CameraController(
    firstCamera,
    ResolutionPreset.medium,
  );

  await _cameraController!.initialize();

  // Get location
  _currentPosition = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  if (mounted) setState(() {});
}

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    final image = await _cameraController!.takePicture();
    setState(() {
      _capturedImage = image;
    });
  }

  Future<void> _submitReport() async {
  final title = _titleController.text.trim();
  if (title.isEmpty || _capturedImage == null || _currentPosition == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please capture photo and enter title')),
    );
    return;
  }

  setState(() => _isUploading = true);

  try {
    // Step 1: Upload to Cloudinary
    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = cloudinaryUploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', _capturedImage!.path));

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Failed to upload image to Cloudinary');
    }

    final responseData = json.decode(await response.stream.bytesToString());
    final imageUrl = responseData['secure_url'];

    // Step 2: Convert lat/lng to address
    String address = '';
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        address =
            '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
      }
    } catch (e) {
      address = '';
    }

    // Step 3: Save to Firestore
    await FirebaseFirestore.instance.collection('issues').add({
      'title': title,
      'description': '',
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'location': {
        'lat': _currentPosition!.latitude,
        'lng': _currentPosition!.longitude,
        'address': address,
      },
      'upvotes': 0,
      'status': 'Pending',
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Issue reported successfully')),
      );
      Navigator.pop(context);
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error submitting report')),
      );
    }
  } finally {
    if (mounted) setState(() => _isUploading = false);
  }
}


  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Report an Issue')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(child: CameraPreview(_cameraController!)),
            const SizedBox(height: 10),
            if (_capturedImage != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.file(File(_capturedImage!.path), height: 150),
                  const SizedBox(height: 8),
                  const Text('Location:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    _currentAddress != null
                        ? _currentAddress!
                        : _currentPosition != null
                            ? 'Lat: ${_currentPosition!.latitude}, Lng: ${_currentPosition!.longitude}'
                            : 'Location not available',
                  ),
                ],
              ),
            const SizedBox(height: 10),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),
            _isUploading
                ? const CircularProgressIndicator()
                : Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _takePicture,
                          child: const Text('Capture Photo'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _submitReport,
                          child: const Text('Submit'),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
