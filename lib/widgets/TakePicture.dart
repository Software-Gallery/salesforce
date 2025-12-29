import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:salesforce/common_widgets/Utils.dart';
import 'package:salesforce/config.dart';
import 'package:salesforce/styles/colors.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool isFrontCamera = true;
  String server = '';

  @override
  void dispose() {
    _controller.dispose();
    // _timer.cancel();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);    
    super.dispose();
  }

  Future<CameraDescription> setRearCamera() async {
    final cameras = await availableCameras();
    final newCamera = isFrontCamera ? cameras[1] : cameras[0];

    return newCamera;
  }

  File fixImgOrientation(File file) {
    try {
      final Uint8List bytes = file.readAsBytesSync();
      final img.Image? capturedImage =
          img.decodeImage(Uint8List.fromList(bytes));

      if (capturedImage != null) {
        final img.Image orientedImage = img.bakeOrientation(capturedImage);

        // Simpan gambar yang sudah diatur orientasinya
        final File orientedFile =
            File('${file.parent.path}/oriented_${file.uri.pathSegments.last}');
        orientedFile
            .writeAsBytesSync(Uint8List.fromList(img.encodeJpg(orientedImage)));

        return orientedFile;
      } else {
        //print('Gagal mendekode gambar.');
      }
    } catch (e) {
      //print('Error: $e');
    }

    return file; // Jika terjadi kesalahan, kembalikan file asli tanpa perubahan
  }

  Future<File?> testCompressAndGetFile(
      File originalFile, String targetPath) async {
    try {
      //print("Original File Path: ${originalFile.path}");
      //print("Original File Name: ${basename(targetPath)}");

      var targetPaths = basename(targetPath).split('.');
      var newFileName = "${targetPaths[0]}_out.${targetPaths[1]}";
      var newPath = join(originalFile.parent.path, newFileName);

      var result = await FlutterImageCompress.compressAndGetFile(
        originalFile.absolute.path,
        newPath,
        quality: 50,
        // rotate: 180,
      );

      if (result != null) {
        var compressedFile = File(result.path);
        //print("Original File Size: ${originalFile.lengthSync()} bytes");
        //print("Compressed File Size: ${compressedFile.lengthSync()} bytes");
        return compressedFile;
      } else {
        //print("Compression failed. Returning the original file.");
        return originalFile;
      }
    } catch (e) {
      if (e is CompressError) {
        //print("Compression Error: ${e.message}");
      } else {
        //print("Unexpected Error: $e");
      }
      return originalFile;
    }
  }

  Future<void> setShared() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      server = prefs.getString('CURRENTSETTING') ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    setRearCamera().then((newCamera) {
      _controller = CameraController(
        newCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      _controller.setFlashMode(FlashMode.torch);
      _controller.setFlashMode(FlashMode.off);

      _initializeControllerFuture = _controller.initialize();

      setState(() {});

      // _timer = Timer(Duration(seconds: 10), () {
      //   Utils.showActionSnackBar(context: context, showLoad: false, text: "Waktu Foto Melewati 10 detik, Silahkan Coba Lagi");
      //   // Navigator.popUntil(this.context, (route) => route.isFirst);
      //   Navigator.popUntil(this.context, (route) => route.isFirst);
      // });
    });
    setShared();
  }

  void _toggleCamera() async {
    final cameras = await availableCameras();
    final newCamera = isFrontCamera ? cameras[0] : cameras[1];

    if (newCamera == null) return;

    setState(() {
      isFrontCamera = !isFrontCamera;
      _controller = CameraController(
        newCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      _controller.setFlashMode(FlashMode.torch);
      _controller.setFlashMode(FlashMode.off);
      _initializeControllerFuture = _controller.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    void _handleTap(Offset tapPosition) {
      final xPercentage = tapPosition.dx / context.size!.width;
      final yPercentage = tapPosition.dy / context.size!.height;

      if (_controller != null && _controller.value.isInitialized) {
        _controller
            .setFlashMode(FlashMode.auto); // Set flash mode ke auto (opsional)
        _controller.setFocusMode(FocusMode.auto); // Set focus mode ke auto

        // Set titik fokus pada posisi yang di-tap
        _controller.setExposurePoint(Offset(xPercentage, yPercentage));
        _controller.setFocusPoint(Offset(xPercentage, yPercentage));
      }
    }

    return Scaffold(
        body: Stack(
          children: [
            FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final size = MediaQuery.of(context).size;
                  final deviceRatio = size.width / size.height;
            
                  // Pastikan previewSize tidak null
                  final previewSize = _controller.value.previewSize!;
                  final cameraRatio = previewSize.height / previewSize.width;
                  return GestureDetector(
                    onTapDown: (details) {
                      _handleTap(details.localPosition);
                    },
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final orientation = MediaQuery.of(context).orientation;
                        final screenWidth = constraints.maxWidth;
                        final screenHeight = constraints.maxHeight;
                        final deviceRatio = screenWidth / screenHeight;
            
                        // Jika landscape, tukar lebar dan tinggi untuk rasio kamera
                        final adjustedCameraRatio =
                            orientation == Orientation.portrait ? cameraRatio : 1 / cameraRatio;
            
                        // Hitung scale yang tepat agar tidak gepeng
                        final scale = adjustedCameraRatio / deviceRatio;
            
                        return Transform.scale(
                          scale: scale < 1 ? 1 / scale : scale,
                          child: Center(
                            child: AspectRatio(
                              aspectRatio: adjustedCameraRatio,
                              child: Transform(
                                alignment: Alignment.center,
                                transform:
                                    isFrontCamera ? Matrix4.rotationY(math.pi) : Matrix4.identity(),
                                child: isFrontCamera 
                                ? Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.rotationY(math.pi),
                                  child: CameraPreview(_controller),
                                )
                                : CameraPreview(_controller),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
            
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // remove this line
                children: [
                  Container(  
                    width: double.maxFinite,
                    height: AppConfig.appSize(context, .12),
                    padding: EdgeInsets.symmetric(horizontal: AppConfig.appSize(context, .02), vertical: AppConfig.appSize(context, .02)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppConfig.appSize(context, .015),),
                        topRight: Radius.circular(AppConfig.appSize(context, .015),),
                      )
                    ),
                    child: 
                    
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(14),
                            minimumSize: Size(56, 56),
                          ),
                          onPressed: _toggleCamera,
                          child: SvgPicture.asset(
                            "assets/svg/switch.svg",
                            color: Colors.white,
                            width: 28,
                            height: 28,
                          ),
                        ),

                        // Tombol ambil foto
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(18),
                            minimumSize: Size(64, 64),
                          ),
                          onPressed: () async {
                            try {
                              showDialog(
                                context: context,
                                builder: (context) => const Center(child: CircularProgressIndicator()),
                              );
                              await _initializeControllerFuture;
                              _controller.setFlashMode(FlashMode.off);
                              var fixImg;
                              var image = await _controller.takePicture();

                              fixImg = await fixImgOrientation(File(image.path)) ?? image;

                              File finalImg = await testCompressAndGetFile(fixImg, fixImg.path) ?? fixImg;
                              
                              if (!mounted) return;
                              Navigator.pop(context); // tutup loading
                              Navigator.pop(context, finalImg.path); // kembali dan kirim path foto
                            } catch (e) {
                              print(e);
                              if (mounted) Navigator.pop(context); // tutup loading kalau error
                            }
                          },
                          child: SvgPicture.asset(
                            "assets/svg/camera.svg",
                            color: Colors.white,
                            width: 32,
                            height: 32,
                          ),
                        ),

                        // Tombol cancel (icon X)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(14),
                            minimumSize: Size(56, 56),
                          ),
                          onPressed: () {
                            Navigator.pop(context); // misal cancel berarti close page
                          },
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
              )  
            )
          ],
        ),
        // floatingActionButton: Column(
        //   mainAxisAlignment: MainAxisAlignment.end,
        //   children: [
        //     FloatingActionButton(
        //       backgroundColor: AppColors.primaryColor,
        //       onPressed: _toggleCamera,
        //       child: SvgPicture.asset("assets/svg/switch.svg", color: Colors.white,),
        //     ),
        //     const SizedBox(height: 16),
        //     FloatingActionButton(
        //       backgroundColor: AppColors.primaryColor,
        //       onPressed: () async {
        //         try {
        //           showDialog(
        //               context: context,
        //               builder: (context) =>
        //                   const Center(child: CircularProgressIndicator()));
        //           await _initializeControllerFuture;
        //           _controller.setFlashMode(FlashMode.off);
        //           var fixImg;
        //           var image = await _controller.takePicture();

        //           fixImg = await fixImgOrientation(File(image.path)) ?? image;

        //           File finalImg =
        //               await testCompressAndGetFile(fixImg, fixImg.path) ??
        //                   fixImg;
        //           //print(finalImg.path);
        //           if (!mounted) return;
        //           Navigator.pop(context);
        //           Navigator.pop(context, finalImg.path);
        //         } catch (e) {
        //           //print(e);
        //         }
        //       },
        //       child: SvgPicture.asset("assets/svg/camera.svg", color: Colors.white,),
        //     ),
        //   ],
        // ),
      );
  }
}
