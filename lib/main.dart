import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Brand Logo Detector',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF37474F), // Blue Grey 800
          brightness: Brightness.dark,
          surface: const Color(0xFF1E1E1E),
          background: const Color(0xFF121212),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Color(0xFF121212),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF37474F),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 4,
          ),
        ),
        cardTheme: ThemeData.dark().cardTheme.copyWith(
          color: const Color(0xFF1E1E1E),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(8.0),
        ),
      ),
      home: MyHomePage(cameras: cameras),
    );
  }
}

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _defaultUserId = 'default_user';

  Future<void> saveDetection(DetectionResult result) async {
    await _firestore.collection('users').doc(_defaultUserId).collection('detections').add({
      'brandName': result.brandName,
      'confidence': result.confidence,
      'timestamp': result.timestamp,
      'imageUrl': result.imagePath,
    });
  }

  Future<List<DetectionResult>> getDetections() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_defaultUserId)
        .collection('detections')
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return DetectionResult(
        brandName: doc['brandName'],
        confidence: doc['confidence'],
        timestamp: (doc['timestamp'] as Timestamp).toDate(),
        imagePath: doc['imageUrl'] as String?,
      );
    }).toList();
  }

  Stream<List<DetectionResult>> getDetectionsStream() {
    return _firestore
        .collection('users')
        .doc(_defaultUserId)
        .collection('detections')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return DetectionResult(
          brandName: doc['brandName'],
          confidence: doc['confidence'],
          timestamp: (doc['timestamp'] as Timestamp).toDate(),
          imagePath: doc['imageUrl'] as String?,
        );
      }).toList();
    });
  }
}

class MyHomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const MyHomePage({super.key, required this.cameras});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Car Brands',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1A237E),
                    const Color(0xFF0D47A1),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1976D2).withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -40,
                    top: -40,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -60,
                    bottom: -60,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue[300]!,
                              Colors.blue[600]!,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withValues(alpha: 0.5),
                              blurRadius: 15,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.directions_car_filled,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'SELECT YOUR BRAND',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 3,
                        width: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue[300]!,
                              Colors.cyan,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Choose a manufacturer to explore detection',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
                          color: Colors.blue[100],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.95,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: carBrands.length,
                itemBuilder: (context, index) {
                  final brand = carBrands[index];
                  return _buildBrandCard(context, brand);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HistoryScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.history),
                  label: const Text('View Detection History'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandCard(BuildContext context, CarBrand brand) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetectionScreen(
              cameras: widget.cameras,
              brand: brand,
            ),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF2D2D2D),
                const Color(0xFF1A1A1A),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  brand.icon,
                  size: 100,
                  color: Colors.white.withValues(alpha: 0.03),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: brand.color.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.3),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          brand.imagePath,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    brand.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 2,
                    width: 30,
                    color: brand.color,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      brand.description,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[400],
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CarBrand {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String imagePath;

  CarBrand({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.imagePath,
  });
}

class DetectionResult {
  final String brandName;
  final double confidence;
  final DateTime timestamp;
  final String? imagePath;

  DetectionResult({
    required this.brandName,
    required this.confidence,
    required this.timestamp,
    this.imagePath,
  });
}

final List<CarBrand> carBrands = [
  CarBrand(
    id: '0',
    name: 'Toyota',
    description: 'World\'s largest automaker specializing in hybrid and electric vehicles.',
    icon: Icons.directions_car,
    color: Colors.blue,
    imagePath: 'assets/Toyota.jpg',
  ),
  CarBrand(
    id: '1',
    name: 'Nissan',
    description: 'Japanese automaker known for reliability and performance.',
    icon: Icons.directions_car,
    color: Colors.lightBlue,
    imagePath: 'assets/Nissan.jpg',
  ),
  CarBrand(
    id: '2',
    name: 'Honda',
    description: 'Japanese automotive manufacturer known for reliability and innovation.',
    icon: Icons.directions_car,
    color: Colors.red,
    imagePath: 'assets/Honda.jpg',
  ),
  CarBrand(
    id: '3',
    name: 'Mitsubishi',
    description: 'Japanese manufacturer specializing in SUVs and robust vehicles.',
    icon: Icons.directions_car,
    color: Colors.red,
    imagePath: 'assets/Mitsubishi.jpg',
  ),
  CarBrand(
    id: '4',
    name: 'Ford',
    description: 'American automotive pioneer known for trucks and SUVs.',
    icon: Icons.directions_car,
    color: Colors.blueGrey,
    imagePath: 'assets/Ford.jpg',
  ),
  CarBrand(
    id: '5',
    name: 'Mazda',
    description: 'Japanese brand focusing on stylish design and driving pleasure.',
    icon: Icons.directions_car,
    color: Colors.orange,
    imagePath: 'assets/Mazda.jpg',
  ),
  CarBrand(
    id: '6',
    name: 'Hyundai',
    description: 'South Korean manufacturer known for value, reliability, and modern design.',
    icon: Icons.directions_car,
    color: Colors.indigo,
    imagePath: 'assets/Hyundai.jpg',
  ),
  CarBrand(
    id: '7',
    name: 'Chevrolet',
    description: 'American brand known for trucks, SUVs, and performance cars.',
    icon: Icons.directions_car,
    color: Colors.amber,
    imagePath: 'assets/Chevrolet.jpg',
  ),
  CarBrand(
    id: '8',
    name: 'Kia',
    description: 'South Korean brand known for stylish design and industry-leading warranty.',
    icon: Icons.directions_car,
    color: Colors.deepPurple,
    imagePath: 'assets/Kia.jpg',
  ),
  CarBrand(
    id: '9',
    name: 'Isuzu',
    description: 'Japanese manufacturer known for commercial vehicles and diesel engines.',
    icon: Icons.directions_car,
    color: Colors.redAccent,
    imagePath: 'assets/Isuzu.jpg',
  ),
];

class MLService {
  static final MLService _instance = MLService._internal();
  late Interpreter _interpreter;
  late List<String> _labels;
  bool _isInitialized = false;

  factory MLService() {
    return _instance;
  }

  MLService._internal();

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _interpreter = await Interpreter.fromAsset('assets/model_unquant.tflite');
      
      final labelsData = await rootBundle.loadString('assets/labels.txt');
      
      _labels = labelsData.split('\n')
          .where((line) => line.isNotEmpty)
          .map((line) => line.split(' ').skip(1).join(' '))
          .toList();
      
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize ML service: $e');
    }
  }

  Future<DetectionResult> detectImage(File imageFile) async {
    if (!_isInitialized) {
      throw Exception('ML Service not initialized');
    }

    try {
      final bytes = imageFile.readAsBytesSync();
      var image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      image = img.copyResize(image, width: 224, height: 224);

      final inputData = <List<List<List<double>>>>[
        List.generate(224, (i) => 
          List.generate(224, (j) {
            final pixel = image!.getPixelSafe(j, i);
            return [
              (pixel.r - 127.5) / 127.5,
              (pixel.g - 127.5) / 127.5,
              (pixel.b - 127.5) / 127.5,
            ];
          })
        )
      ];

      var output = List.filled(1 * _labels.length, 0.0).reshape([1, _labels.length]);

      _interpreter.run(inputData, output);

      List<double> results = output[0].cast<double>();
      
      int maxIndex = results.indexOf(results.reduce((a, b) => a > b ? a : b));
      double confidence = results[maxIndex];

      return DetectionResult(
        brandName: _labels[maxIndex],
        confidence: confidence,
        timestamp: DateTime.now(),
        imagePath: imageFile.path,
      );
    } catch (e) {
      throw Exception('Failed to run inference: $e');
    }
  }
}

class DetectionScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final CarBrand brand;

  const DetectionScreen({
    super.key,
    required this.cameras,
    required this.brand,
  });

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.brand.name),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF263238),
                    const Color(0xFF121212),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.brand.color,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.brand.color.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        widget.brand.imagePath,
                        width: 160,
                        height: 160,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    widget.brand.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 4,
                    width: 60,
                    color: widget.brand.color,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Text(
                      widget.brand.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[300],
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CameraScreen(
                              cameras: widget.cameras,
                              brand: widget.brand,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.camera_alt, size: 24),
                      label: const Text(
                        'START CAMERA DETECTION',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        backgroundColor: widget.brand.color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GalleryScreen(brand: widget.brand),
                          ),
                        );
                      },
                      icon: const Icon(Icons.image, size: 24),
                      label: const Text(
                        'SELECT FROM GALLERY',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        side: BorderSide(color: widget.brand.color, width: 2),
                        foregroundColor: widget.brand.color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final CarBrand brand;

  const CameraScreen({
    super.key,
    required this.cameras,
    required this.brand,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final MLService _mlService = MLService();
  final FirebaseService _firebaseService = FirebaseService();
  DetectionResult? _lastResult;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.cameras[0],
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
    _initializeML();
  }

  Future<void> _initializeML() async {
    try {
      await _mlService.initialize();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ML initialization error: $e')),
        );
      }
    }
  }

  Future<void> _captureAndDetect() async {
    if (_isProcessing) return;
    
    try {
      _isProcessing = true;
      final image = await _controller.takePicture();
      final result = await _mlService.detectImage(File(image.path));
      
      setState(() {
        _lastResult = result;
      });

      await _firebaseService.saveDetection(result);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Detection saved to Firestore!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Detection error: $e')),
        );
      }
    } finally {
      _isProcessing = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.brand.name} - Camera Detection')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_controller),
                if (_lastResult != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.9),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _lastResult!.brandName.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 4,
                                  width: 40,
                                  color: widget.brand.color,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'CONFIDENCE: ${(_lastResult!.confidence * 100).toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            _lastResult = null;
                                          });
                                        },
                                        icon: const Icon(Icons.refresh),
                                        label: const Text('AGAIN'),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          side: BorderSide(color: Colors.grey[700]!),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        icon: const Icon(Icons.home),
                                        label: const Text('HOME'),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          backgroundColor: widget.brand.color,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isProcessing ? null : _captureAndDetect,
        child: _isProcessing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.camera),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class GalleryScreen extends StatefulWidget {
  final CarBrand brand;

  const GalleryScreen({super.key, required this.brand});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final ImagePicker _picker = ImagePicker();
  final MLService _mlService = MLService();
  final FirebaseService _firebaseService = FirebaseService();
  DetectionResult? _result;
  File? _selectedImage;
  bool _isProcessing = false;
  String? _errorMessage;

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _result = null;
          _errorMessage = null;
        });
        // Add a small delay to ensure UI updates before processing
        await Future.delayed(const Duration(milliseconds: 100));
        await _detectImage();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _detectImage() async {
    if (_selectedImage == null || _isProcessing) return;

    try {
      setState(() {
        _isProcessing = true;
        _errorMessage = null;
      });
      
      await _mlService.initialize();
      final result = await _mlService.detectImage(_selectedImage!);
      
      setState(() {
        _result = result;
        _isProcessing = false;
      });

      await _firebaseService.saveDetection(result);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Detection saved to Firestore!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Detection error: ${e.toString()}';
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Detection error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.brand.name} - Gallery Detection')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (_selectedImage != null)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.file(
                    _selectedImage!,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('No image selected'),
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Pick Image'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),
              if (_isProcessing)
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                )
              else if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red.withValues(alpha: 0.2),
                        ),
                        child: const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Detection Failed',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red.withValues(alpha: 0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text('Try Another Image'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                )
              else if (_result != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Detection Result',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Color(0xFF6366F1),
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _result!.brandName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Confidence: ${(_result!.confidence * 100).toStringAsFixed(2)}%',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _selectedImage = null;
                                  _result = null;
                                  _errorMessage = null;
                                });
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Try Again'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.home),
                              label: const Text('Home'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detection History'),
        elevation: 0,
      ),
      body: StreamBuilder<List<DetectionResult>>(
        stream: _firebaseService.getDetectionsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final history = snapshot.data ?? [];

          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Detection History Yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start detecting car brands to see results',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final result = history[index];
              return _buildHistoryCard(result);
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(DetectionResult result) {
    final confidence = result.confidence * 100;
    final confidenceColor = confidence > 80
        ? Colors.green
        : confidence > 60
            ? Colors.orange
            : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.grey.withValues(alpha: 0.05),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1).withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.directions_car,
                color: Color(0xFF6366F1),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.brandName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: confidenceColor,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${confidence.toStringAsFixed(1)}% Confidence',
                        style: TextStyle(
                          fontSize: 12,
                          color: confidenceColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              _formatTime(result.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
