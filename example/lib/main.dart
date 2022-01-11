import 'dart:io';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_editor_pro/image_editor_pro.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firexcode/firexcode.dart';
import 'package:screenshot/screenshot.dart';
import 'package:zoom_widget/zoom_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:extended_image/extended_image.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HomePage().xMaterialApp();
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScreenshotController screenshotController = ScreenshotController();
  final controllerDefaultImage = TextEditingController();
  File? _defaultImage;
  File? _image;
  var _height = 300.0;
  var _width = 300.0;
  Future<void> getimageditor() =>
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ImageEditorPro(
          appBarColor: Colors.black87,
          bottomBarColor: Colors.black87,
          pathSave: null,
          defaultImage: _defaultImage,
        );
      })).then((geteditimage) {
        if (geteditimage != null) {
          setState(() {
            _image = geteditimage;
          });
        }
      }).catchError((er) {
        print(er);
      });

  @override
  Widget build(BuildContext context) {
    print(_height);
    print(_width);
    return condition(
            condtion: _image == null,
            isTrue: XColumn(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch)
                .list([
                  Container(
                    padding: EdgeInsets.all(0.0),
                    child: Screenshot(
                        controller: screenshotController,
                        child: Container(
                          padding: EdgeInsets.all(0.0),
                          child: _defaultImage != null
                              ? ExtendedImage.file(
                                  _defaultImage!,
                                  fit: BoxFit.contain,

                                  //enableLoadState: false,
                                  mode: ExtendedImageMode.gesture,
                                  initGestureConfigHandler: (state) {
                                    return GestureConfig(
                                      minScale: 0.9,
                                      animationMinScale: 0.7,
                                      maxScale: 8.0,
                                      animationMaxScale: 8.5,
                                      speed: 1.0,
                                      inertialSpeed: 100.0,
                                      initialScale: 2.0,
                                      inPageView: false,
                                      initialAlignment: InitialAlignment.center,
                                    );
                                  },
                                )
                              : Center(
                                  child: Text('invalid image '),
                                ),
                        )),
                  ),
                  16.0.sizedHeight(),
                  'Set Default Image'.text().xRaisedButton(
                    onPressed: () async {
                      final imageGallery = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      if (imageGallery != null) {
                        _defaultImage = File(imageGallery.path);
                        final decodedImage = await decodeImageFromList(
                            _defaultImage!.readAsBytesSync());
                        _height = decodedImage.height.toDouble();
                        _width = decodedImage.width.toDouble();

                        setState(() =>
                            controllerDefaultImage.text = _defaultImage!.path);
                      }
                    },
                  ),
                  'Open Editor'.text().xRaisedButton(onPressed: () {
                    screenshotController
                        .capture(pixelRatio: 3.5 * 1.5)
                        .then((binaryIntList) async {
                      //print("Capture Done");

                      final paths = await getTemporaryDirectory();

                      final file = await File('${paths.path}/' +
                              DateTime.now().toString() +
                              '.jpg')
                          .create();
                      file.writeAsBytesSync(binaryIntList!);
                      print("taking new print out ");
                      _defaultImage = file;
                    });
                    if (_defaultImage == null) {
                      return;
                    } else {
                      getimageditor();
                    }
                  }),
                ])
                .xCenter()
                .xap(value: 16),
            isFalse:
                _image == null ? Container() : Image.file(_image!).toCenter())
        .xScaffold(
      floatingActionButton: Icons.add.xIcons().xFloationActiobButton(
          color: Colors.red,
          onTap: () async {
            print("hello world");
            if (_image != null && _image?.path != null) {
              print('saving in progress...');

              await GallerySaver.saveImage(_image!.path, albumName: "alayamCMS")
                  .then((bool? success) {
                print('image saved!');
              });
            }
          }),
    );
  }
}

Widget condition({bool? condtion, Widget? isTrue, Widget? isFalse}) {
  return condtion! ? isTrue! : isFalse!;
}
