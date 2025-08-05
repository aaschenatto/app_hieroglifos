import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

late List<CameraDescription> _cameras;


       

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  _cameras = await availableCameras();
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: TelaInicial()));
}

class TelaInicial extends StatefulWidget {
  @override
  _TelaInicialState createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  late CameraController _controller;
  bool _isCameraInitialized = false;
  String? _imagePath;
  String? _translation;
  bool _isLoading = false;
  String apiKey = dotenv.get('apiKey');

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void initCamera() async {
    _controller = CameraController(_cameras[0], ResolutionPreset.max);
    await _controller.initialize();
    if (!mounted) return;
    setState(() {
      _isCameraInitialized = true;
    });
  }

  Future<void> _takePicture() async {
    if (!_controller.value.isInitialized) return;
    final directory = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${directory.path}/images');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    final String imagePath = '${imagesDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    try {
      await _controller.takePicture().then((XFile file) async {
        await file.saveTo(imagePath);
        setState(() {
          _imagePath = imagePath;
          _translation = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Foto salva em $imagePath')),
        );
        await _sendToOpenAI(imagePath);
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _sendToOpenAI(String imagePath) async {
    setState(() {
      _isLoading = true;
      _translation = null;
    });

    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final bytes = await File(imagePath).readAsBytes();
    final base64Image = base64Encode(bytes);

    final body = jsonEncode({
      "model": "gpt-4-vision-preview",
      "messages": [
        {
          "role": "user",
          "content": [
            {
              "type": "text",
              "text": "Traduza os hieróglifos egípcios desta imagem para português. Se não houver hieróglifos, responda apenas 'Nenhum hieróglifo encontrado.'"
            },
            {
              "type": "image_url",
              "image_url": {
                "url": "data:image/jpeg;base64,$base64Image"
              }
            }
          ]
        }
      ],
      "max_tokens": 300
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['choices'][0]['message']['content'];
        setState(() {
          _translation = result;
        });
      } else {
        setState(() {
          _translation = 'Erro na tradução: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _translation = 'Erro ao conectar à API: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Image.asset(
        'images/oraculum_logo.png',
        height: 48,
          ),
        ),
        backgroundColor: Color(0xffBEA073),
        elevation: 2,
      ),
      
      body: _isCameraInitialized
          ? Column(
              children: [
                Expanded(child: CameraPreview(_controller)),
                if (_imagePath != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.file(File(_imagePath!)),
                  ),
                if (_isLoading)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                if (_translation != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: TextEditingController(text: _translation!),
                      maxLines: null,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Tradução dos Hieróglifos',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                    child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Color(0xffBEA073), width: 2.0),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _isLoading ? null : _takePicture,
                      icon: Icon(Icons.camera_enhance_rounded),
                    ),
                    )
                ),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    ); //aaaaaaaaaaaaaaaaaa
  }
}

