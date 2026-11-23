#import "@preview/cetz:0.4.2"
#set page(width: auto, height: auto, margin: 0pt)
#[
#context cetz.canvas(length: 1pt, {
  import cetz.draw: *
  rect((0, 0), (900.0, -390.0), fill: rgb("#FFFFFF"), stroke: none)
  content((70.0, -53.08), text(size: 28.0pt, fill: rgb("#172630"), weight: "bold", top-edge: "cap-height", bottom-edge: "baseline", "DOCUMENT WORKFLOW"), anchor: "base-west", padding: 0)
  line((70.0, -76.0), (830.0, -76.0), fill: none, stroke: (paint: rgb("#D5DEE1"), thickness: 2.0pt, cap: "round", join: "round"))
  content((70.0, -158.76), text(size: 16.0pt, fill: rgb("#53636C"), weight: "bold", top-edge: "cap-height", bottom-edge: "baseline", "LATENT STATE"), anchor: "base-west", padding: 0)
  rect((70.0, -180.0), (270.0, -292.0), fill: rgb("#EEF7F9"), stroke: (paint: rgb("#2879A0"), thickness: 2.8pt, cap: "round", join: "round"), radius: 15.0)
  content((93.0, -232.68), text(size: 38.0pt, fill: rgb("#2879A0"), weight: "bold", top-edge: "cap-height", bottom-edge: "baseline", "D"), anchor: "base-west", padding: 0)
  content((93.0, -269.56), text(size: 21.0pt, fill: rgb("#172630"), top-edge: "cap-height", bottom-edge: "baseline", "Draft"), anchor: "base-west", padding: 0)
  rect((350.0, -180.0), (550.0, -292.0), fill: rgb("#F1F7F3"), stroke: (paint: rgb("#427E68"), thickness: 2.8pt, cap: "round", join: "round"), radius: 15.0)
  content((373.0, -232.68), text(size: 38.0pt, fill: rgb("#427E68"), weight: "bold", top-edge: "cap-height", bottom-edge: "baseline", "R"), anchor: "base-west", padding: 0)
  content((373.0, -269.56), text(size: 21.0pt, fill: rgb("#172630"), top-edge: "cap-height", bottom-edge: "baseline", "Review"), anchor: "base-west", padding: 0)
  rect((630.0, -180.0), (830.0, -292.0), fill: rgb("#EDF3FA"), stroke: (paint: rgb("#356CAA"), thickness: 2.8pt, cap: "round", join: "round"), radius: 15.0)
  content((653.0, -232.68), text(size: 38.0pt, fill: rgb("#356CAA"), weight: "bold", top-edge: "cap-height", bottom-edge: "baseline", "P"), anchor: "base-west", padding: 0)
  content((653.0, -269.56), text(size: 21.0pt, fill: rgb("#172630"), top-edge: "cap-height", bottom-edge: "baseline", "Published"), anchor: "base-west", padding: 0)
  line((278.0, -236.0), (333.55, -236.0), fill: none, stroke: (paint: rgb("#2879A0"), thickness: 5.2pt, cap: "round", join: "round"))
  line((342.0, -236.0), (329.0, -241.59), (329.0, -230.41), close: true, fill: rgb("#2879A0"), stroke: (paint: rgb("#2879A0"), thickness: 1.0pt, cap: "round", join: "round"))
  content((310.0, -211.12), text(size: 17.0pt, fill: rgb("#172630"), weight: "bold", top-edge: "cap-height", bottom-edge: "baseline", "submit"), anchor: "base", padding: 0)
  content((310.0, -275.12), text(size: 17.0pt, fill: rgb("#53636C"), top-edge: "cap-height", bottom-edge: "baseline", "p_submit"), anchor: "base", padding: 0)
  line((558.0, -236.0), (613.55, -236.0), fill: none, stroke: (paint: rgb("#427E68"), thickness: 5.2pt, cap: "round", join: "round"))
  line((622.0, -236.0), (609.0, -241.59), (609.0, -230.41), close: true, fill: rgb("#427E68"), stroke: (paint: rgb("#427E68"), thickness: 1.0pt, cap: "round", join: "round"))
  content((590.0, -211.12), text(size: 17.0pt, fill: rgb("#172630"), weight: "bold", top-edge: "cap-height", bottom-edge: "baseline", "approve"), anchor: "base", padding: 0)
  content((590.0, -275.12), text(size: 17.0pt, fill: rgb("#53636C"), top-edge: "cap-height", bottom-edge: "baseline", "p_accept"), anchor: "base", padding: 0)
})
]
