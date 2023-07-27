import 'dart:io';
import 'package:custom_image_editor/EditImage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ValueNotifier<String> imageLink = ValueNotifier('');
  ImagePicker _picker = ImagePicker();
  ValueNotifier<double> width = ValueNotifier(200);
  ValueNotifier<double> height = ValueNotifier(350);

  Future<void> pickImage() async {
    try {
      if(imageLink.value.isEmpty){
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 100,
          maxWidth: 1000,
          maxHeight: 1000,
        );
        if(pickedFile != null ){
          String imageUri = pickedFile.path;
          imageLink.value = imageUri;
        }
      }
    } catch (e) {
    }
  }

  Future<void> editImage(File imageFile) async {
    final fileResult = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return EditImageComponent(imageFile: imageFile);
    }));
    if (fileResult != null && fileResult is FinishedImageData) {
      String file = fileResult.file.path;
      imageLink.value = file;
      //get the size of the newly updated image
      width.value = fileResult.size.width;
      height.value = fileResult.size.height;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ValueListenableBuilder<String>(
              valueListenable: imageLink,
              builder: (BuildContext context, String imageLinkStr, Widget? child){
                return imageLinkStr.isEmpty ?
                  ElevatedButton(
                    onPressed: () => pickImage(),
                    child: Text('Pick Image')
                  )
                :
                  Stack(
                    children: [
                      ValueListenableBuilder<double>(
                        valueListenable: width,
                        builder: (BuildContext context, double width, Widget? child){
                          return ValueListenableBuilder<double>(
                            valueListenable: height,
                            builder: (BuildContext context, double height, Widget? child){
                              return Image.file(File(imageLinkStr), fit: BoxFit.cover, width: width, height: height);
                            }
                          );
                        }
                      ),
                      Positioned(
                        top: 5, right: 0.03 * getScreenWidth(),
                        child: Container(
                          width: 0.075 * getScreenWidth(),
                          height: 0.075 * getScreenWidth(),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: GestureDetector(
                            onTap: () => imageLink.value = '',
                            child: Icon(Icons.delete, size: 25, color: Colors.white)
                          )
                        )
                      ),
                      Positioned(
                        top: 5, right: 0.13 * getScreenWidth(),
                        child: Container(
                          width: 0.075 * getScreenWidth(),
                          height: 0.075 * getScreenWidth(),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: GestureDetector(
                            onTap: () => editImage(File(imageLinkStr)),
                            child: Icon(Icons.edit, size: 25, color: Colors.white)
                          )
                        )
                      ),
                    ],
                  );
              }
            )

          ],
          
        ),
      )
    );
  }
}
