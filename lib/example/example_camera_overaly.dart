import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_camera_overlay/flutter_camera_overlay.dart';
import 'package:flutter_camera_overlay/model.dart';
// import 'package:ocr/pages/navigations/camera_page.dart';
// import '../pages/navigations/camera_page.dart';
import '../pages/api/upload_image.dart';
import '../pages/home_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_native_image/flutter_native_image.dart';


main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ExampleCameraOverlay(),
  );
}

class ExampleCameraOverlay extends StatefulWidget {

  static const routeName = '/graph-page';

  const ExampleCameraOverlay({Key? key}) : super(key: key);

  @override
  _ExampleCameraOverlayState createState() => _ExampleCameraOverlayState();
}

class _ExampleCameraOverlayState extends State<ExampleCameraOverlay> {
  OverlayFormat format = OverlayFormat.cardID1;
  int tab = 0;

  // File? _image;
  // final picker = ImagePicker();
  //
  // // 비동기 처리를 통해 카메라와 갤러리에서 이미지를 가져온다.
  // Future getImage(ImageSource imageSource) async {
  //   print("getImage");
  //   final image = await picker.pickImage(source: imageSource);
  //
  //   setState(() {
  //     _image = File(image!.path); // 가져온 이미지를 _image에 저장
  //   });
  // }

  cropImage(String cameraurl) async {
    File? croppedfile = await ImageCropper().cropImage(
        sourcePath: cameraurl,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Image Cropper',
            toolbarColor: Colors.deepPurpleAccent,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        )
    );

    if (croppedfile != null) {
      // imagefile = croppedfile;
      setState(() { });
    }else{
      print("Image is not cropped.");
    }
    return croppedfile;
  }
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context);
    var size = media.size;
    double width = media.orientation == Orientation.portrait
        ? size.shortestSide * .9
        : size.longestSide * .5;

    double height = width * 1.414;

    return MaterialApp(
        home: Scaffold(
          // bottomNavigationBar: BottomNavigationBar(
          //   currentIndex: tab,
          //   onTap: (value) {
          //     setState(() {
          //       tab = value;
          //     });
          //     switch (value) {
          //       case (0):
          //         setState(() {
          //           format = OverlayFormat.cardID1;
          //         });
          //         break;
          //       // case (1):
          //       //   setState(() {
          //       //     format = OverlayFormat.cardID3;
          //       //   });
          //       //   break;
          //       // case (2):
          //       //   setState(() {
          //       //     format = OverlayFormat.simID000;
          //       //   });
          //       //   break;
          //     }
          //   },
          //   items: const [
          //     BottomNavigationBarItem(
          //       icon: Icon(Icons.credit_card),
          //       label: 'Bankcard',
          //     ),
          //     // BottomNavigationBarItem(
          //     //     icon: Icon(Icons.contact_mail), label: 'US ID'),
          //     // BottomNavigationBarItem(icon: Icon(Icons.sim_card), label: 'Sim'),
          //   ],
          // ),
          backgroundColor: Colors.white,
          body: FutureBuilder<List<CameraDescription>?>(
            future: availableCameras(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data == null) {
                  return const Align(
                      alignment: Alignment.center,
                      child: Text(
                        'No camera found',
                        style: TextStyle(color: Colors.black),
                      ));
                }
                return CameraOverlay(
                    snapshot.data!.first,
                    CardOverlay.byFormat(format),
                        (XFile file) => showDialog(
                      context: context,
                      barrierColor: Colors.black,
                      builder: (context) {
                        CardOverlay overlay = CardOverlay.byFormat(format);
                        return AlertDialog(
                            actionsAlignment: MainAxisAlignment.center,
                            backgroundColor: Colors.black,
                            // title: const Text('찰칵',
                            //     style: TextStyle(color: Colors.white),
                            //     textAlign: TextAlign.center),
                            title: Row(
                              children: [
                                OutlinedButton(
                                  onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                    child: Container(
                                      alignment: Alignment.topLeft,
                                      child: const Icon(Icons.arrow_back_rounded)
                                    ),
                                ),
                                OutlinedButton(
                                    onPressed: () async {
                                    // final croppedfile = await cropImage(file.path);
                                    // print("start");
                                    ImageProperties properties = await FlutterNativeImage.getImageProperties(file.path);
                                    // print("properties");
                                    // print(properties.width!-500);
                                    // print(properties.height);
                                    // print(width.toInt());
                                    // print(height.toInt());
                                    // 250, 40, properties.width - 500, 640
                                    //400, 500, width.toInt(),height.toInt()
                                    // File croppedfile = await FlutterNativeImage.cropImage(file.path,350,300, properties.width! - 500, 640);
                                    // File croppedfile = await FlutterNativeImage.cropImage(file.path, 210, 30, properties.width! - 500, 640);

                                    File croppedfile = await FlutterNativeImage.cropImage(file.path, 210, 30, properties.width! - 500, 640);

                                    // print(croppedfile.path);
                                    final filename = await submit_uploadimg(croppedfile);
                                    // print(filename);

                                    Navigator.of(context).popUntil((route) => route.isFirst);
                                    await Navigator.push(context,MaterialPageRoute(builder: (context) =>
                                    HomePage(filename)),
                                    );
                                  },
                                      child: Container(
                                        alignment: Alignment.topRight,
                                        child: const Icon(Icons.send)
                                      ),
                                ),
                              ],
                            ),
                            actions: [
                              OutlinedButton(
                                // onPressed: () => Navigator.of(context).pop(),
                                //
                                //     Navigator.pop(context, file.path);
                                  onPressed: () async {
                                    final croppedfile = await cropImage(file.path);
                                    final filename = await submit_uploadimg(croppedfile); // 서버에 저장된 이름을 반환해줌 (이름을 알아야 url로 들어가니까)
                                    print(file.path);
                                    // final filename = await submit_uploadimg(file.path);
                                    // print(filename);

                                    Navigator.of(context).popUntil((route) => route.isFirst);
                                    await Navigator.push(context,MaterialPageRoute(builder: (context) =>
                                    HomePage(filename)),
                                    );
                                    },
                                    child: const Icon(Icons.edit))

                            ],
                            content: SizedBox( // 뒤로가기 버튼 만든 그 페이지 사이즈박스
                                width: double.infinity,
                                child: AspectRatio(
                                  aspectRatio: overlay.ratio!,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                          fit: BoxFit.fitWidth,
                                          alignment: FractionalOffset.center,
                                          image: FileImage(
                                            File(file.path),
                                          ),
                                        )),

                                  ),
                                )));
                      },


                    ),
                    info:
                    'please your ID',
                    label: 'Scanning ID Card');
              } else {
                return const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Fetching cameras',
                      style: TextStyle(color: Colors.black),
                    ));
              }
            },
          ),
        ));
  }
}
