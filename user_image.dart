import 'dart:io';
import 'dart:js';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';

class userImagePicker extends StatelessWidget {
  PlatformFile? pickedFile;
  UploadTask? uploadTask;

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles;
    if (result == null) return;
  }

  Future uploadFile() async {
    final path = 'files/${pickedFile!.name}';
    final file = File(pickedFile!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);
    uploadTask = ref.putFile(file);

    final snapshot = await uploadTask!.whenComplete(() {});

    final urlDownload = await snapshot.ref.getDownloadURL();
    print('Download Link: $urlDownload');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (pickedFile != null)
          Expanded(
              child: Container(
            color: Colors.blue[100],
            child: Center(
              child: Image.file(
                File(pickedFile!.path!),
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          )),
        const SizedBox(
          height: 24,
        ),
        TextButton(
          onPressed: () {}, //selectFile
          child: Row(
            children: [
              Icon(
                Icons.image,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(
                width: 10,
              ),
              const Text('Selecionar imagem')
            ],
          ),
        ),
        TextButton(
          onPressed: () {}, //uploadFile
          child: Row(
            children: [
              Icon(
                Icons.save,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(
                width: 10,
              ),
              const Text('Salvar imagem')
            ],
          ),
        ),
        const SizedBox(
          height: 40,
        ),
        buildProgress(),
      ],
    );
  }

  Widget buildProgress() => StreamBuilder<TaskSnapshot>(
        stream: uploadTask?.snapshotEvents,
        builder: (context, snaphot) {
          if (snaphot.hasData) {
            final data = snaphot.data!;
            double progress = data.bytesTransferred / data.totalBytes;

            return SizedBox(
              height: 50,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey,
                    color: Color.fromRGBO(50, 205, 50, 1),
                  ),
                  Center(
                    child: Text(
                      '${(100 * progress).roundToDouble()}%',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const SizedBox(height: 50);
          }
        },
      );
}


// https://console.firebase.google.com/u/0/project/imagemperfil-92b76/storage/imagemperfil-92b76.appspot.com/files/~2F?hl=pt-br
// https://www.youtube.com/watch?v=3x92z0oHbtY
