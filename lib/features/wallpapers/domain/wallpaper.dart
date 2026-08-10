class Wallpaper {
  const Wallpaper({
    required this.id,
    required this.date,
    required this.imageUrl,
    required this.title,
    required this.copyright,
    required this.market,
    this.availableUntil,
    this.headline = '',
    this.description = '',
    this.copyrightUrl = '',
    this.fullDateString = '',
    this.availableForWallpaper = true,
  });

  final String id;
  final String date;
  final String? availableUntil;
  final String imageUrl;
  final String title;
  final String headline;
  final String description;
  final String copyright;
  final String copyrightUrl;
  final String market;
  final String fullDateString;
  final bool availableForWallpaper;

  String get displayTitle =>
      headline.trim().isNotEmpty ? headline : title;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'availableUntil': availableUntil,
        'imageUrl': imageUrl,
        'title': title,
        'headline': headline,
        'description': description,
        'copyright': copyright,
        'copyrightUrl': copyrightUrl,
        'market': market,
        'fullDateString': fullDateString,
        'availableForWallpaper': availableForWallpaper,
      };

  factory Wallpaper.fromJson(Map<String, dynamic> json) {
    return Wallpaper(
      id: json['id'] as String,
      date: json['date'] as String,
      availableUntil: json['availableUntil'] as String?,
      imageUrl: json['imageUrl'] as String,
      title: json['title'] as String? ?? '',
      headline: json['headline'] as String? ?? '',
      description: json['description'] as String? ?? '',
      copyright: json['copyright'] as String? ?? '',
      copyrightUrl: json['copyrightUrl'] as String? ?? '',
      market: json['market'] as String? ?? 'en-US',
      fullDateString: json['fullDateString'] as String? ?? '',
      availableForWallpaper: json['availableForWallpaper'] as bool? ?? true,
    );
  }

  Wallpaper copyWith({
    String? imageUrl,
    bool? availableForWallpaper,
  }) {
    return Wallpaper(
      id: id,
      date: date,
      availableUntil: availableUntil,
      imageUrl: imageUrl ?? this.imageUrl,
      title: title,
      headline: headline,
      description: description,
      copyright: copyright,
      copyrightUrl: copyrightUrl,
      market: market,
      fullDateString: fullDateString,
      availableForWallpaper:
          availableForWallpaper ?? this.availableForWallpaper,
    );
  }
}
