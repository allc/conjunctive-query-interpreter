myinterpreter : Main.hs
	ghc Main.hs -o myinterpreter

clean : 
	rm Main.hi Main.o
