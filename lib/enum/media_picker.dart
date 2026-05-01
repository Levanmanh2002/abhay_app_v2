enum MediaType { all, image, video }

extension MediaTypes on MediaType {
  static List<MediaType> get allCases => [MediaType.all, MediaType.image, MediaType.video];

  static List<MediaType> get photoAndVideo => [MediaType.image, MediaType.video];

  static List<MediaType> get allAndPhoto => [MediaType.all, MediaType.image];

  static List<MediaType> get allAndVideo => [MediaType.all, MediaType.video];

  static List<MediaType> get photoOnly => [MediaType.image];

  static List<MediaType> get videoOnly => [MediaType.video];
}
