FN = 9
create:
	ruby create.rb | uniq | tippecanoe -f \
	--detect-longitude-wraparound \
	--maximum-zoom=11 -o $(FN).mbtiles ;\
	pmtiles convert $(FN).mbtiles $(FN).pmtiles
style:
	pkl eval -f json style.pkl > docs/style.json
upload:
	aws s3 cp docs/a.pmtiles s3://smartmaps/foil4gr1/reusable-h3-pmtiles/h3.pmtiles --endpoint-url=https://data.source.coop
