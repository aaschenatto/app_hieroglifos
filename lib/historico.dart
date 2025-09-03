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
      appBar: AppBar(
        backgroundColor: const Color(0xffBEA073),
        title: const Text("Histórico"),
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
                      const Text("Nenhum histórico encontrado"),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: historicos.length,
                itemBuilder: (context, index) {
                  final history = historicos[index];

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Card(
                      color: const Color.fromARGB(171, 190, 160, 115),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: ListTile(
                        leading:
                            (history.imagePath!.isNotEmpty &&
                                File(history.imagePath!).existsSync())
                            ? Image.file(
                                File(history.imagePath!),
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : const Icon(
                                Icons.image_not_supported_outlined,
                                size: 50,
                                color: Colors.grey,
                              ),
                        title: Text(
                          history.texto,
                          style: TextStyle(color: Colors.white),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white),
                          onPressed: () async {
                            if (history.id != null) {
                              await dao.deletar(history.id!);
                              setState(() {});
                            }
                          },
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Detalhes do Histórico'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Texto: ${history.texto}",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 10),
                                  //   if (history.imagePath!.isNotEmpty &&
                                  //       File(history.imagePath!).existsSync())
                                  //     Image.file(
                                  //       File(history.imagePath!),
                                  //       height: 150,
                                  //       width: double.infinity,
                                  //       fit: BoxFit.cover,
                                  //     ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    'Fechar',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
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
