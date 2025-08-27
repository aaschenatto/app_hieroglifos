import './main.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';

String prompt = '';

Future<String?> enviarparagemini(path) async {
  final apiKey = 'Insira sua chave api' ;
  final model = GenerativeModel(
    model: 'gemini-2.5-flash',
    apiKey: apiKey,
  );
  
  // Carrega a imagem dos assets corretamente

  final file = File(path);
  final imageBytes = await file.readAsBytes();

  print("bytes"+imageBytes.toString());
  
  if(idioma == 1){prompt =  'Traduza os hieróglifos egípcios desta imagem para uma mensagem clara em português, limite-se a 200 caracteres e seja direto. Se não houver hieróglifos, responda apenas Nenhum hieróglifo encontrado. Já foi informado ao usuário que o contexto do texto prescisa de conhecimento eespecializado, não inclua essa mensagem em sua resposta.';}
  if(idioma == 2){prompt =  'Traduza os hieróglifos egípcios desta imagem para uma mensagem clara em Espanhol, limite-se a 200 caracteres e seja direto. Se não houver hieróglifos, responda apenas Nenhum hieróglifo encontrado. Já foi informado ao usuário que o contexto do texto prescisa de conhecimento eespecializado, não inclua essa mensagem em sua resposta.';}
  if(idioma == 3){prompt =  'Traduza os hieróglifos egípcios desta imagem para uma mensagem clara em Inglês, limite-se a 200 caracteres e seja direto. Se não houver hieróglifos, responda apenas Nenhum hieróglifo encontrado. Já foi informado ao usuário que o contexto do texto prescisa de conhecimento eespecializado, não inclua essa mensagem em sua resposta.';}

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