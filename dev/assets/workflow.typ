#import "@preview/cetz:0.4.2"
#set page(width: auto, height: auto, margin: 0pt)
#[
#context cetz.canvas(length: 1pt, {
  import cetz.draw: *
  rect((0, 0), (620.0, -200.0), fill: rgb("#FFFFFF"), stroke: none)
  rect((30.0, -45.0), (170.0, -155.0), fill: rgb("#EEF7F9"), stroke: (paint: rgb("#2879A0"), thickness: 2.8pt, cap: "round", join: "round"), radius: 15.0)
  content((53.0, -97.68), text(size: 38.0pt, fill: rgb("#2879A0"), weight: "bold", top-edge: "cap-height", bottom-edge: "baseline", "D"), anchor: "base-west", padding: 0)
  content((53.0, -134.56), text(size: 21.0pt, fill: rgb("#172630"), top-edge: "cap-height", bottom-edge: "baseline", "Draft"), anchor: "base-west", padding: 0)
  rect((240.0, -45.0), (380.0, -155.0), fill: rgb("#F1F7F3"), stroke: (paint: rgb("#427E68"), thickness: 2.8pt, cap: "round", join: "round"), radius: 15.0)
  content((263.0, -97.68), text(size: 38.0pt, fill: rgb("#427E68"), weight: "bold", top-edge: "cap-height", bottom-edge: "baseline", "R"), anchor: "base-west", padding: 0)
  content((263.0, -134.56), text(size: 21.0pt, fill: rgb("#172630"), top-edge: "cap-height", bottom-edge: "baseline", "Review"), anchor: "base-west", padding: 0)
  rect((450.0, -45.0), (590.0, -155.0), fill: rgb("#F7F3ED"), stroke: (paint: rgb("#A76A32"), thickness: 2.8pt, cap: "round", join: "round"), radius: 15.0)
  content((473.0, -97.68), text(size: 38.0pt, fill: rgb("#A76A32"), weight: "bold", top-edge: "cap-height", bottom-edge: "baseline", "P"), anchor: "base-west", padding: 0)
  content((473.0, -134.56), text(size: 21.0pt, fill: rgb("#172630"), top-edge: "cap-height", bottom-edge: "baseline", "Published"), anchor: "base-west", padding: 0)
  line((180.0, -100.0), (221.55, -100.0), fill: none, stroke: (paint: rgb("#2879A0"), thickness: 5.0pt, cap: "round", join: "round"))
  line((230.0, -100.0), (217.0, -105.59), (217.0, -94.41), close: true, fill: rgb("#2879A0"), stroke: (paint: rgb("#2879A0"), thickness: 1.0pt, cap: "round", join: "round"))
  line((390.0, -100.0), (431.55, -100.0), fill: none, stroke: (paint: rgb("#427E68"), thickness: 5.0pt, cap: "round", join: "round"))
  line((440.0, -100.0), (427.0, -105.59), (427.0, -94.41), close: true, fill: rgb("#427E68"), stroke: (paint: rgb("#427E68"), thickness: 1.0pt, cap: "round", join: "round"))
})
]
