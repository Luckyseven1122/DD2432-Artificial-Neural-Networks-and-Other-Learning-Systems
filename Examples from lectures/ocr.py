#!/usr/bin/env python


import sys
from qt import *
from qtcanvas import *
import math
import random

from letterpatterns import trainpatterns, testpatterns


class MyFileMenu( QPopupMenu ):
    def __init__(self, parent, theview):
        QPopupMenu.__init__( self, parent )
        self.insertItem( "&Train", theview.train, Qt.Key_T )
        self.insertItem( "&Delta Train", theview.deltatrain, Qt.Key_D )
        self.insertItem( "&Randomize", theview.randomize, Qt.Key_R )
        self.insertSeparator()
        self.insertItem( "&Quit", self.quit, Qt.Key_Q )

    def quit(self):
        global application
        application.quit()


class Perceptron:
    def __init__(self):
        self.n = 63
        self.nout = 7
        self.eta = 0.1
        self.deltaeta = 0.01
        self.weights = [[0.0] * (self.n+1) for i in range(self.nout)]
        self.out = [False] * self.nout
        self.pattern = [0] * self.n

    def enter(self, pattern):
        self.pattern = pattern
        for i in range(self.nout):
            w = self.weights[i]
            s = w[0]
            for j in range(self.n):
                s += pattern[j]*w[j+1]
            self.out[i] = s>0

    def learn(self, pattern, targets):
        self.enter(pattern)
        for i in range(self.nout):
            if targets[i] != self.out[i]:
                t = (-1, 1)[targets[i]]
                w = self.weights[i]
                w[0] += self.eta * t
                for j in range(self.n):
                    w[j+1] += self.eta * pattern[j] * t

    def delta(self, pattern, targets):
        self.pattern = pattern
        for i in range(self.nout):
            w = self.weights[i]
            s = w[0]
            t = (-1, 1)[targets[i]]
            for j in range(self.n):
                s += pattern[j]*w[j+1]
            self.out[i] = s>0
            w[0] += self.deltaeta * (t - s)
            for j in range(self.n):
                w[j+1] += self.deltaeta * pattern[j] * (t - s)


    def randomize(self):
        for i in range(self.nout):
            w = self.weights[i]
            w[0] = random.normalvariate(0, 0.01)
            for j in range(self.n):
                w[j+1] = random.normalvariate(0, 0.01)


class MyPainting(QWidget):
    def __init__(self, parent, model):
        QWidget.__init__( self, parent )
        self.model = model
        self.xsize = 300
        self.ysize = 300
        self.unitsize = 30
        self.label = ('A', 'B', 'C', 'D', 'E', 'J', 'K')
        self.font = QFont()
        self.blackBrush = QBrush(QColor(0, 0, 0))
        self.randomize()
        self.newpattern(0)

    def sizeHint(self):
        return QSize(self.xsize, self.ysize)

    def resizeEvent(self, ev):
        size = ev.size()
        self.xsize = size.width()
        self.ysize = size.height()
        self.unitsize = min(self.xsize, self.ysize)/10
        self.font.setPointSize(self.unitsize)

    def xscale(self, x):
        return self.xsize/20 + x*self.unitsize

    def yscale(self, y):
        return self.ysize/20 + y*self.unitsize

    def paintEvent(self, ev):
        p = QPainter()
        p.begin(self)
        p.setPen (QPen(QColor(0,0,0), 1))
        p.setFont(self.font)

        for i in range(9):
            for j in range(7):
                if self.model.pattern[i*7+j] > 0:
                    p.fillRect(self.xscale(j),
                               self.yscale(i),
                               self.unitsize, self.unitsize, self.blackBrush)
                else:
                    p.drawRect(self.xscale(j),
                               self.yscale(i),
                               self.unitsize, self.unitsize)

        for i in range(7):
            if self.model.out[i]:
                p.drawText(self.xsize*6/7, self.unitsize + i*self.unitsize*4/3,
                           self.label[i])

        p.end()


    def enter(self, pattern):
        self.model.enter(pattern)
        self.repaint()

    def learn(self, pattern, targets):
        self.model.learn(pattern, targets)
        self.repaint()

    def deltalearn(self, pattern, targets):
        self.model.delta(pattern, targets)
        self.repaint()

    def train(self):
        for p in trainpatterns:
            self.learn(p[0], p[1])
        self.newpattern(0)

    def deltatrain(self):
        for p in trainpatterns:
            self.deltalearn(p[0], p[1])
        self.newpattern(0)

    def newpattern(self, p):
        self.enter(trainpatterns[p][0])

    def testpattern(self, p):
        self.enter(testpatterns[p][0])

    def randomize(self):
        self.model.randomize()
        self.newpattern(0)
        

class MyMainWindow( QMainWindow ):
    def __init__(self, appl):
        QMainWindow.__init__( self )

        wid = QHBox(self)

        perc = Perceptron()

        paint = MyPainting(wid, perc)

        self.menuBar().insertItem( "&File", MyFileMenu( self, paint ))
        self.setCentralWidget( wid )

        self.chooser1 = QSlider( 0, len(trainpatterns)-1, 1, 0,
                                 QSlider.Vertical, wid )
        self.connect( self.chooser1, SIGNAL("valueChanged(int)"), paint.newpattern )

        self.chooser2 = QSlider( 0, len(testpatterns)-1, 1, 0,
                                 QSlider.Vertical, wid )
        self.connect( self.chooser2, SIGNAL("valueChanged(int)"), paint.testpattern )

        self.show()


application = QApplication(sys.argv)
win = MyMainWindow(application)
application.setMainWidget(win)
application.exec_loop()
