#/bin/bash
find ./site/ -maxdepth 3 -mindepth 2 -type f -name 'index.html' -not -path './site/de/*' -not -path './site/en/*' | while read f; do
	echo "Fixing redirect ''$f'..."
	sed -i -E 's/\.en\/"/\/"/' $f
done
