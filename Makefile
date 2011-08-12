TARGET=./dist/build/hBugs/hBugs
ANNEXES=../../../annexes
DATA=$(ANNEXES)/p-value
DATA2=$(ANNEXES)/p-value-no-block

# no-block is not in the paper
# uncomment if the text should be updated.
DATASET=$(TEST) $(DATA) $(DATA2)

SRC=$(shell ls src/*.hs)
ifeq ($(shell hostname),palace.topps.diku.dk)
DB=""
else ifeq ($(shell hostname),libellule)
DB="-h localhost -p 5432 -U christophe"
DATA=test
DATA2=test
else
DB="-h localhost -p 5432"
endif

TEX=$(DATASET:%=%.tex)
WXM=$(DATASET:%=%.wxm)

.PHONY: all build run tables
.SUFFIXES: .tex .log .wxm

all: build run
run: $(TEX)
tables: $(WXM)

%.tex %.log: %.wxm
	maxima -b $^ > $(^:%.wxm=%.log)
	sed -i 's|E-\([0-9]\)| \\times 10^{-\1}|' $(^:%.wxm=%.tex)

$(DATA).wxm:
	$(TARGET) -l maxima_lib/ tables -p $(DB) -o $(DATA:%.wxm=%) -s BlockIntr

$(DATA2).wxm:
	$(TARGET) -l maxima_lib/ tables -p $(DB) -o $(DATA2:%.wxm=%) -s BlockLock,BlockIntr

$(DATA3).wxm:
	$(TARGET) -l maxima_lib/ tables -p $(DB) -o $(DATA3:%.wxm=%) -k "linux-2.6.1[23]"

ifneq ("$(TEST)", "")
$(TEST).wxm: $(TARGET)
	$(TARGET) -l maxima_lib/ tables -p $(DB) -o $(@:%.wxm=%) $(FLAGS)
endif

build $(TARGET): $(SRC)
	./Setup.lhs configure --user
	./Setup.lhs build

versions bugs:
	 $(TARGET) -l maxima_lib/ $@

help version:
	 $(TARGET) --$@

clean:
	rm -f *.wxm

fix-build:
	cabal update
	cabal install parsec
	cabal install regex-compat

pack:
	tar cjvf ../hBugs.tbz2 -C .. --exclude-vcs --exclude dist --exclude *~ hBugs 
