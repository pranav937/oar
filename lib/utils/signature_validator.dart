import 'dart:io';
import 'package:image/image.dart' as img;

class SignatureValidator {
  /// Validates if the image in [file] is likely a handwritten signature.
  /// It checks for ink density and contrast.
  static Future<bool> validateHandwritten(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return false;

      // Small images are likely not valid signatures
      if (image.width < 50 || image.height < 20) return false;

      int darkPixels = 0;
      
      // Sample pixels to save time (every 2nd pixel)
      int sampledWidth = 0;
      int sampledHeight = 0;
      
      for (int y = 0; y < image.height; y += 2) {
        sampledHeight++;
        for (int x = 0; x < image.width; x += 2) {
          if (y == 0) sampledWidth++;
          
          final pixel = image.getPixel(x, y);
          
          // Simple luminance calculation
          // In 'image' package v4, r, g, b are getters returning num
          final r = pixel.r;
          final g = pixel.g;
          final b = pixel.b;
          
          // Normalize to 0-255 if they are not already
          // (They might be 0.0-1.0 if it's a float image, but usually 0-255)
          double rNorm = r > 1.0 ? r.toDouble() : r.toDouble() * 255.0;
          double gNorm = g > 1.0 ? g.toDouble() : g.toDouble() * 255.0;
          double bNorm = b > 1.0 ? b.toDouble() : b.toDouble() * 255.0;
          
          final luminance = (0.299 * rNorm + 0.587 * gNorm + 0.114 * bNorm) / 255.0;

          if (luminance < 0.7) { // Threshold for "ink" (slightly lenient)
            darkPixels++;
          }
        }
      }

      double sampledTotal = sampledWidth.toDouble() * sampledHeight.toDouble();
      if (sampledTotal == 0) return false;
      
      double inkDensity = darkPixels / sampledTotal;
      
      // Heuristic for signatures:
      // 1. Must have some ink (at least 0.5% of pixels)
      // 2. Must not be too "busy" (more than 40% ink is likely a photo, not a signature)
      
      if (inkDensity < 0.005) return false; // Too blank
      if (inkDensity > 0.45) return false; // Too dark/busy
      
      return true;
    } catch (e) {
      return false;
    }
  }
}
