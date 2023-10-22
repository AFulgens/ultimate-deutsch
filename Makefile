THIS_FILE := $(lastword $(MAKEFILE_LIST))

CSV_FILES := src/data/guid.csv src/data/substantiv.csv src/data/verb.csv

LEVELS := c b2 b1 a2 a1
LEVELS_WO_C := b2 b1 a2 a1

.SECONDEXPANSION:

setup: Pipfile
	@pipenv install

clean:
	@echo "rm build"
	@rm -r ./build ||:

fix_encodings:
	@echo "fixing known encoding issues"
	@find ./build -type f | xargs sed -i 's/\xFC/ü/g'

source_to_anki: clean structure yq chevron fix_encodings c.process.sources fix_encodings c.brainbrew.source_to_anki fix_encodings guid.backmerge rest.process.sources fix_encodings rest.brainbrew.source_to_anki fix_encodings
	@echo "source_to_anki finished"

anki_to_source:
	@echo "anki_to_source"
	@pipenv run brainbrew run recipes/anki_to_source.yaml

structure: data.dirs
	@echo "mkdir build/*"
	@mkdir -p ./build/headers
	@mkdir -p ./build/note_models/substantiv

data.dirs: $(LEVELS:=.data.dir)

yq:
	@echo "yq"
	@yq_windows_amd64 '. | explode(.)' src/note_models/Ultimate_Deutsch_substantiv.yaml --no-doc -s '"build/note_models/" + .file_name'
	@yq_windows_amd64 '. | explode(.)' src/note_models/Ultimate_Deutsch_verb.yaml --no-doc -s '"build/note_models/" + .file_name'
	@for y in $$(find build/note_models -type f -name "*.yaml"); do yq_windows_amd64 '. |  pick(["name", "id", "css_file", "fields", "templates"])' $$y > $$y.tmp; mv $$y.tmp $$y; done
	@rm ./.yml ||:

chevron:
	@echo "chevron"
	@pipenv run chevron -lα -rω -d src/note_templates/substantiv_base.mustache src/note_models/substantiv/singular_nominativ.mustache > ./build/note_models/substantiv/singular_nominativ.html
	@sed -i 's/\xFC/ü/g' ./build/note_models/substantiv/singular_nominativ.html
	@pipenv run chevron -lα -rω -d src/note_templates/substantiv_base.mustache src/note_models/substantiv/plural_nominativ.mustache > ./build/note_models/substantiv/plural_nominativ.html
	@sed -i 's/\xFC/ü/g' ./build/note_models/substantiv/plural_nominativ.html

guid.backmerge:
	@echo "guid backmerge"
	@pipenv run python recipes/guid_backmerge.py

c.process.sources: c.data

rest.process.sources: $(LEVELS_WO_C:=.data)

c.brainbrew.source_to_anki:
	@echo "brainbrew source_to_anki (C)"
	@pipenv run brainbrew run recipes/source_to_anki_c.yaml

rest.brainbrew.source_to_anki:
	@echo "brainbrew source_to_anki (non-C)"
	@pipenv run brainbrew run recipes/source_to_anki_rest.yaml

%.data:
	@echo "*" $*
	@@$(MAKE) --no-print-directory -f $(THIS_FILE) $*.data.base
	@@$(MAKE) --no-print-directory -f $(THIS_FILE) $*.data.files

c.data.base: src/data/word.csv
	@echo "copy c - word"
	@cp ./src/data/word.csv ./build/data/c/word.csv
	@cp ./src/headers/desc.html ./build/headers/desc.html

b2.data.base: src/data/word.csv
	@echo "copy b2 - word"
	@head -n1 ./src/data/word.csv > ./build/data/b2/word.csv
	@grep "::B2" ./src/data/word.csv >> ./build/data/b2/word.csv
	@grep "::B1" ./src/data/word.csv >> ./build/data/b2/word.csv
	@grep "::A2" ./src/data/word.csv >> ./build/data/b2/word.csv
	@grep "::A1" ./src/data/word.csv >> ./build/data/b2/word.csv

b1.data.base: src/data/word.csv
	@echo "copy b1 - word"
	@head -n1 ./src/data/word.csv > ./build/data/b1/word.csv
	@grep "::B1" ./src/data/word.csv >> ./build/data/b1/word.csv
	@grep "::A2" ./src/data/word.csv >> ./build/data/b1/word.csv
	@grep "::A1" ./src/data/word.csv >> ./build/data/b1/word.csv

a2.data.base: src/data/word.csv
	@echo "copy a2 - word"
	@head -n1 ./src/data/word.csv > ./build/data/a2/word.csv
	@grep "::A2" ./src/data/word.csv >> ./build/data/a2/word.csv
	@grep "::A1" ./src/data/word.csv >> ./build/data/a2/word.csv

a1.data.base: src/data/word.csv
	@echo "copy a1 - word"
	@head -n1 ./src/data/word.csv > ./build/data/a1/word.csv
	@grep "::A1" ./src/data/word.csv >> ./build/data/a1/word.csv

define data_dir
$$(level).data.dir:
	@mkdir -p ./build/data/$(level)
	@mkdir -p ./build/note_models/$(level)
endef

$(foreach level, $(LEVELS), $(eval $(data_dir)))

define data_files
$$(level).data.files: $(CSV_FILES:.csv=.$$(level).data.merge)
endef

$(foreach level, $(LEVELS), $(eval $(data_files)))

define data_merge
%.$$(level).data.merge: %.csv
	@echo "copy $(level) - $$(shell echo -n $$* | rev | cut -d'/' -f1 | rev)"
	@grep -Ef \
		<(cut ./build/data/$(level)/word.csv -d"," -f1 | sed -e 's/^/\^/' | sed -e 's/$$$$/,/') \
		$$<  \
		> ./build/data/$(level)/$$(shell echo -n $$* | rev | cut -d'/' -f1 | rev).csv
endef

$(foreach level, $(LEVELS), $(eval $(data_merge)))

#	@echo "@" "$$@"
#	@echo "%" "$$%"
#	@echo "<" "$$<"
#	@echo "?" "$$?"
#	@echo "^" "$$^"
#	@echo "+" "$$+"
#	@echo "|" "$$|"
#	@echo "*" "$$*"
