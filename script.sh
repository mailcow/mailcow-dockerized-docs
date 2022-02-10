#/bin/bash
find ./site/ -maxdepth 2 -mindepth 2 -type f -name 'index.html' -not -path './site/de/*' -not -path './site/en/*' | while read f; do
	#echo $f
	sed -E 's/\.en\/"[\>|\+]/\/">/' $f
done
