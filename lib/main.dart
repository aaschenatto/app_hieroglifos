import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_application_3/buttons.dart';
import 'package:flutter_application_3/database/dao/history_dao.dart';
import 'package:flutter_application_3/historico.dart';
import 'package:flutter_application_3/model/history_model.dart';
import 'package:flutter_application_3/splashscreen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import './logica.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Pacote para popup
import 'package:flutter_popup_card/flutter_popup_card.dart';

late List<CameraDescription> _cameras;

int idioma = 1;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  _cameras = await availableCameras();
  await dotenv.load(fileName: ".env");
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen()));
}

class TelaInicial extends StatefulWidget {
  @override
  _TelaInicialState createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  late CameraController _controller;

  XFile? savedImage;

  bool _isCameraInitialized = false;
  bool isPremium = false;
  String? _imagePath;
  bool _isLoading = false;
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
        showPopupCard(
          context: context,
          builder: (context) {
            return PopupCard(
              child: Padding(
                padding: EdgeInsetsGeometry.all(15),
                child: SizedBox(
                  height: 360,
                  width: 210,
                  child: Column(
                    children: [
                      Text(
                        "Resultado da Verificação:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("nenhuma camera disponivel"),
                    ],
                  ),
                ),
              ),
            );
          },
        );
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
    if (_isLoading) return; // Evita múltiplos carregamentos

    setState(() {
      _isLoading = true;
    });

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }

    final result = await enviarparagemini(_image?.path);

    setState(() {
      _isLoading = false;
    });

    showPopupCard(
      context: context,
      builder: (context) {
        return PopupCard(
          child: Padding(
            padding: EdgeInsetsGeometry.all(15),
            child: SizedBox(
              height: 360,
              width: 210,
              child: Column(
                children: [
                  Text(
                    "Resultado da Verificação:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(result ?? 'Sem resposta'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future _takePicture() async {
    //faz a foto salva ela e manda pro gemini
    if (!_controller.value.isInitialized) return;

    final directory = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${directory.path}/images');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final String imagePath =
        '${imagesDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg'; //gera nome unico p imagem
    try {
      final file = await _controller.takePicture();

      await file.saveTo(imagePath);

      print("Caminho da imagem: $imagePath");

      setState(() {
        //salva dados da imagem
        _imagePath = imagePath;
        _textController.clear();
      });

      return await enviarparagemini(imagePath); //manda para gemini
    } catch (e) {
      print(e);
    }
  }

  Future<String> postarHistory(String texto, String imagePath) async {
    final dao = HistoryDao();

    final novo = History(texto: texto, imagePath: imagePath);

    await dao.inserir(novo);
    print("Histórico salvo localmente: ${novo.texto}");
    return "Histórico salvo localmente: ${novo.texto}";
  }

  void turnPremium() {
    isPremium = !isPremium;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isPremium
            ? Image.asset(
                'assets/images/OraculumLogoPremiumApp.png',
                height: 32,
              )
            : Image.asset('assets/images/OraculumLogoFreeApp.png', height: 32),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                turnPremium();
              });
            },
            icon: Icon(
              Icons.workspace_premium,
              color: Color(0xFFFFD700),
              size: 32,
            ),
          ),
        ],
        backgroundColor: Color(0xffBEA073),
        elevation: 2,
      ),
      body: _isCameraInitialized
          ? Column(
              children: [
                SizedBox(height: 10),
                Expanded(
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: AspectRatio(
                        aspectRatio: 0.8,
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
                    child: Container(
                      width: 250.0,
                      height: 300.0,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(_imagePath!),
                          width: 300.0,
                          height: 300.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                if (_isLoading)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),

                Visibility(
                  visible: isPremium,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xffBEA073), Color(0xff8E6B32)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: DropdownMenu<int>(
                      initialSelection: idioma,
                      onSelected: (int? value) {
                        setState(() {
                          idioma = value ?? 1;
                        });
                      },
                      width: 220,
                      menuStyle: MenuStyle(
                        backgroundColor: MaterialStateProperty.all(
                          const Color(0xffF8F8F8),
                        ),
                        elevation: MaterialStateProperty.all(6),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      inputDecorationTheme: const InputDecorationTheme(
                        border: InputBorder.none,
                      ),
                      trailingIcon: const Icon(
                        Icons.language,
                        color: Colors.white,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      dropdownMenuEntries: const <DropdownMenuEntry<int>>[
                        DropdownMenuEntry(value: 1, label: "🇧🇷  Português"),
                        DropdownMenuEntry(value: 2, label: "🇪🇸  Español"),
                        DropdownMenuEntry(value: 3, label: "🇺🇸  English"),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Visibility(
                        visible: isPremium,
                        child: CustomIconButton(
                          icon: Icons.history_edu,
                          label: "Histórico",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => InicialHistory(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 24),
                      CustomIconButton(
                        icon: Icons.camera_enhance_rounded,
                        label: "Câmera",
                        onPressed: () async {
                          if (_isLoading) return;
                          setState(() {
                            _isLoading = true;
                          });
                          try {
                            // Chama _takePicture() e envia para o Gemini
                            final result = await _takePicture();
                            await postarHistory(result, _imagePath!);
                            if (!mounted) return;
                            showPopupCard(
                              context: context,
                              builder: (context) {
                                return PopupCard(
                                  child: Padding(
                                    padding: EdgeInsetsGeometry.all(15),
                                    child: SizedBox(
                                      height: 360,
                                      width: 210,
                                      child: Column(
                                        children: [
                                          Text(
                                            "Resultado da Verificação:",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(result ?? 'Sem resposta'),
                                          //fazer o card no outro botao so dando o result como a foto escolhida
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                            if (result != null && _image?.path != null) {
                              await postarHistory(result, _image!.path);
                            }
                          } catch (e) {
                            print('Erro: $e');
                          } finally {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 24),
                      CustomIconButton(
                        icon: Icons.photo_library_rounded,
                        label: "Galeria",
                        onPressed: () {
                          _isLoading ? null : _pickImage();
                        },
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
