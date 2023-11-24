// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:custom_image_editor/EditImage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:device_info_plus/device_info_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Editor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    try {
      bool permissionIsGranted = false;
      ph.Permission? permission;
      if(Platform.isAndroid){
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if(androidInfo.version.sdkInt <= 32){
          permission = ph.Permission.storage;
        }else{
          permission = ph.Permission.photos;
        }
      }
      permissionIsGranted = await permission!.isGranted;
      if(!permissionIsGranted){
        await permission.request();
        permissionIsGranted = await permission.isGranted;
      }
      if(permissionIsGranted){
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 100,
          maxWidth: 1000,
          maxHeight: 1000,
        );
        if(pickedFile != null){
          String imageUri = pickedFile.path;
          await editImage(File(imageUri));
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> editImage(File imageFile) async {
    final fileResult = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return EditImageComponent(imageFile: imageFile);
    }));
    if (fileResult != null && fileResult is FinishedImageData) {
      String file = fileResult.file.path;
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Save file to device', textAlign: TextAlign.center,),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                    downloadFile(file);
                  }, 
                  child: const Text('Yes')
                ),
                ElevatedButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                  }, child: const Text('No')
                )
              ],
            ),
          );
        }
      );
    }
  }

  void downloadFile(String url) async{
    Directory directory = await Directory('/storage/emulated/0/custom_image_editor').create(recursive: true);
    File originalFile = File(url);
    String filePath = '${directory.path}/${url.split('/').last}.png';
    await originalFile.copy(filePath).then((value){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File successfully saved to device!!!'),
          duration: Duration(seconds: 4),
        )
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Editor'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color.fromARGB(255, 111, 211, 181), Color.fromARGB(255, 146, 63, 74), Color.fromARGB(255, 123, 129, 40)
              ],
              stops: [
                0.25, 0.5, 0.75
              ],
            ),
          ),
        )
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => pickImage(),
              child: const Text('Pick Image')
            )
          ],
        ),
      )
    );
  }
}
