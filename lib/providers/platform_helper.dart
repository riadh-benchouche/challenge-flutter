import 'package:flutter/foundation.dart'; // Pour kIsWeb
// Import conditionnel
// dart:io uniquement pour Android/iOS/Desktop
export 'platform_io.dart' if (dart.library.html) 'platform_web.dart';
