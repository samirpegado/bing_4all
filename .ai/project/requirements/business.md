# Business Requirements

## Goals

- Entregar cliente desktop open source, gratuito e sem telemetria para wallpapers diários do Bing
- Atualizar wallpaper automaticamente e permitir navegação/aplicação manual das 8 imagens recentes
- Exibir créditos/fotógrafo e link de copyright em todas as imagens
- Funcionar em macOS e Linux (GNOME e KDE no MVP), com cache local para uso temporário offline

## Success metrics

- Critérios de aceite do MVP (ver `docs/SPEC.md` §13): imagem do dia sem API key; UI utilizável offline/com fallback; cache evita re-download; atualização diária após reboot/suspensão; créditos sempre visíveis; sem alterar navegador; opt-out de auto-update e login startup
- Validação manual na matriz macOS (Intel/Apple Silicon) + GNOME/KDE (X11/Wayland)

## Constraints

- GPL-3.0-or-later recomendada; código e builds públicos
- Não usar “Bing Wallpaper” como nome exclusivo do produto; sem ícone/marca Microsoft
- Imagens do Bing não cobertas pela licença do código; uso apenas como wallpaper
- Sem anúncios, conta, servidor próprio ou recursos premium
