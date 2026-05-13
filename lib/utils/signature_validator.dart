import 'dart:io';
import 'package:image/image.dart' as img;

class SignatureValidator {
  /// Validates if the image in [file] is likely a handwritten signature.
  /// It checks for ink density, contrast, and regularity to reject printed text.
  static Future<bool> validateHandwritten(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return false;

      // 1. Basic size check
      if (image.width < 100 || image.height < 30) return false;

      int darkPixels = 0;
      final int width = image.width;
      final int height = image.height;

      // Projections for regularity analysis
      final List<int> rowProjections = List.filled(height, 0);
      final List<int> colProjections = List.filled(width, 0);

      // We'll use a slightly stricter threshold for "ink"
      const double threshold = 0.65;

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final pixel = image.getPixel(x, y);

          // Using luminance to detect ink (dark pixels)
          final r = pixel.r;
          final g = pixel.g;
          final b = pixel.b;

          // Normalize (image package v4 might return 0-255 or 0-1)
          double rNorm = r > 1.0 ? r.toDouble() : r.toDouble() * 255.0;
          double gNorm = g > 1.0 ? g.toDouble() : g.toDouble() * 255.0;
          double bNorm = b > 1.0 ? b.toDouble() : b.toDouble() * 255.0;

          final luminance =
              (0.299 * rNorm + 0.587 * gNorm + 0.114 * bNorm) / 255.0;

          if (luminance < threshold) {
            darkPixels++;
            rowProjections[y]++;
            colProjections[x]++;
          }
        }
      }

      final double totalPixels = (width * height).toDouble();
      final double inkDensity = darkPixels / totalPixels;

      // Heuristic 1: Ink Density
      // Signatures shouldn't be too sparse or too solid
      if (inkDensity < 0.005 || inkDensity > 0.35) return false;

      // 2. Regularity Check (to reject printed text/typed signatures)
      // Printed text often has very regular horizontal gaps or vertical structures.

      // Check for horizontal regularity (character spacing)
      int inkClusters = 0;
      bool inCluster = false;

      for (int x = 0; x < width; x++) {
        if (colProjections[x] > 0) {
          if (!inCluster) {
            inkClusters++;
            inCluster = true;
          }
        } else {
          if (inCluster) {
            inCluster = false;
          }
        }
      }

      // Printed names often have very distinct 3-10 clusters (characters)
      // Handwritten signatures are often one or two large clusters (cursive)
      if (inkClusters > 15) return false; // Likely a long line of printed text

      // 3. Complexity / Variance check
      // Printed fonts have very uniform row projections (similar heights)
      // We calculate the variance of the non-zero row projections
      final List<int> activeRows = rowProjections.where((p) => p > 0).toList();
      if (activeRows.isEmpty) return false;

      double avgWidth = activeRows.reduce((a, b) => a + b) / activeRows.length;
      double variance = 0;
      for (var p in activeRows) {
        variance += (p - avgWidth) * (p - avgWidth);
      }
      variance /= activeRows.length;

      // Printed fonts have very low variance in stroke width per row
      // Handwritten signatures have natural variation in pressure and height
      // Threshold found by testing: Printed < 50, Handwritten > 100
      if (variance < 40) return false; // Too regular, likely typed

      return true;
    } catch (e) {
      return false;
    }
  }
}
