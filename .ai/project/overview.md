# Project Overview

## Identity

- **Project name**: `bing_4all`
- **Internal codename**: `bing_4all`
- **Repository purpose**: App desktop Flutter (Linux/macOS) para consultar imagens diárias do Bing, exibir metadados e aplicá-las como papel de parede
- **Primary team / squad**: Samir (projeto pessoal / open source)
- **Primary stakeholders**: mantenedor do repositório e contribuidores públicos
- **Primary users**: usuários de desktop Linux (GNOME/KDE) e macOS que querem o wallpaper diário do Bing sem o cliente oficial
- **Central problem**: não há cliente open source multiplataforma simples, gratuito e sem telemetria para usar as imagens diárias do Bing como wallpaper com bandeja/menu bar

## Business context

Aplicativo desktop não oficial para Linux e macOS. Consulta as imagens diárias do Bing, mostra título/descrição/créditos e permite defini-las como papel de parede. Opera principalmente pela bandeja (Linux) ou barra de menus (macOS). Sem anúncios, telemetria, conta obrigatória ou servidor próprio. Spec detalhada em `docs/SPEC.md`.

<!-- BEGIN: AUTO-SUMMARY -->
Resumo inferido automaticamente a partir do repositório:

- Variante detectada: `flutter-app`
- Diretórios principais: `.agents/`, `.ai/`, `.cursor/`, `.docs/`, `.github/`, `.kiro/`, `.vscode/`, `assets/`
- Arquivos principais: `.flutter-plugins-dependencies`, `.gitattributes`, `.gitignore`, `.metadata`, `AGENTS.md`, `analysis_options.yaml`, `bing_4all.iml`, `CHANGELOG.md`
<!-- END: AUTO-SUMMARY -->

## Core flows

- Atualizar wallpaper automaticamente (início do dia, horário configurável, retorno de suspensão, ou “Atualizar agora”)
- Navegar pelas oito imagens mais recentes no painel da bandeja/menu bar e aplicar/baixar
- Configurar mercado/idioma, monitores, cache, tema e inicialização com o sistema
- Fallback de API + cache local quando o Bing estiver indisponível

## Out of scope

- Cliente oficial Microsoft / cópia de marcas e ícones
- Anúncios, analytics oculto, conta, assinatura ou servidor próprio
- Redistribuição de arquivo histórico próprio das imagens do Bing
- MVP: XFCE/Cinnamon/MATE, wallpaper diferente por monitor, auto-update do app (pós-MVP)
