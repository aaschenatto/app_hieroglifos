import 'package:flutter/services.dart' show rootBundle;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';


Future<String?> enviarparagemini(path) async {
  final apiKey = 'AIzaSyA87QHo675Zkp8Qas5tstnCVEKtywPJxiA'; // Substitua pela sua chave real
  final model = GenerativeModel(
    model: 'gemini-2.5-flash',
    apiKey: apiKey,
  );

  print("ele denovo:" + path);

  

  // Carrega a imagem dos assets corretamente
  final file = File(path);
  final imageBytes = await file.readAsBytes();

  print("bytes"+imageBytes.toString());

  // Cria o conteúdo da requisição
  final content = Content.multi([
    DataPart('image/jpeg', imageBytes),
    TextPart('Traduza os hieróglifos egípcios desta imagem para uma mensagem clara em português, limite-se a 200 caracteres e seja direto. Se não houver hieróglifos, responda apenas Nenhum hieróglifo encontrado. Já foi informado ao usuário que o contexto do texto prescisa de conhecimento eespecializado, não inclua essa mensagem em sua resposta.'),
  ]);

  // Envia para o modelo
  final response = await model.generateContent([content]);

  // Mostra a resposta
  print(response.text);
  return response.text;
}