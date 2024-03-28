import 'dart:io';

import 'package:flutter/foundation.dart';

extension PlatformExtension on Platform {
  static get isDesktop =>
      !kIsWeb && Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  static get isMobile => !kIsWeb && Platform.isAndroid || Platform.isIOS;
}
