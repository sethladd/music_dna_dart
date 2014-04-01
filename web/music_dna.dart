/**
 * Copyright 2014 Google Inc. All Rights Reserved.
 * For licensing see http://lab.aerotwist.com/canvas/music-dna/LICENSE
 */

import 'package:music_dna/music_dna.dart';

import 'dart:typed_data' show Uint8List;
import 'dart:html'
  show Blob, Element, FileReader, ProgressEvent, document, window, querySelector;
import 'dart:async' show Future;

class MusicDNA {

  static final int DATA_SIZE = 1024;

  AudioParser audioParser;
  AudioRenderer audioRenderer;
  Uint8List audioData;
  int audioDuration = 1;
  double audioTime = 0.0;
  bool audioPlaying = false;
  Element time;
  
  MusicDNA() {
    audioData = new Uint8List(DATA_SIZE);
    audioRenderer = new AudioRenderer();
    audioParser = new AudioParser(DATA_SIZE);
    time = querySelector('#time');
    window.animationFrame.then(updateAndRender);
  }

  Future onFileRead(FileReader reader) {
    return audioParser.parseArrayBuffer(reader.result).then(onAudioDataParsed);
  }

  void onAudioDataParsed(buffer) {
    audioDuration = buffer.duration;
    audioPlaying = true;

    audioRenderer.clear();
  }

  void updateAndRender(num t) {
    audioParser.getAnalyserAudioData(audioData);
    audioTime = audioParser.time / audioDuration;

    if (audioPlaying) {
      audioRenderer.render(audioData, audioTime);
      time.style.width = (audioTime * 100).toStringAsFixed(1) + '%';
    }

    window.animationFrame.then(updateAndRender);
  }

  void parse(Blob file) {
    var fileReader = new FileReader();
    fileReader.onLoadEnd.listen((_) => onFileRead(fileReader));
    fileReader.readAsArrayBuffer(file);
  }
}