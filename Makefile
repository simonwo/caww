BASE_URL ?= https://archiveofourown.org
CURL ?= curl -L --rate 1/m

1.html:
	${CURL} "${BASE_URL}/users/Patchwork_Crow/works" > $@

pages.mk: 1.html
	PAGES=$$(hq --file=$< -a=href 'ol.pagination li:not([class]) a[href]' | sort -u |\
		grep -Eo 'page=\d+' | grep -Eo '\d+' | xargs printf "%d.html "); \
	printf "$$PAGES:\n\t${CURL}" > $@; \
	for PAGE in $$(hq --file=$< -a=href 'ol.pagination li:not([class]) a[href]' | sort -u); do \
		printf " -o %d.html '${BASE_URL}%s'" $$(echo $$PAGE | grep -Eo 'page=\d+' | grep -Eo '\d+') "$$PAGE" >> $@; \
	done; \
	printf '\nindex.json: 1.json %s' $$(echo $$PAGES | sed 's/.html/.json/g') >> $@;
include pages.mk

%.json: %.html
	(for WORK in $$(cat $< | hq -a=id 'ol.work li[id^=work_]' | sort -u); do \
		printf '{"name": "%s", "url": "%s", "date": "%s"}' \
			"$$(hq -f=$< -t "#$$WORK h4 a:not([rel=author])")" \
			"${BASE_URL}$$(hq -f=$< -a=href "#$$WORK h4 a:not([rel=author])")" \
			"$$(hq -f=$< -t "#$$WORK .datetime" | xargs -IXXX date -j -f '%d %b %Y' "XXX" '+%Y-%m-%d')"; \
	done) > $@

index.json:
	cat *.json | jq -rs 'sort_by(.date)' > $@

index.html: index.json
	bash json2list.sh $< >$@
