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
Das Ziel der Übung war es die Aufnahme einer Webcam oder Kamera, während der Laufzeit des Programmes die Belichtungszeit, den ISO Wert und die Helligkeit auszulesen und die Belichtungszeit per +/- zu verändern.
Zusätzlich sollte ein Hoizontaler Motion-Blur-Filter erzeugt werden un auf das Bild angewandt werden. 
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

      key = cv2.waitKey(1) & 0xFF
      # Wait for q key to stop
      if key == ord(\"q\"):
          break

  cap.release()
  cv2.destroyAllWindows()
",
  lang: "python",
  tab-size: 8
) 

Danach wurden der aktuelle Belichtungszeit wert ausgelesen um diesen später zu verändern.
#raw(
  "
  exposure = cap.get(cv2.CAP_PROP_EXPOSURE)
  ",
  lang: "python"
)

Die Belichtungszeit änderung wurde wie folgt implementiert:
#raw(
  "
      if  key == ord(\"+\"):
            exposure += 1
            cap.set(cv2.CAP_PROP_EXPOSURE, exposure)
      if key == ord(\"-\"):
            exposure -= 1
            cap.set(cv2.CAP_PROP_EXPOSURE, exposure)
      
      print(\"Camera Exposure: {}\".format(exposure))
      print(\"Camera ISO: {}\".format(cap.get(cv2.CAP_PROP_GAIN)))
      print(\"Camera Brightness: {}\".format(cap.get(cv2.CAP_PROP_BRIGHTNESS)))
",
  lang: "python"
)
Die Belichtungszeit nimmt in meinem fall Werte von -10 bis 0 alles drunter oder drüber war zu dunkel oder zu hell u änderungen wahrzunehmen. \
\
Um dem Motion-Blur-Filter eine variable Länge zu geben wurde eine Trackbar implementiert.

#raw(
  "
  # Create windows
  cv2.namedWindow('Kernel Range')

  cv2.createTrackbar('Range', 'Kernel Range', 5, 50, lambda x: None)
...

        kernel_size = cv2.getTrackbarPos('Range', 'Kernel Range') 
  ",
  lang: "python"
)

Der Motion-Blur-Filter wurde dann wie folgt implementiert:
#raw(
  "
        kernel_h = numpy.zeros((kernel_size, kernel_size))

        kernel_h[int((kernel_size -1)/2), :] = numpy.ones(kernel_size)

        kernel_h /= kernel_size

        motion_blur_horizontal = cv2.filter2D(img, -1, kernel_h)
  ",
  lang: "python"
)

Darauf folgend wurden beide Bilder angezeigt.
#raw(
  "
        cv2.imshow('frame',img)
        cv2.imshow('Motion-Blur', motion_blur_horizontal)
  ",
  lang: "python"
)
#raw(
  "
  cv2.imshow('frame',img)
  cv2.imshow('mask',mask)
  cv2.imshow('HSV',res)
  ",
  lang: "python"
)

#grid()
#image("Frame_-6.png")
#image("Motion-Blur-5.png")
#image("Motion-Blur-30_-6.png")

#image("Frame_-5.png")
#image("Motion-Blur-5_-5.png")
#image("Motion-Blur-30_-5.png")

#image("Frame_-7.png")
#image("Motion-Blur-5_-7.png")
#image("Motion-Blur-30_-7.png")
= Zusammenfassung

= Literatur

#bibliography(
  ("Citing.bib"),
  style: "ieee",
  title: none
) q