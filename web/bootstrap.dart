/**
 * Copyright 2014 Google Inc. All Rights Reserved.
 * For licensing see http://lab.aerotwist.com/canvas/music-dna/LICENSE
 */

import 'music_dna.dart';
import 'dart:html';
import 'dart:js' as js;

main() {

  var musicDNA = new MusicDNA();
  var fileDropArea = querySelector('#file-drop-area');
  var artist = querySelector('#artist');
  var track = querySelector('#track');
  var fileUploadForm = querySelector('#file-chooser');
  var fileInput = querySelector('#source-file');
  var ID3 = js.context['ID3'];
  
  js.context['loadTagsCallback'] = () {
    var tags = ID3.callMethod('getAllTags', ["filename.mp3"]);
    if (tags.artist != null) {
      artist.text = tags.artist;
    }
    if (tags.title != null) {
      track.text = tags.title;
    }
  };

  void go(Blob file) {
    musicDNA.parse(file);
    fileDropArea.classes.add('dropped');
    
    var id3FileReader = new js.JsObject(js.context['FileAPIReader'], [file]);

    ID3.callMethod('loadTags', ["filename.mp3", js.context['loadTagsCallback'],
                                new js.JsObject.jsify({'dataReader': id3FileReader})
                               ]);
  }

  void onSubmit(Event evt) {
    evt.preventDefault();
    evt.stopImmediatePropagation();

    if (fileInput.files.length > 0)
      go(fileInput.files[0]);
  }

  void cancel(Event evt) {
    evt.preventDefault();
  }

  void dropFile(Event evt) {
    evt.stopPropagation();
    evt.preventDefault();

    var files = evt.dataTransfer.files;

    if (files.length > 0) {
      go(files[0]);
    }
  }
  
  fileDropArea
    ..onDrop.listen(dropFile)
    ..onDragOver.listen(cancel)
    ..onDragLeave.listen(cancel)
    ..onSubmit.listen(onSubmit);
}