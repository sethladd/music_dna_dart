library music_dna;

import 'dart:async' show Future;
import 'dart:typed_data' show TypedData, Uint8List;
import 'dart:web_audio'
  show AnalyserNode, AudioBuffer, AudioBufferSourceNode, AudioContext, GainNode;

import 'dart:math' show log, PI, min, max, sin, cos, round, Random;
import 'dart:html'
  show CanvasElement, CanvasRenderingContext2D, querySelector, window;

part 'src/audio_parser.dart';
part 'src/audio_renderer.dart';