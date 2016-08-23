all: grammar walker
grammar: VisualBasic6.g4
	java -jar /usr/local/lib/antlr-4.5.3-complete.jar VisualBasic6.g4
walker: grammar MyWalker.java
	javac *.java