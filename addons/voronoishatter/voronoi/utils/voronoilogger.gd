# Simple logger wrapper
extends Object

class_name VoronoiLog

const prefix = "[VoronoiShatter] "

static func err(message: String):
    printerr(prefix + message)

static func log(message: String):
    print(prefix + message)
