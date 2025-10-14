extension DurationFormat on Duration {
  String format() {
    /// TODO ( Izn ur Rehman ) : Optimize it further
    if (inHours == 0) {
      return [
        inMinutes.remainder(60),
        inSeconds.remainder(60),
      ].map((seg) => seg.toString().padLeft(2, '0')).join(':');
    }
    return [
      inHours,
      inMinutes.remainder(60),
      inSeconds.remainder(60),
    ].map((seg) => seg.toString().padLeft(2, '0')).join(':');
  }
}
