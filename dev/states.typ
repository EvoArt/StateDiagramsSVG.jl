#import "@preview/cetz:0.4.2"
#set page(width: auto, height: auto, margin: 0pt)
#[
#context cetz.canvas(length: 1pt, {
  import cetz.draw: *
  rect((0, 0), (340.0, -110.0), fill: rgb("#FFFFFF"), stroke: none)
  rect((10.0, -5.0), (150.0, -105.0), fill: rgb("#EEF7F9"), stroke: (paint: rgb("#2879A0"), thickness: 2.8pt, cap: "round", join: "round"), radius: 15.0)
  content((33.0, -57.68), text(size: 38.0pt, fill: rgb("#2879A0"), weight: "bold", top-edge: "cap-height", bottom-edge: "baseline", "A"), anchor: "base-west", padding: 0)
  content((33.0, -94.56), text(size: 21.0pt, fill: rgb("#172630"), top-edge: "cap-height", bottom-edge: "baseline", "Waiting"), anchor: "base-west", padding: 0)
  rect((190.0, -5.0), (330.0, -105.0), fill: rgb("#F1F7F3"), stroke: (paint: rgb("#427E68"), thickness: 2.8pt, cap: "round", join: "round"), radius: 15.0)
  content((213.0, -57.68), text(size: 38.0pt, fill: rgb("#427E68"), weight: "bold", top-edge: "cap-height", bottom-edge: "baseline", "B"), anchor: "base-west", padding: 0)
  content((213.0, -94.56), text(size: 21.0pt, fill: rgb("#172630"), top-edge: "cap-height", bottom-edge: "baseline", "Ready"), anchor: "base-west", padding: 0)
  line((160.0, -55.0), (171.55, -55.0), fill: none, stroke: (paint: rgb("#2879A0"), thickness: 4.5pt, cap: "round", join: "round"))
  line((180.0, -55.0), (167.0, -60.59), (167.0, -49.41), close: true, fill: rgb("#2879A0"), stroke: (paint: rgb("#2879A0"), thickness: 1.0pt, cap: "round", join: "round"))
})
]
