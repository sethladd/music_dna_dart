/**
 * Copyright 2014 Google Inc. All Rights Reserved.
 * For licensing see http://lab.aerotwist.com/canvas/music-dna/LICENSE
 */

import 'package:music_dna/music_dna.dart';

import 'dart:typed_data' show Uint8List;
import 'dart:html'
  show Blob, Element, FileReader, ProgressEvent, document, window, querySelector;
import 'dart:async' show Future;
import 'dart:web_audio' show AudioBuffer;

class MusicDNA {

  static final int DATA_SIZE = 1024;

  AudioParser audioParser;
  AudioRenderer audioRenderer;
  Uint8List audioData;
  double audioDuration = 1.0;
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

  void updateAndRender(num t) {
    audioParser.getAnalyserAudioData(audioData);
    audioTime = audioParser.time / audioDuration;

    if (audioPlaying) {
      audioRenderer.render(audioData, audioTime);
      time.style.width = (audioTime * 100).toStringAsFixed(1) + '%';
    }

    window.animationFrame.then(updateAndRender);
  }

  Future parse(Blob file) {
    var fileReader = new FileReader();
    fileReader.readAsArrayBuffer(file);
    
    return fileReader.onLoadEnd.first.then((ProgressEvent evt) {
      var reader = evt.target as FileReader;
      return audioParser.parseArrayBuffer(reader.result);
    }).then((AudioBuffer buffer) {
      audioDuration = buffer.duration;
      audioPlaying = true;
      audioRenderer.clear();
    });
  }
}