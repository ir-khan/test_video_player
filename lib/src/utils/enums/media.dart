enum MediaType {
  image('Image'),
  video('Video');

  final String name;

  const MediaType(this.name);

  @override
  String toString() => name;
}
