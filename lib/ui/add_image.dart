import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AddImage extends StatefulWidget {
  const AddImage({super.key});

  @override
  State<AddImage> createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {

  Future<Uint8List> testComporessList(Uint8List list) async {
    var result = await FlutterImageCompress.compressWithList(
      list,
      quality: 70,
    );

    return result;
  }

  Future<Uint8List?> downloadImage(String? url) async {
    if (url == null || url.trim() == '') return null;

    try {
      var r = await http.get(Uri.parse(url));

      if(r.statusCode != 200) return null;

      return await testComporessList(r.bodyBytes);
    } catch (e) {
      print(e);
      rethrow;
      return null;
    }
  }

  Future<String> saveImage(Uint8List data, String name) async {
    final reference = FirebaseStorage.instance.ref().child(name);
    var metadata = SettableMetadata(
      contentType: "image/jpeg",
    );

    final taskSnapshot = await reference.putData(data, metadata);

    final url = await taskSnapshot.ref.getDownloadURL();
    print("URL: $url");

    return url;
  }

  TextEditingController imageurl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [ElevatedButton(onPressed: () {}, child: Text('Upload'))],
      ),
      body:  Center(
                    child: Column(
                      children: [
                        TextField(
                          controller: imageurl,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () async {
                            var imageBytes =
                                await downloadImage(imageurl.text.trim());
                            if (imageBytes == null) {
                              print("CANNOT GET IMAGE");
                              return;
                            }
                            var imageName = DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString() +
                                "-image.jpg"
                                ;
                            var imageNewUrl =
                                await saveImage(imageBytes, imageName);
                            print("DONE WITH IMAGE" + imageNewUrl);
                          },
                        ),
                      ],
                    ),
    ));
  }
}
