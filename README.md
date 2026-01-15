# CBF — Aplicativo Flutter

Aplicativo Flutter para visualização de jogadores, rankings e scouts.

**Principais recursos**
- Listagem de jogadores com filtros por posição
- Tela de detalhes do jogador com histórico de rodadas e gráficos
- Rankings por rodada e temporada
- Serviços para consumir API REST (configurável em `lib/services/api_config.dart`)

**Stack**
- Flutter (Material 3)
- Packages: `google_fonts`, `http`, `shared_preferences`, `fl_chart`

**Estrutura relevante**
- `lib/screens/` — telas da aplicação
- `lib/services/` — chamadas à API e lógica de rede
- `lib/models/` — modelos de dados (Jogador, JogadorRodada, ScoutRanking)
- `lib/constants/posicoes.dart` — mapeamento posicao code ↔ ID (GOL→1, LAT→2, ZAG→3, MEI→4, ATA→5, TEC→6)

## Pré-requisitos
- Flutter SDK (compatível com a versão do projeto)
- Android Studio / Xcode toolchain para emulação ou dispositivos reais

## Instalação e execução

1. Clone o repositório

```bash
git clone <repo-url>
cd cbf
```

2. Instale dependências

```bash
flutter pub get
```

3. Ajuste a URL da API se necessário (ex.: `lib/services/api_config.dart`)

4. Execute no dispositivo/emulador

```bash
flutter run
```

5. Gerar APK (opcional)

```bash
flutter build apk --release
```

## Configuração da API

A URL da API padrão está em [lib/services/api_config.dart](lib/services/api_config.dart). Atualize `baseUrl` se necessário.

## Observações de desenvolvimento
- Durante o desenvolvimento existem alguns `print` de depuração espalhados — remova-os antes do build de produção.
- Importante: `clube_id` e `posicao_id` são inteiros na API; a aplicação faz conversão automática de códigos de posição (GOL/ZAG/...) para IDs em `lib/constants/posicoes.dart`.

## Testes e depuração
- Não há testes unitários automatizados neste repositório atualmente.
- Use `flutter run` e observe o terminal para logs de API e parsing.

## Erros comuns
- HTTP 400 ao filtrar por posição: verifique se o parâmetro `posicao` enviado é um número (1–6). O arquivo `lib/constants/posicoes.dart` faz essa conversão.

## Contribuição
- Abra uma issue ou envie um pull request com melhorias.

## Contato
- Desenvolvedor: (adicione seu contato aqui)

---
Arquivo principal de configuração da API: [lib/services/api_config.dart](lib/services/api_config.dart)
# cbf

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
