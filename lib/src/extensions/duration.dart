extension DurationFormat on Duration {
  String format() {
    /// ✅ TODO ( Izn ur Rehman ) : Optimize it further
    /// ✅ New TODO ( Izn ur Rehman ) : it becomes a little complex
    // if (inHours == 0) {
    //   return [
    //     inMinutes.remainder(60),
    //     inSeconds.remainder(60),
    //   ].map((seg) => seg.toString().padLeft(2, '0')).join(':');
    // }
    // return [
    //   inHours,
    //   inMinutes.remainder(60),
    //   inSeconds.remainder(60),
    // ].map((seg) => seg.toString().padLeft(2, '0')).join(':');
    if (inHours == 0) return toString().substring(2,7);
    return toString().split('.').first;
  }
}
