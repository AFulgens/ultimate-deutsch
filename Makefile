THIS_FILE := $(lastword $(MAKEFILE_LIST))

CSV_FILES := src/data/substantiv.csv src/data/verb.csv

LEVELS := C B2 B1 A2 A1

.SECONDEXPANSION:

setup: Pipfile
	@pipenv install

clean:
	@echo "rm build"
	@-rm -r ./build
	@@$(MAKE) --no-print-directory -f $(THIS_FILE) structure 1>/dev/null

source_to_anki: clean structure chevron C.process.sources C.brainbrew.source_to_anki guid.backmerge rest.process.sources rest.brainbrew.source_to_anki
	@echo "source_to_anki"

anki_to_source:
	@echo "anki_to_source"
	@pipenv run brainbrew run recipes/anki_to_source.yaml

structure:
	@echo "mkdir build/*"
	@mkdir -p ./build/data/c
	@mkdir -p ./build/data/b2
	@mkdir -p ./build/data/b1
	@mkdir -p ./build/data/a2
	@mkdir -p ./build/data/a1
	@mkdir -p ./build/note_models/substantiv

chevron:
	@echo "chevron"
	@pipenv run chevron -lα -rω -d src/note_templates/substantiv_base.mustache src/note_models/substantiv/singular_nominativ.mustache > ./build/note_models/substantiv/singular_nominativ.html
	@pipenv run chevron -lα -rω -d src/note_templates/substantiv_base.mustache src/note_models/substantiv/plural_nominativ.mustache > ./build/note_models/substantiv/plural_nominativ.html

guid.backmerge:
	@echo "guid backmerge"
	@$(shell pipenv run python recipes/guid_backmerge.py)

C.process.sources: C.data

rest.process.sources: $(LEVELS:=.data)

C.brainbrew.source_to_anki:
	@echo "brainbrew source_to_anki (C)"
	@pipenv run brainbrew run recipes/source_to_anki_c.yaml

rest.brainbrew.source_to_anki:
	@echo "brainbrew source_to_anki (non-C)"
	@pipenv run brainbrew run recipes/source_to_anki_rest.yaml

%.data:
	@echo "*" $*
	@@$(MAKE) --no-print-directory -f $(THIS_FILE) $*.data.base
	@@$(MAKE) --no-print-directory -f $(THIS_FILE) $*.data.files

C.data.base: src/data/word.csv
	@echo "copy C - word"
	@cp ./src/data/word.csv ./build/data/c/word.csv

B2.data.base: src/data/word.csv
	@echo "copy B2 - word"
	@head -n1 ./src/data/word.csv > ./build/data/b2/word.csv
	@grep -i "::B2" ./src/data/word.csv >> ./build/data/b2/word.csv
	@grep -i "::B1" ./src/data/word.csv >> ./build/data/b2/word.csv
	@grep -i "::A2" ./src/data/word.csv >> ./build/data/b2/word.csv
	@grep -i "::A1" ./src/data/word.csv >> ./build/data/b2/word.csv

B1.data.base: src/data/word.csv
	@echo "copy B1 - word"
	@head -n1 ./src/data/word.csv > ./build/data/b1/word.csv
	@grep -i "::B1" ./src/data/word.csv >> ./build/data/b1/word.csv
	@grep -i "::A2" ./src/data/word.csv >> ./build/data/b1/word.csv
	@grep -i "::A1" ./src/data/word.csv >> ./build/data/b1/word.csv

A2.data.base: src/data/word.csv
	@echo "copy A2 - word"
	@head -n1 ./src/data/word.csv > ./build/data/a2/word.csv
	@grep -i "::A2" ./src/data/word.csv >> ./build/data/a2/word.csv
	@grep -i "::A1" ./src/data/word.csv >> ./build/data/a2/word.csv

A1.data.base: src/data/word.csv
	@echo "copy A1 - word"
	@head -n1 ./src/data/word.csv > ./build/data/a1/word.csv
	@grep -i "::A1" ./src/data/word.csv >> ./build/data/a1/word.csv

define data_files
$$(level).data.files: $(CSV_FILES:.csv=.$$(level).data.merge)
endef

define data_merge
%.$$(level).data.merge: %.csv
	@echo "copy $(level) - $$(shell echo -n $$* | rev | cut -d'/' -f1 | rev)"
	@grep -Ef \
		<(cut ./build/data/$(level)/word.csv -d"," -f1 | sed -e 's/^/\^/' | sed -e 's/$$$$/,/') \
		$$<  \
		> ./build/data/$(level)/$$(shell echo -n $$* | rev | cut -d'/' -f1 | rev).csv
endef

$(foreach level, $(LEVELS), $(eval $(data_merge)))

$(foreach level, $(LEVELS), $(eval $(data_files)))

#	@echo "@" "$$@"
#	@echo "%" "$$%"
#	@echo "<" "$$<"
#	@echo "?" "$$?"
#	@echo "^" "$$^"
#	@echo "+" "$$+"
#	@echo "|" "$$|"
#	@echo "*" "$$*"
