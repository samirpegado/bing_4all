sealed class AppException implements Exception {
  const AppException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

final class NetworkException extends AppException {
  const NetworkException({
    String message = 'Sem conexão',
    Object? cause,
  }) : super(message, cause: cause);
}

final class BingUnavailableException extends AppException {
  const BingUnavailableException({
    String message = 'Serviço do Bing indisponível',
    Object? cause,
  }) : super(message, cause: cause);
}

final class UnsupportedMarketException extends AppException {
  const UnsupportedMarketException({
    String message = 'Região não suportada',
    Object? cause,
  }) : super(message, cause: cause);
}

final class WallpaperUnavailableException extends AppException {
  const WallpaperUnavailableException({
    String message = 'Imagem não disponível para wallpaper',
    Object? cause,
  }) : super(message, cause: cause);
}

final class InvalidImageException extends AppException {
  const InvalidImageException({
    String message = 'Formato de imagem inválido',
    Object? cause,
  }) : super(message, cause: cause);
}

final class StoragePermissionException extends AppException {
  const StoragePermissionException({
    String message = 'Sem permissão para salvar',
    Object? cause,
  }) : super(message, cause: cause);
}

final class UnsupportedDesktopException extends AppException {
  const UnsupportedDesktopException({
    String message = 'Ambiente gráfico não suportado',
    Object? cause,
  }) : super(message, cause: cause);
}

final class ApplyWallpaperException extends AppException {
  const ApplyWallpaperException({
    String message = 'Falha ao aplicar no monitor',
    Object? cause,
  }) : super(message, cause: cause);
}
