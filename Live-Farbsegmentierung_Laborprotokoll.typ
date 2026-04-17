#set document(
  title: [Live-Farbsegmentierung im Kamerabild Laborprotokoll],
  author: "Paul Seelig",
  description: "Laborprotokoll",
)

#let current-chapter-title() =  context{
  // Title top
  set text(10pt)
  place(top + center, {
    if query(heading.where(level: 1))
    .find(h => h.location().page() == here().page()) == none {
      // Filter headers that come after the current page
      let smh = query(heading.where(level: 1)).filter(h => h.location().page() <= here().page())
      smh.last().body // last element in array is newest level 1 headline
    } else {
      none
    }
  }, dy: 1.25cm)
}

#set page(
  paper: "a4",
  margin: (left: 3cm, rest: 2.5cm)
)

#set text(
  font: "Arial",
  size: 10pt,
  hyphenate: true,
  lang: "de"
)

#set par(
  leading: 1.0em, //zwischen 1.0 -1.5
  justify: true,
)

#set highlight(fill: gray)

#set page(numbering: none)

#show figure.where(
  kind: table
): set figure.caption(position: top)

#show figure: set block(breakable: true)
//Deckblatt
#align(center)[
    
    #image("HTW_Berlin_Logo.jpg")
    
    #line(length: 100%)

    #set text(size: 18pt)
    #text(fill: green)[#heading(level: 1, outlined: false)[
        Live-Farbsegmentierung im \ Kamerabild
    ]]

    #line(length: 100%)
    \
    #text(size: 16pt)[Laborprotokoll] \
    \
    #text(size: 12pt)[Name des Studienganges]
    \
    Computerengineering \
    #text(fill: green)[Fachbereich 1] \
    #text(size: 12pt)[vorgelegt von] \
    Paul Seelig \
    \
    #text(size: 12pt)[Datum:] \
    #text(size: 14pt)[Berlin, 13.04.2026]
  ]
#pagebreak()

#set page(numbering: "I")
#counter(page).update(1)

#outline(
  title: [Inhaltsverzeichnis],
  depth: 2
)

#pagebreak()

#set heading(numbering: "1.")

#set page(
  numbering: "1 / 1",
  header: current-chapter-title()
)

= Ziel
Das Ziel der Übung war es die Aufnahme einer Webcam oder Kamera, während der Laufzeit des Programmes in den HSV-Farbraum zu konvertieren und diesen ggf. per Schieberegler zu kontrolieren.
Hierfür wird die Bildverarbeitungsbibliothek Opencv verwendet, die Python implementation. @opencv_library
= Ablauf
Zuerst soll die Webcam vom Programm erkannt und weiterverarbeitet werden.
Hierzu wird in der Funktion #raw("cv2.VideoCapture(0)",lang: "python") die Webcam erkannt und in die Variable #raw("cap",lang: "python") gelesen.\ Danach wird in einer Schleife die Kamera ausgelesen #raw("cap.read()",lang: "python") und in die Variablen #raw("ret, img",lang: "python") gelesen.\
Um aus der Schleife auszutreten muss der Knopf #highlight("q") für Quit gedrückt werden. Das führt dazu das die Fenster sich schließen und die Kamera nicht mehr aktiv sendet.
#raw(
  "
cap = cv2.VideoCapture(0)
...
  while(1):
    ret, img = cap.read()
    ...

    if cv2.waitKey(1) & 0xFF == ord(\"q\"):
      break

cap.release()
cv2.destroyAllWindows()
",
  lang: "python",
  tab-size: 8
) 

- Konvertiere jedes Frame in den HSV-Farbraum (cv2.cvtColor). @OpenCV_Tutorial
#raw(
  "
  hsv = cv2.cvtColor(img, cv2.COLOR_RGB2HSV)
  ",
  lang: "python"
)
- Nutze cv2.createTrackbar, um die HSV-Schwellwerte zur Laufzeit per Schieberegler einzustellen. So kannst du interaktiv die passenden Werte für verschiedene Farben finden.

#raw(
  "
    # Create windows
    cv2.namedWindow('HSV')
    cv2.namedWindow('Regler')

    # Create trackbars ONCE (outside the loop) 
    # Taken from my previously submitted python file
    cv2.createTrackbar('Hue_lower', 'Regler', 0, 179, lambda x: None) 
    cv2.createTrackbar('Saturation_lower', 'Regler', 0, 255, lambda x: None)
    cv2.createTrackbar('Value_lower', 'Regler', 0, 255, lambda x: None)

    cv2.createTrackbar('Hue_upper', 'Regler', 170, 179, lambda x: None) 
    cv2.createTrackbar('Saturation_upper', 'Regler', 255, 255, lambda x: None)
    cv2.createTrackbar('Value_upper', 'Regler', 255, 255, lambda x: None)

    ...
    while(1):
      ...
      Hue_L = cv2.getTrackbarPos('Hue_lower', 'Regler')
      Saturation_L = cv2.getTrackbarPos('Saturation_lower', 'Regler')
      Value_L = cv2.getTrackbarPos('Value_lower', 'Regler')

      Hue_U = cv2.getTrackbarPos('Hue_upper', 'Regler')
      Saturation_U = cv2.getTrackbarPos('Saturation_upper', 'Regler')
      Value_U = cv2.getTrackbarPos('Value_upper', 'Regler')
  ",
  lang: "python"
)

- Erzeuge mit cv2.inRange eine binäre Maske, die nur Pixel im gewählten Farbbereich enthält.
#raw(
  "
  mask = cv2.inRange(hsv, lower, upper)
  ",
  lang: "python"
)

- Wende die Maske auf das Originalbild an (cv2.bitwise_and), sodass nur die segmentierten Bereiche sichtbar sind.
#raw(
  "
  res = cv2.bitwise_and(img,img, mask= mask)
  ",
  lang: "python"
)
#pagebreak()
- Zeige das Originalbild, die Maske und das gefilterte Ergebnis nebeneinander an.
#raw(
  "
  cv2.imshow('frame',img)
  cv2.imshow('mask',mask)
  cv2.imshow('HSV',res)
  ",
  lang: "python"
)
#grid(rows: 2, columns: 2, 
grid.cell(colspan: 2, align: center, image("Live farmsegmentierung/Default.png", width: 50%, fit: "contain")),
grid.cell(image("Live farmsegmentierung/HSV.png", width: 100%, fit: "contain")),
grid.cell(image("Live farmsegmentierung/Mask.png", width: 100%, fit: "contain"))
)
#pagebreak()
- Ein Gaußfilter (cv2.GaussianBlur) vor der Farbsegmentierung kann helfen, Rauschen zu reduzieren
#raw(
  "
  blur = cv2.GaussianBlur(img, (15, 15), 0) 
  hsv = cv2.cvtColor(blur, cv2.COLOR_RGB2HSV)
  ",
  lang: "python"
)
#grid(rows: 2, columns: 2, 
grid.cell(colspan: 2, align: center,image("Live farmsegmentierung/Default.png", width: 50%)),
grid.cell(image("Live farmsegmentierung/HSV_w_Blur.png")),
grid.cell(image("Live farmsegmentierung/Mask_w_blur.png")))
= Zusammenfassung

= Literatur

#bibliography(
  ("Citing.bib"),
  style: "ieee",
  title: none
) 