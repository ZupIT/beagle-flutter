/*
 * Copyright 2020, 2022 ZUP IT SERVICOS EM TECNOLOGIA E INOVACAO SA
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:typed_data';
import 'package:beagle/beagle.dart';
import 'package:beagle_components/beagle_components.dart';
import 'package:flutter/widgets.dart';

/// Defines an image widget that renders local or remote resource depending on
/// the value passed to [path].
class BeagleImage extends StatefulWidget {
  const BeagleImage({
    Key? key,
    required this.path,
    this.mode,
    this.style,
  }) : super(key: key);

  /// Defines the location of the image resource.
  final ImagePath path;

  /// Defines how the declared image will fit the view.
  final ImageContentMode? mode;

  /// Property responsible to customize all the flex attributes and general style configuration
  final BeagleStyle? style;

  @override
  _BeagleImageState createState() => _BeagleImageState();
}

class _BeagleImageState extends State<BeagleImage> with BeagleConsumer {
  Future<Uint8List>? imageBytes;

  @override
  void initBeagleState() {
    if (!isLocalImage()) {
      downloadImage();
    }
  }

  @override
  Widget buildBeagleWidget(BuildContext context) {
    /* Suppose the immediate parent of this widget is a container 50x50. For some reason, Flutter can't figure out
    that the maximum height for the image is 50. It makes it so the content overflows. I have no idea why it happens,
    I checked and the constraints in the immediate parent says maxHeight 50, but if I measure it here, maxHeight is
    Infinity. Somehow, Flutter forgets what the constraints should be. As a workaround, we used the style to set the
    image size when its created. Unfortunately, this will not cover the cases where a percentage is used. */
    final width = (widget.style?.size?.width?.type == UnitType.REAL ?  widget.style?.size?.width?.value : null)
        ?.toDouble();
    final height = (widget.style?.size?.height?.type == UnitType.REAL ?  widget.style?.size?.height?.value : null)
        ?.toDouble();
    final theme = BeagleThemeProvider.of(context)?.theme;
    final image = isLocalImage()
        ? createImageFromAsset(widget.path as LocalImagePath, theme, width, height)
        : createImageFromNetwork(widget.path as RemoteImagePath, theme, width, height);
    return ClipRRect(
      borderRadius: StyleUtils.getBorderRadius(widget.style) ?? BorderRadius.zero,
      child: image,
    );
  }

  Future<void> downloadImage() async {
    try {
      final RemoteImagePath path = widget.path as RemoteImagePath;
      imageBytes = beagle.imageDownloader.downloadImage(beagle.urlBuilder.build(path.url));
    } catch (e) {
      beagle.logger.errorWithException(e.toString(), e as Exception);
    }
  }

  bool isLocalImage() => widget.path.runtimeType == LocalImagePath;

  Widget createImageFromAsset(LocalImagePath? path, BeagleTheme? theme, double? width, double? height) {
    if (isPlaceHolderValid(path, theme)) {
      return Image.asset(
        getAssetName(path!, theme) ?? '',
        width: width,
        height: height,
        fit: getBoxFit(widget.mode ?? ImageContentMode.CENTER),
      );
    }
    beagle.logger.error(
        'Invalid local image: "${path?.mobileId ?? 'null'}". Have you declared this id in your DesignSystem class?');
    return Container();
  }

  Widget createImageFromNetwork(RemoteImagePath path, BeagleTheme? theme, double? width, double? height) {
    return FutureBuilder(
      future: imageBytes,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return createPlaceHolderWidget(path, theme, width, height);
        }
        return createImageFromMemory(snapshot.data as Uint8List, width, height);
      },
    );
  }

  Widget createPlaceHolderWidget(RemoteImagePath path, BeagleTheme? theme, double? width, double? height) {
    if (isPlaceHolderValid(path.placeholder, theme)) {
      return createImageFromAsset(path.placeholder, theme, width, height);
    }
    return Container();
  }

  Image createImageFromMemory(Uint8List bytes, double? width, double? height) {
    return Image.memory(
      bytes,
      width: width,
      height: height,
      fit: getBoxFit(widget.mode ?? ImageContentMode.CENTER),
    );
  }

  bool isImageDownloaded() => imageBytes != null;

  String? getAssetName(LocalImagePath imagePath, BeagleTheme? theme) {
    return theme?.image(imagePath.mobileId);
  }

  bool isPlaceHolderValid(LocalImagePath? path, BeagleTheme? theme) {
    if (path == null) return false;

    final assetName = getAssetName(path, theme);
    return assetName != null && assetName.isNotEmpty;
  }

  BoxFit getBoxFit(ImageContentMode mode) {
    if (mode == ImageContentMode.CENTER) {
      return BoxFit.none;
    } else if (mode == ImageContentMode.CENTER_CROP) {
      return BoxFit.cover;
    } else if (mode == ImageContentMode.FIT_CENTER) {
      return BoxFit.contain;
    } else if (mode == ImageContentMode.FIT_XY) {
      return BoxFit.fill;
    }
    return BoxFit.contain;
  }
}

abstract class ImagePath {
  ImagePath._();

  factory ImagePath.local(String mobileId) = LocalImagePath;

  factory ImagePath.remote(String url, LocalImagePath placeholder) =
      RemoteImagePath;

  factory ImagePath.fromJson(Map<String, dynamic> json) {
    if (json[_jsonBeagleImagePathKey] == 'local') {
      return LocalImagePath.fromJson(json);
    }
    return RemoteImagePath.fromJson(json);
  }

  static const _jsonBeagleImagePathKey = '_beagleImagePath_';
}

class LocalImagePath extends ImagePath {
  LocalImagePath(this.mobileId) : super._();

  LocalImagePath.fromJson(Map<String, dynamic> json)
      : mobileId = json[_jsonMobileIdKey],
        super._();

  final String mobileId;

  static const _jsonMobileIdKey = 'mobileId';
}

class RemoteImagePath extends ImagePath {
  RemoteImagePath(this.url, this.placeholder) : super._();

  RemoteImagePath.fromJson(Map<String, dynamic> json)
      : url = json[_jsonUrlKey],
        placeholder = json[_jsonPlaceholderKey] != null
            ? LocalImagePath.fromJson(json[_jsonPlaceholderKey])
            : null,
        super._();

  final String url;
  final LocalImagePath? placeholder;

  static const _jsonUrlKey = 'url';
  static const _jsonPlaceholderKey = 'placeholder';
}

enum ImageContentMode {
  /// Compute a scale that will maintain the original aspect ratio,
  /// but will also ensure that it fits entirely inside the destination view.
  /// At least one axis (X or Y) will fit exactly. The result is centered inside the destination.
  FIT_XY,

  /// Compute a scale that will maintain the original aspect ratio,
  /// but will also ensure that it fits entirely inside the destination view.
  /// At least one axis (X or Y) will fit exactly.
  /// The result is centered inside the destination.
  FIT_CENTER,

  /// Scale the image uniformly (maintain the image's aspect ratio) so that both dimensions
  /// (width and height) of the image will be equal to or larger than
  /// the corresponding dimension of the view (minus padding).
  CENTER_CROP,

  /// Center the image in the view but perform no scaling.
  CENTER
}
