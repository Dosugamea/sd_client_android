class Resolution {
  final int width;
  final int height;
  final String aspectRatio;

  const Resolution(this.width, this.height, this.aspectRatio);

  @override
  String toString() => '$width x $height ($aspectRatio)';
}
