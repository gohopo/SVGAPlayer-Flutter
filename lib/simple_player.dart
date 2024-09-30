part of svgaplayer_flutter_player;

class SVGASimpleImage extends StatefulWidget {
  final String? resUrl;
  final String? assetsName;
  final File? file;

  const SVGASimpleImage({Key? key, this.resUrl, this.assetsName, this.file})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SVGASimpleImageState();
  }
}

class SVGASimpleImageState extends State<SVGASimpleImage>
    with SingleTickerProviderStateMixin {
  SVGAAnimationController? animationController;

  @override
  void initState() {
    super.initState();
    animationController = SVGAAnimationController(vsync: this);
    _tryDecodeSvga();
  }

  @override
  void didUpdateWidget(covariant SVGASimpleImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resUrl != widget.resUrl || oldWidget.assetsName != widget.assetsName) {
      _tryDecodeSvga();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (animationController == null) {
      return Container();
    }
    return SVGAImage(animationController!);
  }

  @override
  void dispose() {
    animationController?.dispose();
    animationController = null;
    super.dispose();
  }

  void _tryDecodeSvga() {
    Future<MovieEntity> decode;
    if (widget.resUrl != null) {
      decode = SVGAParser.shared.decodeFromURL(widget.resUrl!);
    } else if (widget.assetsName != null) {
      decode = SVGAParser.shared.decodeFromAssets(widget.assetsName!);
    } else if (widget.file != null) {
      decode = widget.file!.readAsBytes().then((bytes) {
        return SVGAParser.shared.decodeFromBuffer(bytes);
      });
    } else {
      return;
    }
    decode.then((videoItem) {
      if (mounted && animationController != null) {
        animationController!
          ..videoItem = videoItem
          ..repeat();
      } else {
        videoItem.dispose();
      }
    }).catchError((e, stack) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: e,
        stack: stack,
        library: 'svga library',
        informationCollector: () => [
          if (widget.resUrl != null) StringProperty('resUrl', widget.resUrl),
          if (widget.assetsName != null)
            StringProperty('assetsName', widget.assetsName),
        ],
      ));
    });
  }
}
