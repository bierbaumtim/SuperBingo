<!-- [![style: effective dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://github.com/tenhobi/effective_dart) -->

[![codecov](https://codecov.io/gh/tb2761/SuperBingo/branch/master/graph/badge.svg)](https://codecov.io/gh/tb2761/SuperBingo)

# SuperBingo

Superbingo ist ein als Multiplayer Kartenspiel, welches im Rahmen der Ausbildung mit dem Flutter-Framework entwickelt wurde.

## Ziel des Projekts

Das Ziel des Projekts ist eine erste Version des Kartenspiels SuperBingo als App für Android und iOS. Dabei soll der Nutzer in der Lage sein, ein Spiel zu konfigurieren, zu erstellen und einem offenen, öffentlichen Spiel beizutreten. Ob ein Spiel öffentlich ist kann von dem Host konfiguriert werden, genauso wie die maximale Spieleranzahl, die Menge an Spielkarten und der Name des Spiels.

In einem Spiel soll der Nutzer eine Karte legen können und entsprechende Hinweise erhalten, wenn er diese Karten nicht spielen darf, da diese gegen eine der Regeln verstößt. Außerdem soll er entscheiden können, ob er eine Karte legen oder ziehen möchte und dann manuell eine Karten nach der anderen ziehen können.

Sobald ein Spieler nur noch eine Karte auf der Hand hat, soll er ‚Bingo‘ sagen können und beim ablegen der letzten Karte ‚SuperBingo‘. Vergisst ein Spieler dies, bekommt er den Regeln entsprechend, eine Strafe.
Karten mit einer speziellen Funktion sollen das Spiel entsprechend beeinflussen.
Haben alle Spieler ihre Karten abgelegt, soll das Spiel entweder beendet werden und neu gestartet werden können.

## Regeln von SuperBingo

- Bube und Joker funktionieren als ‚Wünsch mir‘-Karte und können auf jede andere Karte gelegt werden, wobei Bube auf Bube/Joker auf Joker nur möglich sind, wenn dazwischen mindestens ein Spieler an der Reihe war
- 7 bedeutet 2 Karten ziehen, können gestapelt werden, wodurch sich die Anzahl zuziehender Karten um jeweils 2 Karten erhöht
- 8 bedeutet aussetzen
- 9 ändert die Spielrichtung
- Hat ein Spieler nur noch eine Karte muss er Bingo sagen, ansonsten muss er eine Karte ziehen
- Legt ein Spieler seine letzte Karte ab, muss er SuperBingo sagen, ansonsten muss er eine Karte ziehen

## Umsetzung
Als Framework für die App dient Flutter und als Programmiersprache Dart. Die Daten für die Multiplayerspiele werden in Firebase Firestore gespeichert. Das Design folgt größtenteils den Material Design Guidelines und wird auf Android und iOS exakt gleich sein. 
Die App wird als 3-Schicht Struktur entwickelt, das heißt es die UI wird auf Änderungen in den BLOCs(Business Logic Component) reagieren und so wenig Logik wie nötig enthalten. Außerdem wird die UI in kleine, wiedernutzbare Widgets(Name einer UI Komponente in Flutter) aufgeteilt, wodurch bei Änderungen in den BLOCs weniger Widgets neu dargestellt werden müssen, um ein flüssiges Spielerlebnis bei 60 fps zu gewährleisten.
Die BLOCs beinhalten die komplette Logik für das Spiel und die Abläufe der App und speichern alle wichtigen Daten in Streams, wodurch die Daten asynchron verändert werden können und die UI flexible auf kleine Änderungen sofort reagieren kann. Aufwendige Prozesse werden in eigenen Isolates(Implementation von Threads in Dart) ausgelagert, um den Hauptisolate nicht zu blockieren und damit die UI einzufrieren.
Die Kommunikation zwischen der Firestore Datenbank und den einzelnen BLoCs wird von einem NetworkService übernommen. Dieser enthält einen StreamListener, welcher bei jeder Änderung in der Datenbank, die Daten in der App aktualisiert. Außerdem werden Methoden bereitgestellt um veränderte Daten an die Datenbank zu übermitteln. 
Die Daten eines Spiels werden in den Data-Models gespeichert und bilden damit die dritte Schicht. Sie beinhalten ebenso wie die UI nur so wenig Logik wie nötig.

Die 3-Schicht Struktur und die Aufteilung der Logik in kleine einfache Methoden vereinfacht das Testen der App durch Unit- und Integration-Tests und gibt einem die Möglichkeit Fehler früher und schneller zu erkennen und zu beheben. Fehler die während der Nutzung der App auftreten, werden mit Hilfe von Firebase Crashlytics aufgezeichnet, um eine schnelle Fehlerbehebung zu ermöglichen.

Um die Funktionen umzusetzen, werden Packages genutzt, die zum Beispiel die Schnittstellen zu Firestore schon fertig implementieren.
