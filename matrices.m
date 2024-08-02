% This calculates the matrices for converting color spaces.
% It derives the matrices from known color conversions.

p3Colors = [
  1, 0, 0, 0.25;
  0, 1, 0, 0.5;
  0, 0, 1, 0.75;
  1, 1, 1, 1;
]
srgbColors = [
  1.0930908918380737,  -0.5116420984268188, -0.0003518527664709836, 0.12397786229848862;
  -0.22684034705162048, 1.0182716846466064,  0.00027732315356843174,  0.5073589086532593;
  -0.15007957816123962, -0.31062406301498413, 1.0420056581497192,  0.771118700504303;
  1,       1,       1,       1;
]

p3ToSrgb = srgbColors * inv(p3Colors)

inv(p3ToSrgb)