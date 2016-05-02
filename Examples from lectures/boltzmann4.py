#!/usr/bin/env python

import sys
from PyQt4 import Qt, QtCore, QtGui
import math
import random


class Boltzmann:
    def __init__(self, n):
        self.n = n
        self.node = [[False] * n for i in range(n)]
        self.dist = [[0.0] * n for i in range(n)]

        self.xposition = [math.cos(i*2.0*math.pi/n) for i in range(n)]
        self.yposition = [math.sin(i*2.0*math.pi/n) for i in range(n)]

        self.temperature = 5.0
        self.bias = 3.0
        self.sameplace = -2.0
        self.sametime = -2.0

        self.updatedist()
        self.step()

    def updatedist(self):
        for i in range(self.n):
            for j in range(self.n):
                self.dist[i][j] = math.sqrt((self.xposition[i] -
                                             self.xposition[j])**2 +
                                            (self.yposition[i] -
                                             self.yposition[j])**2)

    def step(self):
        for i in range(self.n):
            for j in range(self.n):
                input = self.bias
                for k in range(self.n):
                    if k!=i and self.node[k][j]:
                        input += self.sameplace
                    if k!=j and self.node[i][k]:
                        input += self.sametime
		    if k != j:
			next = (i+1) % self.n
			prev = (i-1+self.n) % self.n
                        if self.node[prev][k]:
                            input -= self.dist[j][k]
			if self.node[next][k]:
			    input -= self.dist[j][k]

                p = 1.0/(1.0 + math.exp(-input/self.temperature))
                self.node[i][j] = random.random() < p


class MyPainting(QtGui.QWidget):
    def __init__(self, parent, model):
        QtGui.QWidget.__init__( self, parent )
        self.model = model
        self.startTimer(40)
        self.xsize = 300
        self.ysize = 300
        self.minsize = 300

    def sizeHint(self):
        return QtCore.QSize(self.xsize, self.ysize)

    def timerEvent(self, ev):
        self.step()

    def resizeEvent(self, ev):
        size = ev.size()
        self.xsize = size.width()
        self.ysize = size.height()
        self.minsize = min(self.xsize, self.ysize)

    def xscale(self, x):
        return self.xsize/2 + x*(self.minsize - 20)/2

    def yscale(self, y):
        return self.ysize/2 + y*(self.minsize - 20)/2

    def paintEvent(self, ev):
        p = QtGui.QPainter()
        p.begin(self)
        p.setPen (QtGui.QPen(QtGui.QColor(0,0,0), 3))

        for i in range(self.model.n):
            p.drawEllipse( self.xscale(self.model.xposition[i]) - 5,
                           self.yscale(self.model.yposition[i]) - 5,
                           10, 10 )

        n = self.model.n
        for i in range(n):
            for j in range(n):
                for k in range(n):
                    if self.model.node[k][i] and self.model.node[(k+1)%n][j]:
                        p.drawLine( self.xscale(self.model.xposition[i]),
                                    self.yscale(self.model.yposition[i]),
                                    self.xscale(self.model.xposition[j]),
                                    self.yscale(self.model.yposition[j]) )
                        break

        p.end()

    def step(self):
        self.model.step()
        self.repaint()

    def newtemp(self, temp):
        self.model.temperature = (temp+1)*0.015

    def randpos(self):
        model = self.model
        model.xposition = [random.random()*2-1 for i in range(model.n)]
        model.yposition = [random.random()*2-1 for i in range(model.n)]
        model.updatedist()


class MyMainWindow( QtGui.QMainWindow ):
    def __init__(self):
        QtGui.QMainWindow.__init__( self )

        wid = QtGui.QWidget(self)
        layout = QtGui.QHBoxLayout()

        paint = MyPainting( self, Boltzmann(10) )

        menubar = self.menuBar()

        randaction = menubar.addAction( "&Randomize", paint.randpos )
        randaction.setShortcut( "r" )
        randaction.setToolTip( "Randomize positions" )

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
win.show()
sys.exit(application.exec_())
