#!/usr/bin/env python


import sys
from PyQt4 import Qt, QtCore, QtGui
import math
import random


class Sudoku:
    def __init__(self, known):
        n = 9
        self.n = n
        self.node = [[[False] * n for i in range(n)] for j in range(n)]
        self.support = [[[0.0] * n for i in range(n)] for j in range(n)]
        self.clamped = [[False] * n for i in range(n)]

        for i, j, k in known:
            self.clamp(i, j, k)

        self.temperature = 5.0
        self.bias = 3.0
        self.collision = -2.0
        self.badcollision = -20.0

        self.step()

    def clamp(self, i, j, k):
        for m in range(self.n):
            self.node[i][j][m] = False
        self.node[i][j][k-1] = True
        self.clamped[i][j] = True

    def step(self):
        for i in range(self.n):
            for j in range(self.n):
                for k in range(self.n):
                    if self.clamped[i][j]:
                        continue
                    support = self.bias
                    for m in range(self.n):
                        if m!=i and self.node[m][j][k]:
                            if self.clamped[m][j]:
                                support += self.badcollision
                            else:
                                support += self.collision
                        if m!=j and self.node[i][m][k]:
                            if self.clamped[i][m]:
                                support += self.badcollision
                            else:
                                support += self.collision
                        if m!=k and self.node[i][j][m]:
                            support += self.collision
                    ibase = (i/3) * 3
                    jbase = (j/3) * 3
                    for m in range(3):
                        for n in range(3):
                            if (ibase+m != i or jbase+n != j) and \
                                   self.node[ibase+m][jbase+n][k]:
                                if self.clamped[ibase+m][jbase+n]:
                                    support += self.badcollision
                                else:
                                    support += self.collision

                    if self.temperature < 0.1:
                        self.node[i][j][k] = support > 0
                    else:
                        p = 1.0/(1.0 + math.exp(-support/self.temperature))
                        self.node[i][j][k] = random.random() < p
                    self.support[i][j][k] = support


class MyPainting(QtGui.QWidget):
    def __init__(self, parent, model):
        QtGui.QWidget.__init__( self, parent )
        self.model = model
        self.startTimer(80)
        self.xsize = 300
        self.ysize = 300
        self.minsize = 300
        self.label = ('1', '2', '3', '4', '5', '6', '7', '8', '9')
        self.red = QtGui.QColor(255, 0, 0)
        self.blue = QtGui.QColor(0, 0, 255)
        self.black = QtGui.QColor(0, 0, 0)
        self.font = QtGui.QFont()

    def sizeHint(self):
        return QtCore.QSize(self.xsize, self.ysize)

    def timerEvent(self, ev):
        self.step()

    def resizeEvent(self, ev):
        size = ev.size()
        self.xsize = size.width()
        self.ysize = size.height()
        self.minsize = min(self.xsize, self.ysize)
        self.font.setPointSize(self.minsize/25)

    def xscale(self, x):
        return self.xsize/20 + x*(self.minsize - 20)/10

    def yscale(self, y):
        return self.ysize/20 + y*(self.minsize - 20)/10

    def paintEvent(self, ev):
        p = QtGui.QPainter()
        p.begin(self)
        p.setPen (QtGui.QPen(QtGui.QColor(0,0,0), 3))
        p.setFont(self.font)

        n = self.model.n
        for i in range(n):
            for j in range(n):
                for k in range(n):
                    if self.model.node[i][j][k]:
                        if self.model.clamped[i][j]:
                            p.setPen(self.blue)
                        else:
                            if self.model.support[i][j][k] < self.model.bias:
                                p.setPen(self.red)
                            else:
                                p.setPen(self.black)
                        p.drawText(self.xscale(i),
                                   self.yscale(j),
                                   self.label[k])

        p.end()

    def step(self):
        self.model.step()
        self.repaint()

    def newtemp(self, temp):
        self.model.temperature = (temp-1)*0.03


class MyMainWindow( QtGui.QMainWindow ):
    def __init__(self):
        QtGui.QMainWindow.__init__( self )

        wid = QtGui.QWidget(self)
        layout = QtGui.QHBoxLayout()

        sod = Sudoku(((2, 0, 8),
                      (3, 0, 2),
                      (8, 0, 5),
                      (4, 1, 6),
                      (6, 1, 1),
                      (8, 1, 4),
                      (0, 2, 9),
                      (2, 2, 4),
                      (4, 2, 1),
                      (6, 2, 7),
                      (8, 2, 8),
                      (0, 3, 4),
                      (6, 3, 5),
                      (2, 4, 2),
                      (3, 4, 5),
                      (5, 4, 3),
                      (7, 4, 8),
                      (8, 4, 1),
                      (0, 5, 5),
                      (4, 5, 8),
                      (7, 5, 7),
                      (2, 6, 1),
                      (3, 6, 9),
                      (7, 6, 5),
                      (3, 7, 1),
                      (1, 8, 5),
                      (2, 8, 9),
                      (3, 8, 8),
                      (5, 8, 2),
                      (7, 8, 1),
                      (8, 8, 3)))

#         sod = Sudoku(((0, 0, 6),
#                       (1, 0, 7),
#                       (5, 0, 1),
#                       (0, 1, 3),
#                       (5, 1, 9),
#                       (7, 1, 8),
#                       (8, 1, 6),
#                       (4, 2, 8),
#                       (2, 3, 7),
#                       (3, 3, 1),
#                       (6, 3, 9),
#                       (8, 3, 3),
#                       (4, 4, 4),
#                       (0, 5, 8),
#                       (2, 5, 5),
#                       (5, 5, 6),
#                       (6, 5, 4),
#                       (4, 6, 6),
#                       (0, 7, 9),
#                       (1, 7, 4),
#                       (3, 7, 2),
#                       (8, 7, 7),
#                       (3, 8, 7),
#                       (7, 8, 4),
#                       (8, 8, 1)))

#         sod = Sudoku(((3, 0, 9),
#                       (4, 0, 2),
#                       (2, 1, 5),
#                       (6, 1, 7),
#                       (1, 2, 1),
#                       (7, 2, 8),
#                       (3, 3, 1),
#                       (5, 3, 4),
#                       (6, 3, 2),
#                       (0, 4, 3),
#                       (2, 4, 2),
#                       (5, 4, 9),
#                       (0, 5, 8),
#                       (6, 5, 3),
#                       (8, 5, 6),
#                       (4, 6, 1),
#                       (5, 6, 5),
#                       (0, 7, 6),
#                       (1, 7, 3),
#                       (4, 7, 4),
#                       (8, 7, 1),
#                       (7, 8, 4),
#                       (8, 8, 7)))

        paint = MyPainting(wid, sod)

        menubar = self.menuBar()
        quitaction = menubar.addAction( "&Quit", self.close )
        quitaction.setShortcut("q")

        temp = QtGui.QSlider( QtCore.Qt.Vertical, self )
        temp.setSliderPosition( 99 )
        temp.setFixedHeight( 300 )
        self.connect( temp, Qt.SIGNAL("valueChanged(int)"), paint.newtemp )

        layout.addWidget(paint)
        layout.addWidget(temp)
        wid.setLayout(layout)
        self.setCentralWidget( wid )

        self.show()


application = QtGui.QApplication( sys.argv )
win = MyMainWindow()
sys.exit(application.exec_())
