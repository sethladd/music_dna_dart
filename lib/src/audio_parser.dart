/**
 * Copyright 2014 Google Inc. All Rights Reserved.
 * For licensing see http://lab.aerotwist.com/canvas/music-dna/LICENSE
 */

part of music_dna;

class AudioParser {

  AudioContext audioContext;
  AnalyserNode analyser;
  GainNode gainNode;
  AudioBufferSourceNode sourceNode;
  var audioRenderer = null;
  Function audioDecodedCallback = null;
  int timePlaybackStarted = 0;
  
  AudioParser(int dataSize) {
    audioContext = new AudioContext();
    analyser = audioContext.createAnalyser();
    gainNode = audioContext.createGain();
    analyser.smoothingTimeConstant = 0.2;
    analyser.fftSize = dataSize;
    gainNode.gain.value = 0.5;
  }

  void onDecodeData (buffer) {

    // Kill any existing audio
    if (sourceNode != null) {
      if (sourceNode.playbackState == AudioBufferSourceNode.PLAYING_STATE)
        sourceNode.stop();
      sourceNode = null;
    }

    // Make a new source
    if (sourceNode == null) {

      sourceNode = audioContext.createBufferSource();
      sourceNode.loop = false;

      sourceNode.connectNode(gainNode);
      gainNode.connectNode(analyser);
      analyser.connectNode(audioContext.destination);
    }

    // Set it up and play it
    sourceNode.buffer = buffer;
    sourceNode.start();

    timePlaybackStarted = new DateTime.now().millisecondsSinceEpoch;

    audioDecodedCallback(buffer);

  }

  void getAnalyserAudioData(Uint8List arrayBuffer) {
    analyser.getByteFrequencyData(arrayBuffer);
  }

  Future parseArrayBuffer(ByteBuffer arrayBuffer) {
    return audioContext.decodeAudioData(arrayBuffer).then(audioDecodedCallback);
  }

  double get time {
    return (new DateTime.now().millisecondsSinceEpoch - timePlaybackStarted) * 0.001;
  }

}