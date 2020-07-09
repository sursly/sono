#!/bin/sh
set -e


mkdir -p ./fonts ./fonts/static/ttf ./fonts/static/otf ./fonts/variable

echo "Generating VFs"
fontmake -g sources/sono.glyphs -o variable --output-path ./fonts/variable/Sono[wght].ttf


echo "Post processing VFs"
for ttf in ./fonts/variable/*.ttf
do
	gftools fix-dsig --autofix $ttf;
	gftools fix-nonhinting $ttf "$ttf.fix";
	mv "$ttf.fix" $ttf;
	gftools fix-unwanted-tables --tables MVAR $ttf;
	gftools fix-vf-meta $ttf;
	mv "$ttf.fix" $ttf;
    woff2_compress $ttf;
done

rm ./fonts/variable/*gasp*


echo "Generating Static fonts"
fontmake -g sources/sono.glyphs -i -o ttf --output-dir ./fonts/static/ttf/
fontmake -g sources/sono.glyphs -i -o otf --output-dir ./fonts/static/otf/

echo "Post processing TTFs"
ttfs=$(ls ./fonts/static/ttf/*.ttf)
for ttf in $ttfs
do
	gftools fix-dsig -f $ttf;
	ttfautohint $ttf $ttf.fix
	[ -f $ttf.fix ] && mv $ttf.fix $ttf
	gftools fix-hinting $ttf
	[ -f $ttf.fix ] && mv $ttf.fix $ttf
done

echo "Post processing OTFs"
otfs=$(ls ./fonts/static/otf/*.otf)
for otf in $otfs
do
	gftools fix-dsig -f $otf
done



echo "Building webfonts"
rm -rf ./fonts/web/woff2
ttfs=$(ls ./fonts/static/ttf/*.ttf)
for ttf in $ttfs; do
    woff2_compress $ttf
done
mkdir -p ./fonts/web/woff2
woff2s=$(ls ./fonts/static/*/*.woff2)
for woff2 in $woff2s; do
    mv $woff2 ./fonts/web/woff2/$(basename $woff2)
done
#########
rm -rf ./fonts/web/woff
ttfs=$(ls ./fonts/static/ttf/*.ttf)
for ttf in $ttfs; do
    sfnt2woff-zopfli $ttf
done

mkdir -p ./fonts/web/woff
woffs=$(ls ./fonts/static/*/*.woff)
for woff in $woffs; do
    mv $woff ./fonts/web/woff/$(basename $woff)
done



rm -rf master_ufo/ instance_ufo/




echo "Complete!"
