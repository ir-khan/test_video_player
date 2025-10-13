enum AppRoutes {
  selectVideos('select-videos', '/select-videos');

  final String name;
  final String path;

  const AppRoutes(this.name, this.path);

  static const initialLocation = AppRoutes.selectVideos;
}
