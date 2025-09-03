import 'package:flutter_application_3/database/dao/history_dao.dart';
import 'package:flutter_application_3/model/history_model.dart';

import './main.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final dao = HistoryDao();

String prompt = '';

String api_key = dotenv.env['api_key']!;

Future<String?> enviarparagemini(path) async {
  final apiKey = '$api_key'; // Substitua pela sua chave de API
  final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);

  // Carrega a imagem dos assets corretamente

  final file = File(path);
  final imageBytes = await file.readAsBytes();

  print("bytes" + imageBytes.toString());

  if (idioma == 1) {
    prompt =
        'Traduza os hieróglifos egípcios desta imagem para uma mensagem clara em português, limite-se a 200 caracteres e seja direto. Se não houver hieróglifos, responda apenas Nenhum hieróglifo encontrado. Já foi informado ao usuário que o contexto do texto prescisa de conhecimento especializado, não inclua essa mensagem em sua resposta.';
  }
  if (idioma == 2) {
    prompt =
        'Traduza os hieróglifos egípcios desta imagem para uma mensagem clara em Espanhol, limite-se a 200 caracteres e seja direto. Se não houver hieróglifos, responda apenas Nenhum hieróglifo encontrado. Já foi informado ao usuário que o contexto do texto prescisa de conhecimento especializado, não inclua essa mensagem em sua resposta.';
  }
  if (idioma == 3) {
    prompt =
        'Traduza os hieróglifos egípcios desta imagem para uma mensagem clara em Inglês, limite-se a 200 caracteres e seja direto. Se não houver hieróglifos, responda apenas Nenhum hieróglifo encontrado. Já foi informado ao usuário que o contexto do texto prescisa de conhecimento especializado, não inclua essa mensagem em sua resposta.';
  }

  // Cria o conteúdo da requisição
  final content = Content.multi([
    DataPart('image/jpeg', imageBytes),
    TextPart(prompt),
  ]);

  // Mandar para o modelo
  final response = await model.generateContent([content]);

  // Mostra a resposta
  print(response.text);
  return response.text;
}
