JUNK_FILES=$(FINAL).* *.aux *.log styles/*.aux
SOURCE=book
WEBSITE=$(USER)@YOURSITEHERE:/var/www/YOURSITEHERE
FINAL=book-final

book:
	dexy
	cp Makefile output/
	cp style.sty output/
	${MAKE} -C output clean $(FINAL).pdf
	rm -rf output/*.dvi output/*.pdf
	${MAKE} -C output $(FINAL).pdf

draft: $(FINAL).dvi

$(FINAL).pdf:
	cp $(SOURCE).tex $(FINAL).tex
	pdflatex -halt-on-error $(FINAL).tex

html: 
	cd output && htlatex $(FINAL).tex "book,index=1,2,next,fn-in"
	sed -i -f clean.sed output/*.html
	cat output/fixes.css >> output/$(FINAL).css
	
view: $(FINAL).pdf
	evince $(FINAL).pdf

clean:
	rm -rf $(JUNK_FILES)
	find . -name "*.aux" -exec rm {} \;
	rm -rf output

release: clean $(FINAL).pdf draft $(FINAL).pdf sync

sync: book html
	rsync -vz output/$(FINAL).pdf $(WEBSITE)/$(FINAL).pdf
	rsync -vz output/$(FINAL).html $(WEBSITE)/book/index.html
	rsync -vz output/*.html output/*.css $(WEBSITE)/book/

