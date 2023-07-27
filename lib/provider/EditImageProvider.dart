import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum EditType{
  none,
  crop,
  paint,
  rotate,
  addText
}

class EditImageProviderState extends ChangeNotifier {
  double rotationAngle;
  double width;
  double height;
  double top;
  double left;
  List<Offset> points;
  Map toCrop;
  EditType selectedEditType;
  Size totalImageSize;
  List drawingsList;
  Color selectedPaintColor;
  Color selectedAddTextColor;
  bool updatePaintState;

  EditImageProviderState({
    required this.rotationAngle,
    required this.width,
    required this.height,
    required this.top,
    required this.left,
    required this.points,
    required this.toCrop,
    required this.selectedEditType,
    required this.totalImageSize,
    required this.drawingsList,
    required this.selectedPaintColor,
    required this.selectedAddTextColor,
    required this.updatePaintState
  });
}

class EditImageProvider with ChangeNotifier {
  late EditImageProviderState _state;
  ImageInfo? _imageInfoFuture;

  ImageInfo? get imageInfoFuture => _imageInfoFuture;

  EditImageProvider() {
    _state = EditImageProviderState(
      rotationAngle: 0.0, width: 0.0, height: 0.0, top: 0.0, 
      left: 0.0, points: [], toCrop: {}, selectedEditType: EditType.none, 
      totalImageSize: Size(0, 0), drawingsList: [], selectedAddTextColor: Colors.black, selectedPaintColor: Colors.black,
      updatePaintState: false
    );
  }

  void updateImageInfo(ImageInfo? imageInfo){
    _imageInfoFuture = imageInfo;
    _state.width = imageInfo!.image.width.toDouble();
    _state.height = imageInfo.image.height.toDouble();
    notifyListeners();
  }

  EditImageProviderState get state => _state;

  void updateRotationAngle(double newValue) {
    _state.rotationAngle = newValue;
    notifyListeners();
  }

  void updateWidth(double newValue) {
    _state.width = newValue.toDouble();
    notifyListeners();
  }

  void updateHeight(double newValue) {
    _state.height = newValue.toDouble();
    notifyListeners();
  }
  void addLatestPoints(Offset newValue) {
    _state.points.add(newValue);
    notifyListeners();
  }

  void clearPoints() {
    _state.points = [];
    notifyListeners();
  }

  void updateToCrop(Map newValue) {
    _state.toCrop = newValue;
    notifyListeners();
  }

  void updateTop(double newValue){
    _state.top = newValue.toDouble();
    notifyListeners();
  }

  void updateLeft(double newValue){
    _state.left = newValue.toDouble();
    notifyListeners();
  }

  void updateSelectedEditType(EditType newValue){
    _state.selectedEditType = newValue;
    notifyListeners();
  }
  void updateTotalImageSize(double width, double height){
    _state.totalImageSize = Size(width, height);
    notifyListeners();
  }

  void updateDrawingsList(newValue){
    _state.drawingsList.add({
      'data': newValue,
      'type': _state.selectedEditType,
      'color': _state.selectedEditType == EditType.paint ? _state.selectedPaintColor : _state.selectedAddTextColor
    });
    notifyListeners();
  }

  void updatePaintColor(Color newValue){
    _state.selectedPaintColor = newValue;
    notifyListeners();
  }

  void updateAddTextColor(Color newValue){
    _state.selectedAddTextColor = newValue;
    notifyListeners();
  }

  void togglePaintState(bool newValue){
    _state.updatePaintState = newValue;
    notifyListeners();
  }
  
}