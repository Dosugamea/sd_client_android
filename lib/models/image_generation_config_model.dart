import 'package:sd_client_android/models/resolution_model.dart';

class ImageGenerationSettings {
  static const resolutions = [
    Resolution(1024, 1024, "1:1 SDXL"),
    Resolution(768, 1344, "9:16 SDXL"),
    Resolution(832, 1216, "2:3 SDXL"),
    Resolution(896, 1152, "3:4 SDXL"),
    Resolution(1344, 768, "16:9 SDXL"),
    Resolution(1216, 832, "3:2 SDXL"),
    Resolution(1152, 896, "4:3 SDXL"),
    Resolution(768, 768, "1:1 SD1.5"),
    Resolution(512, 768, "2:3 SD1.5"),
    Resolution(576, 768, "3:4 SD1.5"),
    Resolution(512, 912, "9:16 SD1.5"),
    Resolution(512, 512, "1:1 SD1.5"),
    Resolution(768, 512, "3:2 SD1.5"),
    Resolution(768, 576, "4:3 SD1.5"),
    Resolution(912, 512, "9:16 SD1.5"),
  ];

  static const defaultSteps = 25;
  static const minSteps = 1;
  static const maxSteps = 50;
}
