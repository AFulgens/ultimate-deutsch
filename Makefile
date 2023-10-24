THIS_FILE := $(lastword $(MAKEFILE_LIST))

CSV_FILES := src/data/guid.csv src/data/substantiv.csv src/data/verb.csv

LEVELS := c b2 b1 a2 a1
LEVELS_WO_C := b2 b1 a2 a1

.SECONDEXPANSION:

setup: Pipfile
	@pipenv install
	@echo ""

clean:
	@echo "[clean] rm build"
	@rm -r ./build ||:
	@echo ""

fix_encodings:
	@echo "[fix_encoding] fixing known encoding issues"

	@find ./build -type f | xargs sed -i 's_\xC3\x83\xC2\xA4_ä_g'
	@find ./build -type f | xargs sed -i 's_\xC3\xBC_ü_g'

	@find ./build -type f | xargs sed -i 's_\xE4_ä_g'
	@find ./build -type f | xargs sed -i 's_\xFC_ü_g'

	@echo ""

source_to_anki: clean structure yq chevron merge_and_sort c.process.sources c.brainbrew.source_to_anki guid.backmerge rest.process.sources rest.brainbrew.source_to_anki
	@echo "source_to_anki finished"
	@echo ""

anki_to_source:
	@echo "anki_to_source"
	@pipenv run brainbrew run recipes/anki_to_source.yaml
	@cp ./build/data/c/guid.csv ./src/data/guid.csv
	@cp ./build/data/c/substantiv.csv ./src/data/substantiv.csv
	@cp ./build/data/c/verb.csv ./src/data/verb.csv
	@cp ./build/data/c/wort.csv ./src/data/wort.csv
	@echo "anki_to_source finsihed"
	@echo ""

structure: data.dirs
	@echo "[structure] mkdir build/*"
	@mkdir -p ./build/headers
	@mkdir -p ./build/note_models/substantiv
	@echo ""

data.dirs: $(LEVELS:=.data.dir)

yq:
	@echo "[yq] exploding and processing note models"
	@yq_windows_amd64 '. | explode(.)' src/note_models/Ultimate_Deutsch_substantiv.yaml --no-doc -s '"build/note_models/" + .file_name'
	@yq_windows_amd64 '. | explode(.)' src/note_models/Ultimate_Deutsch_verb.yaml --no-doc -s '"build/note_models/" + .file_name'
	@for y in $$(find build/note_models -type f -name "*.yaml"); do yq_windows_amd64 '. |  pick(["name", "id", "css_file", "fields", "templates"])' $$y > $$y.tmp; mv $$y.tmp $$y; done
	@rm ./.yml ||:
	@echo ""
	@@$(MAKE) --no-print-directory -f $(THIS_FILE) fix_encodings

SUBSTANTIV := singular_nominativ plural_nominativ singular_akkusativ plural_akkusativ singular_genitiv plural_genitiv singular_dativ plural_dativ

%.chevron.substantiv:
	@echo "[chevron] substantiv / $*"
	@pipenv run chevron -lα -rω -d src/note_templates/substantiv_base.mustache src/note_models/substantiv/$*.mustache > ./build/note_models/substantiv/$*.html

chevron: $(SUBSTANTIV:=.chevron.substantiv)
	@echo ""
	@@$(MAKE) --no-print-directory -f $(THIS_FILE) fix_encodings

merge_and_sort:
	@echo "[merge_and_sort]"
	@pipenv run python recipes/merge_and_sort.py
	@echo ""

guid.backmerge:
	@echo "[guid backmerge]"
	@pipenv run python recipes/guid_backmerge.py
	@echo ""

c.process.sources: c.data
	@echo "[split tags] Create 'Niveau' and 'Duden Häufigkeit'"
	@pipenv run python recipes/split_tags.py
	@echo ""

rest.process.sources: $(LEVELS_WO_C:=.data)

c.brainbrew.source_to_anki:
	@echo "[brainbrew] source_to_anki (C)"
	@pipenv run brainbrew run recipes/source_to_anki_c.yaml
	@echo ""
	@@$(MAKE) --no-print-directory -f $(THIS_FILE) fix_encodings

rest.brainbrew.source_to_anki:
	@echo "[brainbrew] source_to_anki (non-C)"
	@pipenv run brainbrew run recipes/source_to_anki_rest.yaml
	@echo ""
	@@$(MAKE) --no-print-directory -f $(THIS_FILE) fix_encodings

%.data:
	@echo "[data processing] " $*
	@@$(MAKE) --no-print-directory -f $(THIS_FILE) $*.data.base
	@echo ""
	@@$(MAKE) --no-print-directory -f $(THIS_FILE) $*.data.files

c.data.base: src/data/wort.csv
	@echo "[copy c] ∀w: 'wort'"
	@cp ./src/data/wort.csv ./build/data/c/wort.csv
	@cp ./src/headers/description*.html ./build/headers/
	@echo ""

b2.data.base: src/data/wort.csv
	@echo "[copy b2] ∀w: 'wort' | 'Niveau' in (A1, A2, B1, B2)"
	@head -n1 ./build/data/c/wort.csv > ./build/data/b2/wort.csv
	@grep "::B2" ./build/data/c/wort.csv >> ./build/data/b2/wort.csv
	@grep "::B1" ./build/data/c/wort.csv >> ./build/data/b2/wort.csv
	@grep "::A2" ./build/data/c/wort.csv >> ./build/data/b2/wort.csv
	@grep "::A1" ./build/data/c/wort.csv >> ./build/data/b2/wort.csv
	@echo ""

b1.data.base: src/data/wort.csv
	@echo "[copy b1] ∀w: 'wort' | 'Niveau' in (A1, A2, B1)"
	@head -n1 ./build/data/c/wort.csv > ./build/data/b1/wort.csv
	@grep "::B1" ./build/data/c/wort.csv >> ./build/data/b1/wort.csv
	@grep "::A2" ./build/data/c/wort.csv >> ./build/data/b1/wort.csv
	@grep "::A1" ./build/data/c/wort.csv >> ./build/data/b1/wort.csv
	@echo ""

a2.data.base: src/data/wort.csv
	@echo "[copy a2] ∀w: 'wort' | 'Niveau' in (A1, A2)"
	@head -n1 ./build/data/c/wort.csv > ./build/data/a2/wort.csv
	@grep "::A2" ./build/data/c/wort.csv >> ./build/data/a2/wort.csv
	@grep "::A1" ./build/data/c/wort.csv >> ./build/data/a2/wort.csv
	@echo ""

a1.data.base: src/data/wort.csv
	@echo "[copy a1] ∀w: 'wort' | 'Niveau' in (A1)"
	@head -n1 ./build/data/c/wort.csv > ./build/data/a1/wort.csv
	@grep "::A1" ./build/data/c/wort.csv >> ./build/data/a1/wort.csv
	@echo ""

define data_dir
$$(level).data.dir:
	@echo "[structure] mkdir build/*/$(level)"
	@mkdir -p ./build/data/$(level)
	@mkdir -p ./build/note_models/$(level)
	@echo ""
endef

$(foreach level, $(LEVELS), $(eval $(data_dir)))

define data_files
$$(level).data.files: $(CSV_FILES:.csv=.$$(level).data.merge)
endef

$(foreach level, $(LEVELS), $(eval $(data_files)))

define data_merge
%.$$(level).data.merge: %.csv
	@echo "[Copy $(level)] '$$(shell echo -n $$* | rev | cut -d'/' -f1 | rev)'"
	@grep -Ef \
		<(cut ./build/data/$(level)/wort.csv -d"," -f1 | sed -e 's/^/\^/' | sed -e 's/$$$$/,/') \
		$$<  \
		> ./build/data/$(level)/$$(shell echo -n $$* | rev | cut -d'/' -f1 | rev).csv
	@echo ""
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
