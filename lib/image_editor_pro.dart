import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_editor_pro/modules/sliders.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_editor_pro/modules/all_emojies.dart';
import 'package:image_editor_pro/modules/bottombar_container.dart';
import 'package:image_editor_pro/modules/emoji.dart';
import 'package:image_editor_pro/modules/text.dart';
import 'package:image_editor_pro/modules/textview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:signature/signature.dart';
import 'package:firexcode/firexcode.dart';
import 'dart:math' as math;

import 'modules/color_filter_generator.dart';
import 'modules/colors_picker.dart'; // import this

TextEditingController heightcontroler = TextEditingController();
TextEditingController widthcontroler = TextEditingController();
var width = 300;
var height = 300;
List<Map> widgetJson = [];
//List fontsize = [];
//List<Color> colorList = [];
var howmuchwidgetis = 0;
//List multiwidget = [];
Color currentcolors = Colors.white;
var opicity = 0.0;
SignatureController _controller = SignatureController(penStrokeWidth: 5, penColor: Colors.green);

class ImageEditorPro extends StatefulWidget {
   Color? appBarColor;
   Color? bottomBarColor;
   Directory? pathSave;
   File? defaultImage;
   double? pixelRatio;

  ImageEditorPro({
    this.appBarColor,
    this.bottomBarColor,
    this.pathSave,
    this.defaultImage,
    this.pixelRatio,
  });

  @override
  _ImageEditorProState createState() => _ImageEditorProState();
}

var slider = 0.0;

class _ImageEditorProState extends State<ImageEditorPro> {
  // create some values
  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);

// ValueChanged<Color> callback
  void changeColor(Color color) {
    setState(() => pickerColor = color);
    var points = _controller.points;
    _controller = SignatureController(penStrokeWidth: 5, penColor: color, points: points);
  }

  List<Offset> offsets = [];
  Offset offset1 = Offset.zero;
  Offset offset2 = Offset.zero;
  var scaf = GlobalKey<ScaffoldState>();
  var openbottomsheet = false;
  List<Offset> _points = <Offset>[];
  List type = [];
  List aligment = [];

  final GlobalKey container = GlobalKey();
  final GlobalKey globalKey = GlobalKey();
  File? _image;
  ScreenshotController screenshotController = ScreenshotController();
  Timer? timeprediction;

  void timers() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (widget.defaultImage != null && widget.defaultImage!.existsSync()) {
        loadImage(widget.defaultImage);
      }
    });
    Timer.periodic(Duration(milliseconds: 10), (tim) {
      setState(() {});
      timeprediction = tim;
    });
  }

  @override
  void dispose() {
    timeprediction!.cancel();
    _controller.clear();
    widgetJson.clear();
    heightcontroler.clear();
    widthcontroler.clear();
    super.dispose();
  }

  @override
  void initState() {
    timers();
    _controller.clear();
    type.clear();
    //  fontsize.clear();
    offsets.clear();
    //  multiwidget.clear();
    howmuchwidgetis = 0;

    super.initState();
  }

  double flipValue = 0;
  int rotateValue = 0;
  double blurValue = 0;
  double opacityValue = 0;
  Color colorValue = Colors.transparent;

  double hueValue = 0;
  double brightnessValue = 0;
  double saturationValue = 0;

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: screenshotController,
      child: RotatedBox(
        quarterTurns: rotateValue,
        child: imageFilterLatest(
          hue: hueValue,
          brightness: brightnessValue,
          saturation: saturationValue,
          child: RepaintBoundary(
              key: globalKey,
              child: xStack.list(
                [
                  _image != null
                      ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(flipValue),
                          child: ClipRect(
                            // <-- clips to the 200x200 [Container] below

                            child: _image!.path.decorationIFToFitHeight().xContainer(
                                padding: EdgeInsets.zero,
                                // alignment: Alignment.center,
                                width: width.toDouble(),
                                height: height.toDouble(),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: blurValue,
                                    sigmaY: blurValue,
                                  ),
                                  child: Container(
                                    color: colorValue.withOpacity(opacityValue),
                                  ),
                                )),
                          ),
                        )

                      //  BackdropFilter(
                      //     filter: ImageFilter.blur(
                      //         sigmaX: 10.0, sigmaY: 10.0, tileMode: TileMode.clamp),
                      //     child: Image.file(
                      //       _image,
                      //       height: height.toDouble(),
                      //       width: width.toDouble(),
                      //       fit: BoxFit.cover,
                      //     ),
                      //   )
                      : Container(),
                  Signat().xGesture(
                    onPanUpdate: (DragUpdateDetails details) {
                      setState(() {
                        RenderBox? object = context.findRenderObject() as RenderBox?;
                        var _localPosition = object!.globalToLocal(details.globalPosition);
                        _points = List.from(_points)..add(_localPosition);
                      });
                    },
                    onPanEnd: (DragEndDetails details) {
                      _points.add(null!);
                    },
                  ).xContainer(padding: EdgeInsets.all(0.0)),
                  xStack.list(
                    widgetJson.asMap().entries.map((f) {
                      return type[f.key] == 1
                          ? EmojiView(
                              left: offsets[f.key].dx,
                              top: offsets[f.key].dy,
                              ontap: () {
                                scaf.currentState!.showBottomSheet((context) {
                                  return Sliders(
                                    index: f.key,
                                    mapValue: f.value,
                                  );
                                });
                              },
                              onpanupdate: (details) {
                                setState(() {
                                  offsets[f.key] =
                                      Offset(offsets[f.key].dx + details.delta.dx, offsets[f.key].dy + details.delta.dy);
                                });
                              },
                              mapJson: f.value,
                            )
                          : type[f.key] == 2
                              ? TextView(
                                  left: offsets[f.key].dx,
                                  top: offsets[f.key].dy,
                                  ontap: () {
                                    showModalBottomSheet(
                                        shape: BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10))
                                            .xShapeBorder(),
                                        context: context,
                                        builder: (context) {
                                          return Sliders(
                                            index: f.key,
                                            mapValue: f.value,
                                          );
                                        });
                                  },
                                  onpanupdate: (details) {
                                    setState(() {
                                      offsets[f.key] =
                                          Offset(offsets[f.key].dx + details.delta.dx, offsets[f.key].dy + details.delta.dy);
                                    });
                                  },
                                  mapJson: f.value,
                                )
                              : Container();
                    }).toList(),
                  )
                ],
              )).toContainer(
            margin: EdgeInsets.all(20),
            color: Colors.white,
            width: width.toDouble(),
            height: height.toDouble(),
          ),
        ),
      ),
    ).xCenter().xScaffold(
        backgroundColor: Colors.grey.shade400,
        key: scaf,
        appBar: AppBar(
          actions: <Widget>[
            Icon(Icons.clear).xIconButton(onPressed: () {
              _controller.points.clear();
              setState(() {});
            }),

            'Save'.text().xFlatButton(
                primary: Colors.white,
                onPressed: () {
                  screenshotController.capture(pixelRatio: widget.pixelRatio ?? 1.5).then((binaryIntList) async {
                    //print("Capture Done");

                    final paths = widget.pathSave ?? await getTemporaryDirectory();

                    final file = await File('${paths.path}/' + DateTime.now().toString() + '.jpg').create();
                    file.writeAsBytesSync(binaryIntList!);
                    Navigator.pop(context, file);
                  }).catchError((onError) {
                    print(onError);
                  });
                })
          ],
          brightness: Brightness.dark,
          // backgroundColor: Colors.red,
          backgroundColor: widget.appBarColor ?? Colors.black87,
        ),
        bottomNavigationBar: openbottomsheet
            ? Container()
            : XListView(
                scrollDirection: Axis.horizontal,
              ).list(
                <Widget>[
                  BottomBarContainer(
                    colors: widget.bottomBarColor!,
                    icons: FontAwesomeIcons.paintBrush,
                    ontap: () {
                      // raise the [showDialog] widget
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: 'Pick a color!'.text(),
                            content: ColorPicker(
                              pickerColor: pickerColor,
                              onColorChanged: changeColor,
                              showLabel: true,
                              pickerAreaHeightPercent: 0.8,
                            ).xSingleChildScroolView(),
                            actions: <Widget>[
                              'Got it'.text().xFlatButton(
                                onPressed: () {
                                  setState(() => currentColor = pickerColor);
                                  back(context);
                                },
                              )
                            ],
                          );
                        },
                      );
                    },
                    title: 'Brush',
                  ),
                  BottomBarContainer(
                    colors: widget.bottomBarColor!,
                    icons: Icons.text_fields,
                    ontap: () async {
                      var value = await Navigator.push(context, MaterialPageRoute(builder: (context) => TextEditorImage()));
                      if (value['name'] == null) {
                        print('true');
                      } else {
                        type.add(2);
                        widgetJson.add(value);
                        // fontsize.add(20);
                        offsets.add(Offset.zero);
                        //  colorList.add(value['color']);
                        //    multiwidget.add(value['name']);
                        howmuchwidgetis++;
                      }
                    },
                    title: 'Text',
                  ),
                  _image != null ? BottomBarContainer(
                    colors: widget.bottomBarColor!,
                    icons: Icons.flip,
                    ontap: () {
                      setState(() {
                        flipValue = flipValue == 0 ? math.pi : 0;
                      });
                    },
                    title: 'Flip',
                  ) : Container(),
                  BottomBarContainer(
                    colors: widget.bottomBarColor!,
                    icons: Icons.rotate_left,
                    ontap: () {
                      setState(() {
                        rotateValue--;
                      });
                    },
                    title: 'Rotate left',
                  ),
                  BottomBarContainer(
                    colors: widget.bottomBarColor!,
                    icons: Icons.rotate_right,
                    ontap: () {
                      setState(() {
                        rotateValue++;
                      });
                    },
                    title: 'Rotate right',
                  ),

                  BottomBarContainer(
                    colors: widget.bottomBarColor!,
                    icons: FontAwesomeIcons.eraser,
                    ontap: () {
                      _controller.clear();
                      //  type.clear();
                      // // fontsize.clear();
                      //  offsets.clear();
                      // // multiwidget.clear();
                      howmuchwidgetis = 0;
                    },
                    title: 'Eraser',
                  ),

                  // BottomBarContainer(
                  //   colors: widget.bottomBarColor!,
                  //   icons: FontAwesomeIcons.smile,
                  //   ontap: () {
                  //     var getemojis = showModalBottomSheet(
                  //         context: context,
                  //         builder: (BuildContext context) {
                  //           return Emojies();
                  //         });
                  //     getemojis.then((value) {
                  //       if (value['name'] != null) {
                  //         type.add(1);
                  //         widgetJson.add(value);
                  //         //    fontsize.add(20);
                  //         offsets.add(Offset.zero);
                  //         //  multiwidget.add(value);
                  //         howmuchwidgetis++;
                  //       }
                  //     });
                  //   },
                  //   title: 'Emoji',
                  // ),
                ],
              ).xContainer(
                padding: EdgeInsets.all(0.0),
                blurRadius: 10.9,
                shadowColor: widget.bottomBarColor,
                height: 70,
              ));
  }

  final picker = ImagePicker();

  Future<void> loadImage(File? imageFile) async {
    final decodedImage = await decodeImageFromList(imageFile!.readAsBytesSync());
    setState(() {
      height = decodedImage.height;
      width = decodedImage.width;
      _image = imageFile;
      _controller.clear();
    });
  }

  void _closeModal(void value) {
    openbottomsheet = false;
    setState(() {});
  }
}

class Signat extends StatefulWidget {
  @override
  _SignatState createState() => _SignatState();
}

class _SignatState extends State<Signat> {
  @override
  void initState() {
    super.initState();
    _controller.addListener(() => print('Value changed'));
  }

  @override
  Widget build(BuildContext context) {
    return xListView.list(
      [
        Signature(
            controller: _controller,
            height: height.toDouble(),
            width: width.toDouble(),
            backgroundColor: Colors.transparent),
      ],
    );
  }
}

Widget imageFilterLatest({brightness, saturation, hue, child}) {
  return ColorFiltered(
      colorFilter: ColorFilter.matrix(ColorFilterGenerator.brightnessAdjustMatrix(
        value: brightness,
      )),
      child: ColorFiltered(
          colorFilter: ColorFilter.matrix(ColorFilterGenerator.saturationAdjustMatrix(
            value: saturation,
          )),
          child: ColorFiltered(
            colorFilter: ColorFilter.matrix(ColorFilterGenerator.hueAdjustMatrix(
              value: hue,
            )),
            child: child,
          )));
}
