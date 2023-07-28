import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:uuid/uuid.dart';
import 'provider/EditImageProvider.dart';

const ballDiameter = 20.0;

class FinishedImageData {
  final File file;
  final Size size;

  FinishedImageData(this.file, this.size);
}

class EditImageComponent extends StatelessWidget {
  const EditImageComponent({super.key, required this.imageFile});
  final File imageFile;


  @override
  Widget build(BuildContext context){
    return EditImageComponentState(imageFile: imageFile);
  }
}

class EditImageComponentState extends StatefulWidget{
  final File imageFile;
  const EditImageComponentState({super.key, required this.imageFile});
  
  @override
  State<EditImageComponentState> createState() => ImageEditorState();
}

class ImageEditorState extends State<EditImageComponentState> {
  ValueNotifier<double> draggedWidth = ValueNotifier(0);
  ValueNotifier<double> draggedTop = ValueNotifier(0);
  ValueNotifier<double> draggedLeft = ValueNotifier(0);
  ValueNotifier<double> draggedHeight = ValueNotifier(0);
  GlobalKey widgetKey = GlobalKey();
  ValueNotifier<double> imageHeight = ValueNotifier(0);
  ValueNotifier<double> imageWidth = ValueNotifier(0);
  ValueNotifier<double> currentDegrees = ValueNotifier(0);
  ValueNotifier<bool> allowGenerateText = ValueNotifier(false);
  ValueNotifier<bool> inputsNotEmpty = ValueNotifier(false);
  double prevAngle = -1;
  TextEditingController addTextController = TextEditingController();
  ValueNotifier<String> currentText = ValueNotifier('');
  ValueNotifier<bool> boldCurrentText = ValueNotifier(false);
  ValueNotifier<Offset> currentTextOffset = ValueNotifier(const Offset(0, 0));
  double appBarHeight = 80;
  ValueNotifier<double> iconsListHeight = ValueNotifier(0.1 * getScreenHeight());
  List availableColors = [
    Colors.black, Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.purple,
    Colors.orange, Colors.cyan, Colors.amber, Colors.grey, Colors.pink
  ];
  
  @override
  void initState(){
    super.initState();
    addTextController.addListener(() {
      inputsNotEmpty.value = addTextController.text.isNotEmpty;
    });
  }

  Widget cropRectangleComponent(child, EditImageProvider editImageProvider){
    double degrees = radiansToDegrees(editImageProvider.state.rotationAngle);
    double totalWidth = 0;
    double totalHeight = 0;
    if(degrees % 180 == 0){
      totalWidth = editImageProvider.state.width;
      totalHeight = editImageProvider.state.height;
    }else{
      totalHeight = editImageProvider.state.width;
      totalWidth = editImageProvider.state.height;
    }

    return Stack(
      children: <Widget>[
        Positioned(
          child: Container(
            child: child,
          ),
        ),
        // top left
        Positioned(
          top: getTop(draggedTop.value) - ballDiameter / 2,
          left: getLeft(draggedLeft.value) - ballDiameter / 2,
          child: ManipulatingBall(
            onDrag: (dx, dy) {
              var mid = (dx + dy) / 2;
              var newHeight =draggedHeight.value - 2 * mid;
              var newWidth =draggedWidth.value - 2 * mid;
              draggedHeight.value = getTop(newHeight > 0 ? newHeight : 0);
              draggedWidth.value = getLeft(newWidth > 0 ? newWidth : 0);
              if(draggedTop.value + mid + draggedHeight.value <= totalHeight){
                draggedTop.value = getTop(draggedTop.value + mid);
              }
              if(draggedLeft.value + mid + draggedWidth.value <= totalWidth){
                draggedLeft.value = getLeft(draggedLeft.value + mid);
              }
            },
            height: draggedHeight.value
          ),
        ),
        // top middle
        Positioned(
          top: getTop(draggedTop.value) - ballDiameter / 2,
          left: (getLeft(draggedLeft.value) + getLeft(draggedLeft.value +draggedWidth.value)) / 2 - ballDiameter / 2,
          child: ManipulatingBall(
            onDrag: (dx, dy) {
              var newHeight =draggedHeight.value - dy;
              draggedHeight.value = getTop(newHeight > 0 ? newHeight : 0);
              if(draggedTop.value + dy +draggedHeight.value <= totalHeight){
                draggedTop.value = getTop(draggedTop.value + dy);
              }
            },
            height: draggedHeight.value
          ),
        ),
        // top right
        Positioned(
          top: getTop(draggedTop.value) - ballDiameter / 2,
          left: getLeft(draggedLeft.value +draggedWidth.value) - ballDiameter / 2,
          child: ManipulatingBall(
            onDrag: (dx, dy) {
              var mid = (dx + (dy * -1)) / 2;
              var newHeight =draggedHeight.value + 2 * mid;
              var newWidth =draggedWidth.value + 2 * mid;
              draggedHeight.value = getTop(newHeight +draggedTop.value > totalHeight ?draggedHeight.value : newHeight > 0 ? newHeight : 0);
              draggedWidth.value = getLeft(newWidth +draggedLeft.value > totalWidth ?draggedWidth.value : newWidth > 0 ? newWidth : 0);
              if(draggedTop.value - mid +draggedHeight.value <= totalHeight){
                draggedTop.value = getTop(draggedTop.value - mid);
              }
              if(draggedLeft.value - mid +draggedWidth.value <= totalWidth){
                draggedLeft.value = getLeft(draggedLeft.value - mid);
              }
            },
            height: draggedHeight.value
          ),
        ),
        // center right
        Positioned(
          top: (getTop(draggedTop.value +draggedHeight.value) + getTop(draggedTop.value)) / 2 - ballDiameter / 2,
          left: getLeft(draggedLeft.value +draggedWidth.value) - ballDiameter / 2,
          child: ManipulatingBall(
            onDrag: (dx, dy) {
              var newWidth =draggedWidth.value + dx;
              draggedWidth.value = getLeft(newWidth +draggedLeft.value > totalWidth ?draggedWidth.value : newWidth > 0 ? newWidth : 0);
            },
            height: draggedHeight.value
          ),
          
        ),
        // bottom right
        Positioned(
          top: getTop(draggedTop.value +draggedHeight.value) - ballDiameter / 2,
          left: getLeft(draggedLeft.value +draggedWidth.value) - ballDiameter / 2,
          child: ManipulatingBall(
            onDrag: (dx, dy) {
              var mid = (dx + dy) / 2;
              var newHeight =draggedHeight.value + 2 * mid;
              var newWidth =draggedWidth.value + 2 * mid;
              draggedHeight.value = getTop(newHeight +draggedTop.value > totalHeight ?draggedHeight.value : newHeight > 0 ? newHeight : 0);
              draggedWidth.value = getLeft(newWidth +draggedLeft.value > totalWidth ?draggedWidth.value : newWidth > 0 ? newWidth : 0);
              if(draggedTop.value - mid +draggedHeight.value <= totalHeight){
                draggedTop.value = getTop(draggedTop.value - mid);
              }
              if(draggedLeft.value - mid +draggedWidth.value <= totalWidth){
                draggedLeft.value = getLeft(draggedLeft.value - mid);
              }
            },
            height: draggedHeight.value
          ),
        ),
        // bottom center
        Positioned(
          top: getTop(draggedTop.value +draggedHeight.value) - ballDiameter / 2,
          left: (getLeft(draggedLeft.value) + getLeft(draggedLeft.value +draggedWidth.value)) / 2 - ballDiameter / 2,
          child: ManipulatingBall(
            onDrag: (dx, dy) {
              var newHeight =draggedHeight.value + dy;
              draggedHeight.value = getTop(newHeight +draggedTop.value > totalHeight ?draggedHeight.value : newHeight > 0 ? newHeight : 0);
            },
            height: draggedHeight.value
          ),
        ),
        // bottom left
        Positioned(
          top: getTop(draggedTop.value +draggedHeight.value) - ballDiameter / 2,
          left: getLeft(draggedLeft.value) - ballDiameter / 2,
          child: ManipulatingBall(
            onDrag: (dx, dy) {
              var mid = ((dx * -1) + dy) / 2;
              var newHeight =draggedHeight.value + 2 * mid;
              var newWidth =draggedWidth.value + 2 * mid;
              draggedHeight.value = getTop(newHeight +draggedTop.value > totalHeight ?draggedHeight.value : newHeight > 0 ? newHeight : 0);
              draggedWidth.value = getLeft(newWidth +draggedLeft.value > totalWidth ?draggedWidth.value : newWidth > 0 ? newWidth : 0);
              if(draggedTop.value - mid +draggedHeight.value <= totalHeight){
                draggedTop.value = getTop(draggedTop.value - mid);
              }
              if(draggedLeft.value - mid +draggedWidth.value <= totalWidth){
                draggedLeft.value = getLeft(draggedLeft.value - mid);
              }
            },
            height: draggedHeight.value
          ),
        ),
        //left center
        Positioned(
          top: (getTop(draggedTop.value +draggedHeight.value) + getTop(draggedTop.value)) / 2 - ballDiameter / 2,
          left: getLeft(draggedLeft.value) - ballDiameter / 2,
          child: ManipulatingBall(
            onDrag: (dx, dy) {
              var newWidth =draggedWidth.value - dx;
              draggedWidth.value = getLeft(newWidth +draggedLeft.value > totalWidth ?draggedWidth.value : newWidth > 0 ? newWidth : 0);
              draggedLeft.value = getLeft(draggedLeft.value + dx);
            },
            height: draggedHeight.value
          ),
        ),
        //center center
        Positioned(
          top: (getTop(draggedTop.value +draggedHeight.value) + getTop(draggedTop.value)) / 2 - ballDiameter / 2,
          left: (getLeft(draggedLeft.value) + getLeft(draggedLeft.value +draggedWidth.value)) / 2 - ballDiameter / 2,
          child: ManipulatingBall(
            onDrag: (dx, dy) {
              if(draggedTop.value + dy +draggedHeight.value <= totalHeight){
                draggedTop.value = getTop(draggedTop.value + dy);
              }
              if(draggedLeft.value+ dx +draggedWidth.value <= totalWidth){
                draggedLeft.value = getLeft(draggedLeft.value + dx);
              }
            },
            height: draggedHeight.value
          ),
        ),
      ],
    );
  }

  Widget paintCanvasComponent(child, EditImageProvider editImageProvider){
    return GestureDetector(
      onPanUpdate: (details) {
        Offset position = details.globalPosition;
        RenderBox renderBox = context.findRenderObject() as RenderBox;
        Offset localPosition = renderBox.globalToLocal(position);
        localPosition = applyPaintRotationTransformation(localPosition, editImageProvider);
        editImageProvider.addLatestPoints(localPosition);
        editImageProvider.togglePaintState(true);
      },
      onPanEnd: (details) {
        editImageProvider.updateDrawingsList(editImageProvider.state.points);
        editImageProvider.clearPoints();
        editImageProvider.togglePaintState(true);
      },
      child: child
    );
  }
  
  void onDrag(double dx, double dy) {
    var newHeight = draggedHeight.value + dy;
    var newWidth = draggedWidth.value + dx;

    draggedHeight.value = getTop(newHeight + draggedTop.value > imageHeight.value ? draggedHeight.value : newHeight > 0 ? newHeight : 0);
    draggedWidth.value = getLeft(newWidth + draggedLeft.value > imageWidth.value ? draggedWidth.value : newWidth > 0 ? newWidth : 0);
  }

  double getTop(double top2){
    if(currentDegrees.value % 180 == 0){
      return max(0, min(top2.toDouble(), imageHeight.value));
    }
    return max(0, min(top2.toDouble(), imageWidth.value));
  }

  double getLeft(double left){
    if(currentDegrees.value % 180 == 0){
      return max(0, min(left.toDouble(), imageWidth.value));
    }
    return max(0, min(left.toDouble(), imageHeight.value));
  }

  void showAddTextPopup(BuildContext context, double degrees, EditImageProvider editImageProvider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Text'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Enter the text:'),
                  TextField(
                    controller: addTextController,
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: boldCurrentText.value,
                        onChanged: (newValue){
                          setState((){
                            boldCurrentText.value = newValue!;
                          });
                        },
                      ),
                      const Text('Bold text')
                    ]
                  )
                ],
              ),
              actions: [
                ElevatedButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: inputsNotEmpty,
                  builder: (BuildContext context, bool inputsNotEmpty, Widget? child) {
                    return ElevatedButton(
                      child: const Text('Generate'),
                      onPressed: inputsNotEmpty ? () {
                        currentText.value = addTextController.text;
                        addTextController.text = '';
                        if(degrees == 0){
                          currentTextOffset.value = const Offset(0, 0);
                        }else if(degrees == 90){
                          currentTextOffset.value = Offset((editImageProvider.state.width - editImageProvider.state.height) / 2, -(editImageProvider.state.width - editImageProvider.state.height) / 2);
                        }else if(degrees == 180){
                          currentTextOffset.value = const Offset(0, 0);
                        }else if(degrees == 270){
                          currentTextOffset.value = Offset((editImageProvider.state.width - editImageProvider.state.height) / 2, -(editImageProvider.state.width - editImageProvider.state.height) / 2);
                        }
                        Navigator.of(context).pop();
                      } : null,
                    );
                  }
                )
              ],
            );
          }
        );
      },
    );
  }

  Widget AddTextComponent(child, EditImageProvider editImageProvider){
    double containerWidth = editImageProvider.state.width;
    double containerHeight = editImageProvider.state.height;
    Offset offsetChange = applyDragTextRotationTransformation(currentTextOffset.value, editImageProvider);

    return Stack(
      children: [
        Positioned(
          child: Container(
            width: containerWidth,
            height: containerHeight,
            child: child
          ),
        ),
        Positioned(
          left: offsetChange.dx,
          top: offsetChange.dy,
          child: Draggable(
            child: Text(
              currentText.value,
              style: generateAddTextStyle(16, editImageProvider.state.selectedAddTextColor, boldCurrentText.value),
            ),
            feedback: Material(
              color: Colors.transparent,
              child: Text(
                currentText.value,
                style: generateAddTextStyle(16, editImageProvider.state.selectedAddTextColor, boldCurrentText.value),
              )
            ),
            childWhenDragging: Container(),
            onDraggableCanceled: (velocity, offset) {
              RenderBox renderBox = context.findRenderObject() as RenderBox;
              Offset localPosition = renderBox.globalToLocal(offset);
              currentTextOffset.value = Offset(localPosition.dx - (getScreenWidth() - containerWidth) / 2, localPosition.dy - appBarHeight - (getScreenHeight() - containerHeight - appBarHeight - iconsListHeight.value) / 2);
            },
            onDragEnd: (details) {
              Offset position = details.offset;
              RenderBox renderBox = context.findRenderObject() as RenderBox;
              Offset localPosition = renderBox.globalToLocal(position);
              currentTextOffset.value = Offset(localPosition.dx - (getScreenWidth() - containerWidth) / 2, localPosition.dy - appBarHeight - (getScreenHeight() - containerHeight - appBarHeight - iconsListHeight.value) / 2);
            },
          ),
        ),
      ],
    );
  }

  Widget generateCanvas(ImageInfo? imageInfo, EditImageProvider editImageProvider, BuildContext context){
    return CustomPaint(
      painter: ImagePainter(imageInfo!, editImageProvider.state, context),
    );
  }

  Future<void> createImagePng(BuildContext context, EditImageProvider editImageProvider) async {
    Timer.periodic(const Duration(milliseconds: 500), (Timer timer) async{
      timer.cancel();
      RenderRepaintBoundary? boundary = widgetKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
      try {
        if (boundary.debugNeedsPaint) {
          await Future.delayed(const Duration(milliseconds: 5));
          return createImagePng(context, editImageProvider);
        }
      } catch (_) {}
      try {
        ui.Image image = await boundary.toImage(pixelRatio: 5.0);
        ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        Uint8List pngBytes = byteData!.buffer.asUint8List();
        File? tempFile = await saveUint8ListAsImage(pngBytes);
        double degrees = radiansToDegrees(editImageProvider.state.rotationAngle);
        if (tempFile != null) {
          Navigator.pop(context, FinishedImageData(
            tempFile,
            Size(
              degrees % 180 == 0 ? editImageProvider.state.width : editImageProvider.state.height,
              degrees % 180 == 0 ? editImageProvider.state.height : editImageProvider.state.width
            )
          ));
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Error'),
                content: const Text('An error occurred while saving the image.'),
                actions: <Widget>[
                  ElevatedButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      } catch (_) {
        await Future.delayed(const Duration(milliseconds: 5));
        return createImagePng(context, editImageProvider);
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ImageInfo>(
      future: loadImageInfoFromFile(widget.imageFile),
      builder: (BuildContext context, AsyncSnapshot<ImageInfo>snapshot) {
        if(snapshot.hasData){
          return MultiProvider(
            providers: [
              ChangeNotifierProvider<EditImageProvider>(
                create: (context) => EditImageProvider(),
              ),
            ],
            child: Consumer<EditImageProvider>(
              builder: (context, EditImageProvider editImageProvider, _) {
                double degrees = radiansToDegrees(editImageProvider.state.rotationAngle);
                double currentWidth = snapshot.data!.image.width.toDouble();
                double currentHeight = snapshot.data!.image.height.toDouble();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if(editImageProvider.state.width == 0 && editImageProvider.state.height == 0){
                    Size imageSize = getSizeScale(degrees, currentWidth, currentHeight, getScreenWidth(), getScreenHeight());
                    editImageProvider.updateTotalImageSize(imageSize.width, imageSize.height);
                    editImageProvider.updateWidth(imageSize.width);
                    editImageProvider.updateHeight(imageSize.height);
                    imageWidth.value = imageSize.width;
                    imageHeight.value = imageSize.height;
                  }
                });
                EditType selectedEditType = editImageProvider.state.selectedEditType;
                if(selectedEditType == EditType.crop && prevAngle != degrees){
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    draggedWidth.value = degrees == 0 || degrees == 180 ? editImageProvider.state.width : editImageProvider.state.height;
                    draggedHeight.value = degrees == 0 || degrees == 180 ? editImageProvider.state.height : editImageProvider.state.width;
                    prevAngle = degrees;
                  });
                }else if(selectedEditType != EditType.crop){
                  draggedTop.value = 0;
                  draggedLeft.value = 0;
                  draggedWidth.value = 0;
                  draggedHeight.value = 0;
                  prevAngle = -1;
                }
                return Scaffold(
                  resizeToAvoidBottomInset: false,
                  appBar: AppBar(
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    title: Row(
                      children: const [
                        Text(
                          'Image Editor',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      selectedEditType == EditType.crop ?
                        Container(
                          width: 0.2 * getScreenWidth(),
                          child: ElevatedButton(
                            onPressed: (){
                              final editImageProvider = Provider.of<EditImageProvider>(context, listen: false);          
                              editImageProvider.updateToCrop({
                                'top':draggedTop.value.toDouble(),
                                'width':draggedWidth.value.toDouble(),
                                'height':draggedHeight.value.toDouble(),
                                'left':draggedLeft.value.toDouble()
                              });
                              editImageProvider.togglePaintState(true);
                              draggedLeft.value = 0;
                              draggedTop.value = 0;
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                side: BorderSide.none,
                                borderRadius: BorderRadius.circular(0),
                              ),
                            ),  
                            child: const Text('Crop')
                          )
                        )
                      : 
                      ValueListenableBuilder<String>(
                        valueListenable: currentText,
                        builder: (BuildContext context, String text, Widget? child) {
                          return selectedEditType == EditType.addText && text.isNotEmpty ?
                            Row(
                              children: [
                               IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: (){
                                    currentText.value = '';
                                    boldCurrentText.value = false;
                                    currentTextOffset.value = const Offset(0, 0);
                                  }
                                ),
                                IconButton(
                                  icon: const Icon(Icons.check),
                                  onPressed: (){
                                    editImageProvider.updateDrawingsList(
                                      {
                                        'text': currentText.value,
                                        'offset': applyAddTextRotationTransformation(currentTextOffset.value, editImageProvider),
                                        'angle': editImageProvider.state.rotationAngle,
                                        'bold': boldCurrentText.value
                                      },
                                    );
                                    editImageProvider.togglePaintState(true);
                                    currentText.value = '';
                                    boldCurrentText.value = false;
                                    currentTextOffset.value = const Offset(0, 0);
                                  }
                                )
                              ]
                            )
                          :
                            Container();
                        }
                      ),
                      ValueListenableBuilder<String>(
                        valueListenable: currentText,
                        builder: (BuildContext context, String text, Widget? child) {
                          return text.isEmpty ?
                            Container(
                              width: 0.2 * getScreenWidth(),
                              child: ElevatedButton(
                                onPressed: () {
                                  editImageProvider.updateSelectedEditType(EditType.none);
                                  iconsListHeight.value = 0.1 * getScreenHeight();
                                  createImagePng(context, editImageProvider);
                                },
                                child: const Text('Save'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.lightGreen,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide.none,
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                )
                              )
                            )
                          : Container();
                        }
                      )
                    ],
                  ),
                  body: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          children: [
                            Container(
                              height: getScreenHeight() - appBarHeight - iconsListHeight.value,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: degrees == 0 || degrees == 180 ? editImageProvider.state.width : editImageProvider.state.height,
                                    height: degrees == 0 || degrees == 180 ? editImageProvider.state.height : editImageProvider.state.width,
                                    child: RepaintBoundary(
                                    key: widgetKey,
                                    child: selectedEditType == EditType.crop ? 
                                      ValueListenableBuilder<double>(
                                        valueListenable: draggedWidth,
                                        builder: (BuildContext context, double width, Widget? child) {
                                          return ValueListenableBuilder<double>(
                                            valueListenable: draggedHeight,
                                            builder: (BuildContext context, double height, Widget? child) {
                                              return ValueListenableBuilder<double>(
                                                valueListenable: draggedLeft,
                                                builder: (BuildContext context, double left, Widget? child) {
                                                  return ValueListenableBuilder<double>(
                                                    valueListenable: draggedTop,
                                                    builder: (BuildContext context, double top, Widget? child) {
                                                      return cropRectangleComponent(
                                                        generateCanvas(snapshot.data, editImageProvider, context),
                                                        editImageProvider
                                                      );
                                                    }
                                                  );
                                                }
                                              );
                                            }
                                          );
                                        }
                                      )
                                    : selectedEditType == EditType.paint ? 
                                      paintCanvasComponent(
                                        generateCanvas(snapshot.data, editImageProvider, context),
                                        editImageProvider
                                      )
                                    : selectedEditType == EditType.addText ?
                                      ValueListenableBuilder<Offset>(
                                        valueListenable: currentTextOffset,
                                        builder: (BuildContext context, Offset currenTextOffset, Widget? child) {
                                          return ValueListenableBuilder<String>(
                                            valueListenable: currentText,
                                            builder: (BuildContext context, String currentText, Widget? child) {
                                              return AddTextComponent(
                                                generateCanvas(snapshot.data, editImageProvider, context),
                                                editImageProvider
                                              );
                                            }
                                          );
                                        }
                                      )
                                    : 
                                      Container(
                                        child: generateCanvas(snapshot.data, editImageProvider, context),
                                      )
                                    )
                                  )
                                ]
                              ),
                            )
                          ],
                        )
                      ),
                      ValueListenableBuilder<double>(
                        valueListenable: iconsListHeight,
                        builder: (BuildContext context, double height, Widget? child) {
                          return Container(
                            height: height,
                            decoration: const BoxDecoration(
                              border: Border(top: BorderSide(color: Colors.black, width: 1)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                editImageProvider.state.selectedEditType == EditType.paint || editImageProvider.state.selectedEditType == EditType.addText ?
                                  Expanded(
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemCount: availableColors.length,
                                      itemBuilder: (context, i){
                                        return Row(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.symmetric(horizontal: 0.015* getScreenWidth(), vertical: 0.015 * getScreenHeight()),
                                              child: GestureDetector(
                                                onTap: (){
                                                  if(editImageProvider.state.selectedEditType == EditType.paint){
                                                    editImageProvider.updatePaintColor(availableColors[i]);
                                                  }else if(editImageProvider.state.selectedEditType == EditType.addText){
                                                    editImageProvider.updateAddTextColor(availableColors[i]);
                                                  }
                                                },
                                                child: Container(
                                                  height: 0.08 * getScreenWidth(),
                                                  width: 0.08 * getScreenWidth(),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      width: (editImageProvider.state.selectedEditType == EditType.paint && editImageProvider.state.selectedPaintColor == availableColors[i]) ||
                                                        (editImageProvider.state.selectedEditType == EditType.addText && editImageProvider.state.selectedAddTextColor == availableColors[i]) ? 
                                                      2 : 0,
                                                      color: Colors.black
                                                    ),
                                                    color: availableColors[i],
                                                  )
                                                ),
                                              )
                                            )
                                          ]
                                        );
                                      }
                                    )
                                  )
                                : Container(),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(getScreenWidth() * 0.0125),
                                      color: selectedEditType == EditType.crop ? Colors.grey : Colors.transparent,
                                      margin: EdgeInsets.symmetric(horizontal: 0.015* getScreenWidth(), vertical: 0.015 * getScreenHeight()),
                                      child: InkWell(
                                        onTap: () {
                                          editImageProvider.updateSelectedEditType(EditType.crop);
                                          iconsListHeight.value = 0.1 * getScreenHeight();
                                        },
                                        child: const Icon(
                                          Icons.crop,
                                          size: 30,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(getScreenWidth() * 0.0125),
                                      color: selectedEditType == EditType.rotate ? Colors.grey : Colors.transparent,
                                      margin: EdgeInsets.symmetric(horizontal: 0.015* getScreenWidth()),
                                      child: InkWell(
                                        onTap: () {
                                          editImageProvider.updateSelectedEditType(EditType.rotate);
                                          double newRotationAngle = addClockwiseRotation(editImageProvider.state.rotationAngle, 90);
                                          editImageProvider.updateRotationAngle(newRotationAngle);
                                          currentDegrees.value = radiansToDegrees(newRotationAngle);
                                          currentTextOffset.value = const Offset(0, 0);
                                          currentText.value = '';
                                          boldCurrentText.value = false;
                                          iconsListHeight.value = 0.1 * getScreenHeight();
                                          editImageProvider.togglePaintState(true);
                                        },
                                        child: const Icon(
                                          Icons.rotate_right,
                                          size: 30,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(getScreenWidth() * 0.0125),
                                      color: selectedEditType == EditType.paint ? Colors.grey : Colors.transparent,
                                      margin: EdgeInsets.symmetric(horizontal: 0.015* getScreenWidth()),
                                      child: InkWell(
                                        onTap: () {
                                          editImageProvider.updateSelectedEditType(EditType.paint);
                                          iconsListHeight.value = 0.165 * getScreenHeight();
                                        },
                                        child: const Icon(
                                          Icons.draw,
                                          size: 30,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(getScreenWidth() * 0.0125),
                                      color: selectedEditType == EditType.addText ? Colors.grey : Colors.transparent,
                                      margin: EdgeInsets.symmetric(horizontal: 0.015* getScreenWidth()),
                                      child: InkWell(
                                        onTap: () {
                                          editImageProvider.updateSelectedEditType(EditType.addText);
                                          currentText.value = '';
                                          boldCurrentText.value = false;
                                          showAddTextPopup(context, degrees, editImageProvider);
                                          iconsListHeight.value = 0.165 * getScreenHeight();
                                        },
                                        child: const Icon(
                                          Icons.edit,
                                          size: 30,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        }
                      )
                    ]
                  )
                  
                );
              }
            )
          );
        }
        return Scaffold(
          body: Opacity(
            opacity: 1,
            child: Container(
              color: Colors.transparent,
              width: getScreenWidth(),
              height: getScreenHeight(),
              child: const Center(
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(color: Colors.redAccent),
                ),
              ),
            ),
          )
        );
      }
    );
  }
}

Paint generatePaintColor(Color color){
  return Paint()
    ..color = color
    ..strokeWidth = 5
    ..strokeCap = StrokeCap.round;
}

class ImagePainter extends CustomPainter {
  final ImageInfo? imageInfo;
  final EditImageProviderState editImageProviderState;
  final BuildContext context;

  ImagePainter(this.imageInfo, this.editImageProviderState, this.context);

  @override
  void paint(Canvas canvas, Size size){
    final editImageProvider = Provider.of<EditImageProvider>(context, listen: false);
    double width = editImageProviderState.width;
    double height = editImageProviderState.height;
    List<Offset> points = editImageProviderState.points; 
    double angleInRadians = editImageProviderState.rotationAngle;
    Map toCrop = editImageProviderState.toCrop;
    double left = editImageProviderState.left;
    double top = editImageProviderState.top;
    Size totalImageSize = editImageProviderState.totalImageSize;
    double degrees = radiansToDegrees(angleInRadians);
    final currentPaintColor = Paint()
      ..color = editImageProviderState.selectedPaintColor
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    Rect boundary = Rect.fromLTWH(
      0, 0, totalImageSize.width, totalImageSize.height
    );
    Rect boundary2 = Rect.fromLTWH(0, 0, totalImageSize.width, totalImageSize.height);

    if (imageInfo != null) {
      boundary2 = Rect.fromLTWH(left, top, width, height);
      canvas.save();
      canvas.rotate(angleInRadians);
      canvas.translate(
        degrees == 0 ? 0 : degrees == 90 ? 0 : degrees == 180 ? -width : degrees == 270 ? -width : 0,
        degrees == 0 ? 0 : degrees == 90 ? -height : degrees == 180 ? -height : degrees == 270 ? 0 : 0
      );
      canvas.translate(-left, -top );
      
      if(toCrop.isNotEmpty){
        if(degrees == 0){
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final editImageProvider = Provider.of<EditImageProvider>(context, listen: false);
            editImageProvider.updateLeft(left + toCrop['left']);
            editImageProvider.updateTop(top + toCrop['top'],);
            editImageProvider.updateWidth(toCrop['width']);
            editImageProvider.updateHeight(toCrop['height']);
          });
          boundary2 = Rect.fromLTWH(left + toCrop['left'], top + toCrop['top'], toCrop['width'], toCrop['height']);
        }else if(degrees == 90){
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final editImageProvider = Provider.of<EditImageProvider>(context, listen: false);
            editImageProvider.updateLeft(left + toCrop['top']);
            editImageProvider.updateTop(top + (height - toCrop['width'] - toCrop['left']),);
            editImageProvider.updateWidth(toCrop['height']);
            editImageProvider.updateHeight(toCrop['width']);
          });
          boundary2 = Rect.fromLTWH(left + toCrop['top'], top + (height - toCrop['width'] - toCrop['left']), toCrop['height'], toCrop['width']);
        }else if(degrees == 180){
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final editImageProvider = Provider.of<EditImageProvider>(context, listen: false);
            editImageProvider.updateLeft(left + (width - toCrop['width'] - toCrop['left']));
            editImageProvider.updateTop(top + (height - toCrop['height'] - toCrop['top']),);
            editImageProvider.updateWidth(toCrop['width']);
            editImageProvider.updateHeight(toCrop['height']);
          });
          boundary2 = Rect.fromLTWH(left + (width - toCrop['width'] - toCrop['left']), top + (height - toCrop['height'] - toCrop['top']), toCrop['width'], toCrop['height']);
        }else if(degrees == 270){
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final editImageProvider = Provider.of<EditImageProvider>(context, listen: false);
            editImageProvider.updateLeft(left + (width - toCrop['height'] - toCrop['top']));
            editImageProvider.updateTop(top + (toCrop['left']));
            editImageProvider.updateWidth(toCrop['height']);
            editImageProvider.updateHeight(toCrop['width']);
          });
          boundary2 = Rect.fromLTWH(left + (width - toCrop['height'] - toCrop['top']), top + (toCrop['left']), toCrop['height'], toCrop['width']);
        }  
        WidgetsBinding.instance.addPostFrameCallback((_) {
          editImageProvider.updateToCrop({});
        });
      }

      Path clipPath = Path();
      clipPath.addRect(boundary2);
      canvas.clipPath(clipPath);
      canvas.drawImageRect(
        imageInfo!.image,
        Rect.fromLTRB(0, 0, imageInfo!.image.width.toDouble(), imageInfo!.image.height.toDouble()),
        boundary,
        Paint(),
      );
      List drawingsList = editImageProvider.state.drawingsList;

      for(int i = 0; i < drawingsList.length; i++){
        if(drawingsList[i]['type'] == EditType.paint){
          for(var j = 0; j < drawingsList[i]['data'].length; j++){
            Paint paintColor = generatePaintColor(drawingsList[i]['color']);
            canvas.drawLine(drawingsList[i]['data'][j], drawingsList[i]['data'][j], paintColor);  
            if(drawingsList[i]['data'].length > j + 1){
              canvas.drawLine(drawingsList[i]['data'][j], drawingsList[i]['data'][j + 1], paintColor);
            }else{
              canvas.drawLine(drawingsList[i]['data'][j], drawingsList[i]['data'][j], paintColor);
            }
          }
        }else if(drawingsList[i]['type'] == EditType.addText){
          Map addedText = drawingsList[i]['data'];
          final text = addedText['text'];
          final offset = addedText['offset'];
          final textAngle = addedText['angle'];
          final textSpan = TextSpan(
            text: text,
            style: generateAddTextStyle(16, drawingsList[i]['color'], addedText['bold']),
          );
          final textPainter = TextPainter(
            text: textSpan,
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          canvas.save();
          
          canvas.translate(
            offset.dx, offset.dy
          );
          canvas.rotate(2*pi - textAngle);
          canvas.translate(
            -offset.dx, -offset.dy
          );
          textPainter.paint(canvas, offset);
          canvas.restore();
        }
      }

      for(var j = 0; j < points.length; j++){
        final startPoint = points[j];
        if(startPoint.dx <= width && startPoint.dy <= height){
          canvas.drawLine(points[j], points[j], currentPaintColor);  
          if(points.length > j + 1){   
            final endPoint = points[j + 1];
            if(endPoint.dx <= width && endPoint.dy <= height){
              canvas.drawLine(points[j], points[j + 1], currentPaintColor);
            }else{
              canvas.drawLine(points[j], startPoint, currentPaintColor);  
            }
          }
        }
      }

      canvas.restore();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        editImageProvider.togglePaintState(false);
      });
    }    
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return editImageProviderState.updatePaintState;
  }
}

Size getSizeScale(degrees, width, height, screenWidth, screenHeight){
  double targetWidth = degrees == 0 || degrees == 180 ? screenWidth : screenHeight;
  double targetHeight = degrees == 90 || degrees == 270 ? screenHeight : screenWidth;

  double scaleWidth = targetWidth / width;
  double scaleHeight = targetHeight / height;

  double scale = scaleWidth < scaleHeight ? scaleWidth : scaleHeight;

  double resizedWidth = width * scale;
  double resizedHeight = height * scale;

  return Size(resizedWidth, resizedHeight);
}

double addClockwiseRotation(double radians, double rotationDegrees) {
  double degrees = radiansToDegrees(radians);
  double rotatedDegrees = (degrees + rotationDegrees) % 360;
  double rotatedRadians = rotatedDegrees * (pi / 180);
  return rotatedRadians;
}

TextStyle generateAddTextStyle(double fontSize, Color color, bool setBold){
  return TextStyle(
    fontSize: fontSize, color: color, decoration: TextDecoration.none,
    fontWeight: setBold ? FontWeight.w600 : FontWeight.normal,
  );
}

Future<ImageInfo> loadImageInfoFromFile(File file) {
  final completer = Completer<ImageInfo>();
  final imageProvider = FileImage(file);

  final stream = imageProvider.resolve(ImageConfiguration.empty);
  final listener = ImageStreamListener((info, _) {
    completer.complete(info);
  });

  stream.addListener(listener);

  return completer.future.then((info) {
    stream.removeListener(listener);
    return info;
  });
}

double getScreenHeight(){
  return PlatformDispatcher.instance.views.first.physicalSize.height / PlatformDispatcher.instance.views.first.devicePixelRatio;
}

double getScreenWidth(){
  return PlatformDispatcher.instance.views.first.physicalSize.width / PlatformDispatcher.instance.views.first.devicePixelRatio;
}

double radiansToDegrees(double radians) {
  return radians * (180 / pi);
}

Offset applyPaintRotationTransformation(Offset point, EditImageProvider editImageProvider) {
  double angleInRadians = editImageProvider.state.rotationAngle;
  double width = editImageProvider.state.width;
  double height = editImageProvider.state.height;
  double left = editImageProvider.state.left;
  double top = editImageProvider.state.top;

  if(radiansToDegrees(angleInRadians) == 0){
    return Offset(
      point.dx - (getScreenWidth() - width)/2 + left,
      point.dy - (getScreenHeight() - height)/2 + top
    );
  }else if(radiansToDegrees(angleInRadians) == 90){
    return Offset(
      point.dy - (getScreenHeight() - width)/2 + left,
      height - (point.dx - (getScreenWidth()-height)/2) + top
    );
  }else if(radiansToDegrees(angleInRadians) == 270){
    return Offset(
      width - (point.dy - (getScreenHeight() - width)/2) + left, 
      point.dx - (getScreenWidth() - height)/2 + top
    );
  }else if(radiansToDegrees(angleInRadians) == 180){
    return Offset(
      width - (point.dx - (getScreenWidth()-width)/2) + left,
      height - (point.dy - (getScreenHeight() - height)/2 ) + top
    );
  }

  return point;
}

Offset applyDragTextRotationTransformation(Offset point, EditImageProvider editImageProvider) {
  double angleInRadians = editImageProvider.state.rotationAngle;
  double width = editImageProvider.state.width;
  double height = editImageProvider.state.height;

  if(radiansToDegrees(angleInRadians) == 90){
    return Offset(
      point.dx - (width - height) /2,
      (point.dy) + (width - height)/2
    );
  }else if (radiansToDegrees(angleInRadians) == 270){
    return Offset(
      point.dx - (width - height) /2, 
      point.dy + (width - height)/2
    );
  }

  return point;
}

Offset applyAddTextRotationTransformation(Offset point, EditImageProvider editImageProvider) {
  double angleInRadians = editImageProvider.state.rotationAngle;
  double width = editImageProvider.state.width;
  double height = editImageProvider.state.height;
  double top = editImageProvider.state.top;
  double left = editImageProvider.state.left;

  if (radiansToDegrees(angleInRadians) == 90) {
    return Offset(point.dy + (width - height) / 2 + left, width - point.dx - (width - height) / 2 + top);
  } else if (radiansToDegrees(angleInRadians) == 270) {
    return Offset(height - point.dy + (width - height) / 2 + left, point.dx - (width - height) / 2 + top);
  } else if (radiansToDegrees(angleInRadians) == 180) {
    return Offset(width - point.dx + left, height - point.dy + top);
  }

  return Offset(point.dx + left, point.dy + top);
}

Future<File?> saveUint8ListAsImage(Uint8List imageData) async {
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;
  String uuid = const Uuid().v4();
  String filename = 'image_$uuid.png';
  File tempFile = File('$tempPath/$filename');

  try {
    await tempFile.writeAsBytes(imageData);
    return tempFile;
  } catch (e) {
    return null;
  }
}

class ManipulatingBall extends StatefulWidget {
  const ManipulatingBall({super.key, required this.onDrag, required this.height});

  final double height;
  final Function onDrag;

  @override
  _ManipulatingBallState createState() => _ManipulatingBallState();
}

class _ManipulatingBallState extends State<ManipulatingBall> {
  late double initX;
  late double initY;

  _handleDrag(details) {
    initX = details.globalPosition.dx;
    initY = details.globalPosition.dy;
  }

  _handleUpdate(details) {
    var dx = details.globalPosition.dx - initX;
    var dy = details.globalPosition.dy - initY;
    initX = details.globalPosition.dx;
    initY = details.globalPosition.dy;
    widget.onDrag(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handleDrag,
      onPanUpdate: _handleUpdate,
      child: Container(
        width: ballDiameter,
        height: ballDiameter,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('initX', initX));
  }
}