
# 📜 ORACULUM


O **Oraculum** é um aplicativo inovador que utiliza **inteligência artificial** para **"traduzir" papiros e textos antigos**, tornando o conhecimento histórico acessível, interpretável e relevante nos dias de hoje.

## ℹ️ Sobre o Projeto

Durante séculos, manuscritos antigos permaneceram como enigmas para a maioria das pessoas. Com o Oraculum, unimos a tecnologia e a paixão pela história para dar **voz ao passado**.

#### 🎯 Objetivo

- A aplicação busca transformar imagens de papiros e documentos antigos em texto legível e traduzido para o português, com ajuda de uma inteligência artificial treinada para interpretação paleográfica e linguística.

---

## 🧐 Funcionalidades

- 📸 Captura de imagens ou upload direto da galeria do celular
- 🔍 Detecção e extração de texto antigo
- 🌐 Tradução automática utilizando IA
- 🧠 Reconhecimento de padrões históricos e simbólicos

---

## 🛠️ Tecnologias Utilizadas

- Flutter (interface mobile)
- API Gemini (leitura de imagens)
- Câmera do dispositivo (captura da imagem)

--- 
## ⚙️ API Gemini

A API utilizada no app é a API do gemini, que é usada para realizar a análise de imagens dos hieróglifos e retornar para o usuário um texto
com os simbolos traduzidos. Se não for possível descobrir a tradução exata, o contexto das inscrições será retornado.

````bash
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

  // Cria o conteúdo da requisição
  final content = Content.multi([
    DataPart('image/jpeg', imageBytes),
    TextPart('Prompt'),
  ]);

  // Mandar para o modelo
  final response = await model.generateContent([content]);

  // Mostra a resposta
  print(response.text);
  return response.text;
}
````
Vale ressaltar que a imagem prescisa passar por tratamento para ser lida corretamente pela API.
---
## 📦 Instalação
1. Clone o repositório do app usando o git clone
```bash
git clone https://github.com/aaschenatto/app_hieroglifos.git
````
2. Instale todas os pacotes necessários com flutter pub get
```bash
flutter pub get
````
3. Insira a sua própria chave da Gemini API no arquivo logica.dart

4. Conecte o dispositivo mobile desejado, ative a depuração USB e instale o app
