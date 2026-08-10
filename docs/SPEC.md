# Bing 4All — especificação

Spec de produto do cliente desktop não oficial **Bing 4All**.  
**v1 = Linux** (GNOME/KDE). **macOS = v2**.

## 1. Visão geral

Aplicativo desktop não oficial (foco Linux; macOS planejado) que consulta as imagens diárias do Bing, apresenta informações sobre cada fotografia e permite defini-las como papel de parede.

O aplicativo deve operar principalmente pela bandeja do sistema no Linux e pela barra de menus no macOS. A interface principal deve ser pequena, rápida e inspirada na experiência do Bing Wallpaper, sem copiar marcas, ícones ou elementos proprietários da Microsoft.

### Objetivos

- Atualizar o papel de parede automaticamente todos os dias.
- Permitir navegar pelas oito imagens mais recentes.
- Exibir título, descrição, data e créditos do fotógrafo.
- Usar imagens UHD sempre que disponíveis.
- Suportar múltiplos monitores.
- Funcionar em segundo plano com baixo consumo de recursos.
- Não incluir anúncios, telemetria ou alterações no navegador.
- Ser totalmente gratuito, sem versão premium, assinatura ou recursos bloqueados.
- Manter todo o código-fonte, processo de build e acompanhamento de problemas públicos.
- Manter cache local para funcionamento temporário sem internet.

### Princípios do projeto

- Código aberto desde a primeira versão.
- Todos os recursos disponíveis gratuitamente.
- Sem anúncios, rastreamento, venda de dados ou analytics oculto.
- Sem conta obrigatória e sem servidor próprio necessário.
- Configurações e imagens armazenadas somente no computador do usuário.
- Builds reproduzíveis e releases geradas por CI pública.
- Desenvolvimento, bugs e roadmap acompanhados em um repositório público.
- Doações podem ser aceitas, mas nunca devem liberar funcionalidades exclusivas.

### Licença

A licença recomendada é **GPL-3.0-or-later**. Ela permite uso, estudo, modificação e distribuição, mas exige que versões derivadas distribuídas também disponibilizem seu código-fonte sob uma licença compatível.

Se a prioridade for permitir que terceiros reutilizem o código inclusive em produtos fechados, pode-se escolher MIT ou Apache-2.0. Para preservar o aplicativo e seus derivados como software livre, a GPL-3.0 é a escolha preferida.

O repositório deve incluir:

```text
LICENSE
README.md
CONTRIBUTING.md
CODE_OF_CONDUCT.md
SECURITY.md
PRIVACY.md
```

A licença do código não abrange os wallpapers, fotografias, nome Bing ou marcas da Microsoft. Esses conteúdos continuam sujeitos aos direitos dos respectivos proprietários.

### Plataformas iniciais

- macOS 12 ou superior, Intel e Apple Silicon.
- Ubuntu 22.04 ou superior com GNOME.
- KDE Plasma 5/6.
- Suporte posterior a XFCE, Cinnamon e MATE.

## 2. Fonte dos wallpapers

### Endpoint principal

O endpoint encontrado no instalador atual do Bing Wallpaper deve ser utilizado como fonte principal:

```text
GET https://services.bingapis.com/ge-apps/api/v2/bwc/hpimages?mkt=pt-BR
```

Ele não exige chave de API e retorna até oito imagens recentes com metadados completos.

O parâmetro `mkt` define o idioma e a região:

```text
pt-BR  Português do Brasil
pt-PT  Português de Portugal
en-US  Inglês dos Estados Unidos
en-GB  Inglês do Reino Unido
es-ES  Espanhol
de-DE  Alemão
fr-FR  Francês
ja-JP  Japonês
```

O valor padrão deve ser inferido do idioma do sistema. Caso a região não seja aceita, o aplicativo deve tentar `en-US`.

### Campos utilizados

Cada item de `images` possui, entre outros, os seguintes campos:

```json
{
  "startdate": "20260809",
  "enddate": "20260810",
  "urlbase": "https://www.bing.com/th?id=OHR.Exemplo_PT-BR123_UHD.jpg",
  "copyrighttext": "© Fotógrafo/Agência",
  "copyrightlink": "https://www.bing.com/search?...",
  "title": "Local fotografado",
  "description": "Descrição completa da imagem.",
  "headline": "Título editorial",
  "fullDateString": "9 ago. 2026",
  "sourceType": "BingImageOfTheDay"
}
```

Mapeamento para o modelo interno:

```text
id             = startdate + identificador extraído de urlbase
date           = startdate
availableUntil = enddate
imageUrl       = urlbase
title          = title
headline       = headline
description    = description
copyright      = copyrighttext
copyrightUrl   = copyrightlink
market         = mercado solicitado
```

### Endpoint de fallback

Se o endpoint principal falhar, utilizar:

```text
GET https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=8&mkt=pt-BR
```

Parâmetros:

- `format=js`: resposta em JSON.
- `idx=0`: inicia pela imagem atual.
- `n=8`: solicita até oito imagens.
- `mkt=pt-BR`: idioma e região.

Nesse endpoint, `url` e `urlbase` normalmente são caminhos relativos. A URL completa deve ser formada com `https://www.bing.com`.

Resposta simplificada:

```json
{
  "images": [
    {
      "startdate": "20260809",
      "url": "/th?id=OHR.Exemplo_1920x1080.jpg&rf=LaDigue_1920x1080.jpg&pid=hp",
      "urlbase": "/th?id=OHR.Exemplo",
      "copyright": "Local (© Fotógrafo)",
      "copyrightlink": "https://www.bing.com/search?...",
      "title": "Título",
      "wp": true
    }
  ]
}
```

Quando `wp` for `false`, a imagem não deve ser oferecida para download ou aplicação como wallpaper.

### Estratégia de resolução

No endpoint principal, `urlbase` já aponta para a versão UHD e deve ser tentado primeiro.

No endpoint de fallback, formar as URLs a partir de `urlbase`:

```text
{urlbase}_UHD.jpg
{urlbase}_1920x1080.jpg
```

Ordem recomendada:

1. UHD.
2. 1920 × 1080.
3. URL original retornada pela API.

O aplicativo deve validar o status HTTP e o `Content-Type` antes de salvar. Uma resposta `200` que não seja `image/jpeg`, `image/png` ou `image/webp` deve ser rejeitada.

## 3. Fluxo de atualização

1. Detectar o mercado configurado.
2. Consultar o endpoint principal.
3. Validar e converter a resposta para o modelo interno.
4. Em caso de erro, tentar novamente com backoff curto.
5. Se o erro continuar, consultar o endpoint de fallback.
6. Comparar a imagem atual com o cache por ID ou hash SHA-256.
7. Baixar a imagem somente quando ainda não estiver armazenada.
8. Validar o arquivo baixado.
9. Definir o wallpaper nos monitores selecionados.
10. Registrar localmente a data e o resultado da atualização.

Uma atualização automática deve ocorrer:

- ao iniciar, se ainda não houve atualização no dia;
- diariamente em horário configurável;
- ao retornar de suspensão, se a data tiver mudado;
- manualmente por meio do botão “Atualizar agora”.

Falhas de rede não devem remover o wallpaper atual. As tentativas automáticas devem usar intervalos crescentes, por exemplo: 5 minutos, 30 minutos e 2 horas.

## 4. Interface

### Painel da bandeja

O clique no ícone deve abrir um painel compacto contendo:

- pré-visualização da imagem;
- headline ou título;
- local/data;
- créditos;
- botões anterior e próximo;
- botão “Aplicar”;
- botão “Baixar”;
- botão de informações;
- acesso às configurações.

O clique no crédito ou em “Saiba mais” deve abrir `copyrightlink` no navegador padrão.

### Tela de configurações

Configurações mínimas:

- iniciar com o sistema;
- atualizar automaticamente;
- horário de atualização;
- região/idioma;
- aplicar em todos os monitores;
- comportamento por monitor;
- qualidade preferida;
- diretório para imagens salvas;
- limite do cache;
- tema claro, escuro ou automático;
- notificações;
- opção “Restaurar wallpaper anterior ao sair”.

### Galeria

A galeria deve exibir as oito imagens retornadas pela API. Cada cartão deve mostrar miniatura, data, título e indicação da imagem atualmente aplicada.

Uma imagem armazenada no cache deve continuar disponível mesmo se ela deixar de aparecer na resposta do Bing.

## 5. Arquitetura sugerida

```text
lib/
├── app/
│   ├── app.dart
│   ├── routes.dart
│   └── theme.dart
├── core/
│   ├── errors/
│   ├── http/
│   ├── logging/
│   └── storage/
├── features/
│   ├── wallpapers/
│   │   ├── data/
│   │   │   ├── bing_primary_api.dart
│   │   │   ├── bing_fallback_api.dart
│   │   │   ├── wallpaper_cache.dart
│   │   │   └── wallpaper_repository.dart
│   │   ├── domain/
│   │   │   ├── wallpaper.dart
│   │   │   └── wallpaper_service.dart
│   │   └── presentation/
│   ├── settings/
│   └── tray/
├── platform/
│   ├── wallpaper_platform.dart
│   ├── startup_platform.dart
│   └── monitor_platform.dart
└── main.dart
```

Responsabilidades:

- `BingPrimaryApi`: comunicação com `services.bingapis.com`.
- `BingFallbackApi`: comunicação com `HPImageArchive.aspx`.
- `WallpaperRepository`: fallback, normalização, cache e download.
- `WallpaperService`: regras de atualização e agendamento.
- `WallpaperPlatform`: aplicação do wallpaper por sistema operacional.
- `StartupPlatform`: inicialização automática.
- `MonitorPlatform`: descoberta e seleção de monitores.

O código de interface não deve executar comandos do sistema diretamente.

## 6. Integração por plataforma

### macOS

Usar implementação nativa em Swift por meio de Method Channels.

Recursos necessários:

- `NSWorkspace.shared.setDesktopImageURL` para definir a imagem.
- `NSScreen.screens` para enumerar monitores.
- `SMAppService` para iniciar no login.
- aplicativo do tipo menu bar, sem ícone permanente no Dock.

O aplicativo deve testar troca de Spaces, monitores desconectados e retorno de suspensão.

### Linux

O backend deve detectar `XDG_CURRENT_DESKTOP` e selecionar o adaptador adequado:

```text
GNOME/Ubuntu  gsettings
KDE Plasma    plasma-apply-wallpaperimage ou DBus
XFCE          xfconf-query
Cinnamon      gsettings
MATE          gsettings
Fallback      nitrogen, quando instalado
```

Wayland não oferece uma API universal para troca de wallpaper. O suporte deve ser declarado por ambiente gráfico, e não apenas como “suporte a Linux”.

No GNOME, o ícone de bandeja pode exigir a extensão AppIndicator.

## 7. Armazenamento local

Estrutura sugerida:

```text
app-data/
├── config.json
├── state.json
├── logs/
└── cache/
    ├── metadata.json
    ├── thumbnails/
    └── originals/
```

Informações persistidas:

- configurações do usuário;
- última atualização bem-sucedida;
- imagem atualmente aplicada;
- wallpaper anterior;
- metadados das imagens;
- hash dos arquivos;
- histórico de erros sem dados pessoais.

O cache deve possuir limite configurável e nunca apagar a imagem atualmente aplicada.

## 8. Rede, segurança e privacidade

- Aceitar somente HTTPS.
- Permitir downloads apenas de hosts aprovados:
  - `services.bingapis.com`;
  - `www.bing.com`;
  - subdomínios de imagem retornados pela API após validação explícita.
- Não executar conteúdo baixado.
- Limitar tamanho máximo de resposta e imagem.
- Usar timeouts de conexão e leitura.
- Nunca incluir tokens ou identificadores de máquina nas requisições.
- Não alterar página inicial, mecanismo de busca ou extensões do navegador.
- Não coletar telemetria por padrão.
- Ocultar dados pessoais dos logs.

## 9. Uso de marca e imagens

Este deve ser apresentado como aplicativo não oficial e sem associação com a Microsoft.

Regras:

- não utilizar o nome “Bing Wallpaper” como nome exclusivo do produto;
- não reutilizar o ícone oficial;
- manter os créditos fornecidos pela API;
- disponibilizar o link de copyright;
- usar as imagens somente como papel de parede;
- respeitar `wp=false`;
- não redistribuir um arquivo histórico próprio das imagens.

Os endpoints são públicos e acessíveis sem autenticação, mas não possuem contrato público de estabilidade. Alterações futuras devem ser esperadas.

## 10. Tratamento de erros

Erros devem ser convertidos em estados compreensíveis:

```text
Sem conexão
Serviço do Bing indisponível
Região não suportada
Imagem não disponível para wallpaper
Formato de imagem inválido
Sem permissão para salvar
Ambiente gráfico não suportado
Falha ao aplicar no monitor
```

O painel deve mostrar uma mensagem curta e oferecer “Tentar novamente”. Informações técnicas completas devem ficar apenas nos logs.

## 11. Testes

### Testes unitários

- parsing dos dois formatos de API;
- normalização de URLs;
- fallback de endpoint;
- seleção de mercado;
- deduplicação;
- política de cache;
- cálculo da próxima atualização.

### Testes de integração

- respostas válidas, vazias e malformadas;
- timeout e HTTP 429/500;
- URL UHD indisponível;
- funcionamento offline;
- monitores adicionados ou removidos;
- retorno de suspensão.

### Matriz manual

- macOS Intel e Apple Silicon;
- GNOME em X11 e Wayland;
- KDE Plasma em X11 e Wayland;
- monitor único e múltiplos monitores;
- temas claro e escuro;
- idiomas `pt-BR` e `en-US`.

Os testes automatizados não devem depender diretamente dos endpoints reais. Respostas JSON devem ser armazenadas como fixtures, mantendo apenas um teste opcional de conectividade.

## 12. Escopo do MVP

Primeira versão:

1. Flutter para interface.
2. Bandeja/menu bar.
3. Endpoint principal e fallback.
4. Galeria das últimas oito imagens.
5. Download e cache.
6. Aplicação manual e diária.
7. macOS, GNOME e KDE.
8. Inicialização automática.
9. Preferência de mercado.
10. Créditos e link de copyright.

Recursos posteriores:

- wallpaper diferente por monitor;
- escolha inteligente por proporção;
- suporte a XFCE, Cinnamon e MATE;
- atualizações automáticas do aplicativo;
- atalhos globais;
- importação de fontes adicionais;
- restauração avançada por Space no macOS.

## 13. Critérios de aceite do MVP

- A imagem do dia é exibida e aplicada sem chave de API.
- A interface continua utilizável quando o Bing está indisponível.
- O endpoint de fallback é acionado automaticamente.
- Nenhuma imagem é baixada novamente quando já existe no cache.
- A atualização diária funciona após reinicialização e suspensão.
- Os créditos são exibidos em todas as imagens.
- O aplicativo não altera configurações do navegador.
- O usuário pode desativar atualização automática e inicialização no login.
- O funcionamento está validado em macOS, GNOME e KDE.

