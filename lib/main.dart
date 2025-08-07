import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

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
  String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  final TextEditingController _textController = TextEditingController();
  File? _image;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> initCamera() async {
    await Permission.camera.request();
    if (await Permission.camera.isDenied) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Permissão da câmera negada')));
      return;
    }

    if (_cameras.isEmpty) {
      setState(() {
        _translation = 'Nenhuma câmera disponível no dispositivo.';
      });
      return;
    }

    _controller = CameraController(_cameras[0], ResolutionPreset.max);
    await _controller.initialize();
    if (!mounted) return;
    setState(() {
      _isCameraInitialized = true;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _takePicture() async {
    if (!_controller.value.isInitialized) return;

    final directory = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${directory.path}/images');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final String imagePath =
        '${imagesDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    try {
      final file = await _controller.takePicture();
      await file.saveTo(imagePath);
      setState(() {
        _imagePath = imagePath;
        _translation = null;
        _textController.clear();
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Foto salva em $imagePath')));
      await _sendToGemini(imagePath);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _sendToGemini(String imagePath) async {
    if (apiKey.isEmpty) {
      setState(() {
        _translation = 'Chave de API não encontrada. Verifique o arquivo .env.';
      });
      debugPrint('[DEBUG] API Key vazia');
      return;
    }

    setState(() {
      _isLoading = true;
      _translation = null;
    });

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1/models/gemini-pro-vision:generateContent?key=$apiKey',
    );
    final bytes = await File(imagePath).readAsBytes();
    final base64Image = base64Encode(bytes);

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {
              "text":
                  "Traduza os hieróglifos egípcios desta imagem para português. Se não houver hieróglifos, responda apenas 'Nenhum hieróglifo encontrado.'",
            },
            {
              "inlineData": {"mimeType": "image/jpeg", "data": base64Image},
            },
          ],
        },
      ],
    });

    debugPrint('[DEBUG] Enviando requisição para Gemini...');
    debugPrint('[DEBUG] URL: $url');
    debugPrint('[DEBUG] Tamanho da imagem base64: ${base64Image.length}');
    debugPrint('[DEBUG] Corpo da requisição:\n$body');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      debugPrint('[DEBUG] Status da resposta: ${response.statusCode}');
      debugPrint('[DEBUG] Corpo da resposta:\n${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String? result;
        try {
          result = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        } catch (e) {
          debugPrint('[DEBUG] Erro ao extrair resultado da resposta: $e');
        }
        result ??= 'Sem resposta da IA';

        setState(() {
          _translation = result;
          _textController.text = result!;
        });
      } else {
        setState(() {
          _translation = 'Erro na tradução: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _translation = 'Erro ao conectar à API Gemini: $e';
      });
      debugPrint('[DEBUG] Exceção na requisição: $e');
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
          child: Image.asset('assets/images/oraculum_logo.png', height: 48),
        ),
        backgroundColor: Color(0xffBEA073),
        elevation: 2,
      ),
      body: _isCameraInitialized
          ? Column(
              children: [
                SizedBox(height: 16),
                Expanded(
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 4),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CameraPreview(_controller),
                        ),
                      ),
                    ),
                  ),
                ),
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
                      controller: _textController,
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Color(0xffBEA073),
                            width: 2.0,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: _isLoading ? null : _takePicture,
                          icon: Icon(Icons.camera_enhance_rounded),
                        ),
                      ),
                      SizedBox(width: 24),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Color(0xffBEA073),
                            width: 2.0,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: _isLoading ? null : _pickImage,
                          icon: Icon(Icons.photo_library_rounded),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
