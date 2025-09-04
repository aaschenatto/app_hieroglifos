import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/database/dao/history_dao.dart';
import 'package:flutter_application_3/model/history_model.dart';

class InicialHistory extends StatefulWidget {
  const InicialHistory({super.key});

  @override
  State<InicialHistory> createState() => _InicialHistoryState();
}

class _InicialHistoryState extends State<InicialHistory> {
  final dao = HistoryDao();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F4EF),
      appBar: AppBar(
        backgroundColor: const Color(0xffBEA073),
        elevation: 4,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white, size: 32),
        title: const Text(
          "Histórico",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: FutureBuilder<List<History>>(
        future: dao.buscarTodos(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              return const Center(child: CircularProgressIndicator());

            case ConnectionState.none:
              return const Center(child: Text('Nenhuma conexão estabelecida'));

            case ConnectionState.done:
              if (snapshot.hasError) {
                return const Center(child: Text('Erro ao carregar histórico'));
              }

              final historicos = snapshot.data ?? [];

              if (historicos.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 100, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        "Nenhum histórico encontrado",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: historicos.length,
                itemBuilder: (context, index) {
                  final history = historicos[index];

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: const Text(
                                'Detalhes do Histórico',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xffBEA073),
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    history.texto,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 12),
                                  if (history.imagePath != null &&
                                      history.imagePath!.isNotEmpty &&
                                      File(history.imagePath!).existsSync())
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        File(history.imagePath!),
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    'Fechar',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child:
                                (history.imagePath != null &&
                                    history.imagePath!.isNotEmpty &&
                                    File(history.imagePath!).existsSync())
                                ? Image.file(
                                    File(history.imagePath!),
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 30,
                                      color: Colors.grey,
                                    ),
                                  ),
                          ),
                          title: Text(
                            history.texto,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              if (history.id != null) {
                                await dao.deletar(history.id!);
                                setState(() {});
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
          }
        },
      ),
    );
  }
}
