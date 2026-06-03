class ImageUrlResolver {
  const ImageUrlResolver({
    required this.imageBaseUrl,
    required this.actorImageBaseUrl,
    required this.noImageUrl,
  });

  final String imageBaseUrl;
  final String actorImageBaseUrl;
  final String noImageUrl;

  /// Poster/backdrop URL, falling back to [noImageUrl] when [path] is empty.
  String movieImage(String path) =>
      path.isNotEmpty ? '$imageBaseUrl$path' : noImageUrl;

  /// Actor profile URL, or `null` when the API provides no [path].
  String? actorImage(String? path) =>
      path != null ? '$actorImageBaseUrl$path' : null;
}
