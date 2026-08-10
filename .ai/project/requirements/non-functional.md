# Non-Functional Requirements

## Performance

- Operar em segundo plano com baixo consumo de recursos
- Painel da bandeja/menu bar pequeno e rápido
- Evitar re-download quando a imagem já está no cache (ID/hash SHA-256)

## Security

- Somente HTTPS; hosts de download em allowlist
- Timeouts e limites de tamanho de resposta/imagem
- Não executar conteúdo baixado; não enviar tokens/IDs de máquina
- Não alterar homepage, busca ou extensões do navegador
- Sem telemetria por padrão; ocultar dados pessoais em logs

## Reliability

- Falha de rede não remove o wallpaper atual
- Retry com backoff (ex.: 5 min, 30 min, 2 h)
- Fallback de API automático; cache permite uso temporário offline
- Cache nunca apaga a imagem atualmente aplicada

## Accessibility

- Tema claro, escuro ou automático
- Mensagens de erro curtas e acionáveis no painel (“Tentar novamente”)
- Metas de a11y mais formais ainda não especificadas numericamente

## Observability

- Logs locais (sem dados pessoais)
- Histórico de erros locais
- Sem analytics/telemetria remotos por padrão
