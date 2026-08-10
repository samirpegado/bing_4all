# Integrations

## External services

- **Bing Wallpaper API (principal)**: `GET https://services.bingapis.com/ge-apps/api/v2/bwc/hpimages?mkt=<market>` — sem autenticação; até 8 imagens com metadados
- **Bing HPImageArchive (fallback)**: `GET https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=8&mkt=<market>` — URLs relativas resolvidas com `https://www.bing.com`
- **Hosts de download permitidos**: `services.bingapis.com`, `www.bing.com`, e hosts de imagem retornados pela API após validação explícita

## Internal services

- Nenhum servidor próprio. Persistência apenas local (`config.json`, `state.json`, cache de imagens/metadados)

## Contracts and interfaces

- Modelo interno de wallpaper: id, date, availableUntil, imageUrl, title, headline, description, copyright, copyrightUrl, market
- Respeitar `wp=false` no fallback (não oferecer download/aplicação)
- Preferir UHD; validar HTTP status e `Content-Type` (`image/jpeg|png|webp`) antes de salvar
- Plataforma: `WallpaperPlatform`, `StartupPlatform`, `MonitorPlatform`
