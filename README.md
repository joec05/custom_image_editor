# Custom Image Editor

Strong image editor based on Flutter with ability to crop, paint, add text, and rotate images.

## Features

* Crop

* Add text, with options to bold the text and choose a color for the text

* Paint, with options to choose a color for the lines

* Rotate by 90 degrees clockwise

## Custom image editor in display  

### Crop
![](https://github.com/joec05/files/blob/aec89a406e8a7ddaf79f7f79e738d9a203a3e276/custom_image_editor/crop.gif?raw=true)

<br />

### Rotate

![](https://github.com/joec05/files/blob/main/custom_image_editor/rotate.gif?raw=true)

<br />

### Paint

![](https://github.com/joec05/files/blob/main/custom_image_editor/paint.gif?raw=true)

<br />

### Add text

![](https://github.com/joec05/files/blob/main/custom_image_editor/add%20text.gif?raw=true)

<br />

## How to use this package

In order to start editing the image,

```dart
Future<void> editImage(File imageFile) async {
    //navigate to the image editor
    final fileResult = await Navigator.push(context, MaterialPageRoute(builder: (context) {
        return EditImageComponent(imageFile: imageFile);
    }));
    if (fileResult != null && fileResult is FinishedImageData) {
        String file = fileResult.file.path; //file path of the newly updated image
        imageLink.value = file;
        //get the size of the newly updated image
        width.value = fileResult.size.width;
        height.value = fileResult.size.height;
    }
}```

