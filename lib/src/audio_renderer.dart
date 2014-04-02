/**
 * Copyright 2014 Google Inc. All Rights Reserved.
 * For licensing see http://lab.aerotwist.com/canvas/music-dna/LICENSE
 */

part of music_dna;

class AudioRenderer {

  static final double LOG_MAX = log(128);
  static final double TAU = PI * 2;
  static final double MAX_DOT_SIZE = 0.5;
  static final double BASE = log(4) / LOG_MAX;

  CanvasElement canvas;
  CanvasRenderingContext2D ctx;

  int width = 0;
  int height = 0;
  double outerRadius = 0.0;

  final Random _random = new Random();

  AudioRenderer() {
    canvas = querySelector('#render-area');
    ctx = canvas.context2D;

    window
      ..onResize.listen((_) => onResize())
      ..onLoad.first.then((_) => onResize());
  }

  double random() => _random.nextDouble();

  void onResize() {
    width = canvas.offsetWidth;
    height = canvas.offsetHeight;

    canvas
      ..width = width
      ..height = height;

    outerRadius = min(width, height) * 0.47;

    ctx.globalCompositeOperation = "lighter";
  }

  num clamp(val, min, max) => min(max, max(val, min));

  void clear() {
    ctx.clearRect(0, 0, width, height);
  }

  void render(audioData, normalizedPosition) {
    var angle = PI - normalizedPosition * TAU;
    var color = 0;
    var lnDataDistance = 0;
    var distance = 0;
    var size = 0;
    var volume = 0;
    var power = 0;

    var x = sin(angle);
    var y = cos(angle);
    var midX = width * 0.5;
    var midY = height * 0.5;

    // There is so much number hackery in here.
    // Number fishing is HOW YOU WIN AT LIFE.

    for (var a = 16; a < audioData.length; a++) {

      volume = audioData[a] / 255;

      if (volume < 0.75)
        continue;

      color = normalizedPosition - 0.12 + random() * 0.24;
      color = (color * 360).round();

      lnDataDistance = (log(a - 4) / LOG_MAX) - BASE;

      distance = lnDataDistance * outerRadius;
      size = volume * MAX_DOT_SIZE + random() * 2;

      if (random() > 0.995) {
        size *= (audioData[a] * 0.2) * random();
        volume *= random() * 0.25;
      }

      ctx
        ..globalAlpha = volume * 0.09
        ..fillStyle = 'hsl($color, 80%, 50%)'
        ..beginPath()
        ..arc(midX + x * distance, midY + y * distance, size, 0, TAU, false)
        ..closePath()
        ..fill();
    }
  }
}