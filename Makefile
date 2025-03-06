# BSD 3-Clause License
#
# Copyright (c) 2025 Quux System and Technology. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

OUTPUT_BASENAME := beijing-hotel-classic-cookbook-1959

build: scan

all: scan

scan: $(OUTPUT_BASENAME)-scan.pdf

proof: $(OUTPUT_BASENAME)-proof-a4.pdf

FILELIST: \
	$(addprefix trim/, $(addsuffix .jpg, $(basename $(notdir \
		$(wildcard jpeg/a*.jpg))))) \
	$(addprefix trim/, $(addsuffix .png, $(basename $(notdir \
		$(wildcard jpeg/[bcpyz]*.jpg)))))
	ls -1 trim/* >$@

# The original book has the page size 203.2mm x 135.5mm. This length-to-width
# ratio is roughly equal to 3 : 2. Thus, with a 600dpi resolution, the
# image size of all the pages will be 4800px x 3200px.

trim/a001.jpg: trim/%.jpg: jpeg/%.jpg
	mkdir -p trim
	convert $< \
		-crop 3200x4800+24+36! -background white -flatten \
		-quality 100 -alpha off \
		png:- | \
	convert png:- \
		-auto-level \
		-quality 85 \
		$@

trim/z999.png: trim/%.png: jpeg/%.jpg
	mkdir -p trim
	convert $< \
		-filter Gaussian -resize 325x487 \
		-define filter:sigma=8 -resize 3247x4871! \
		-quality 100 -alpha off \
		png:- | \
	composite $< -compose Divide_Dst png:- \
		-quality 100 -alpha off \
		png:- | \
	convert png:- \
		-crop 3200x4800+24+36! -background white -flatten \
		-quality 100 -alpha off \
		png:- | \
	convert png:- \
		\( +clone -crop 16x16+1280+256 +repage -scale 1x1! \
			-scale 3200x4000! \) \
			-geometry +0+0      -composite \
		\( +clone -crop 1x1+0+0 +repage -scale 375x4200! \) \
			-geometry +0+450    -composite \
		\( +clone -crop 1x1+0+0 +repage -scale 3200x300! \) \
			-geometry +0+4500   -composite \
		\( +clone -crop 1x1+0+0 +repage -scale 375x4200! \) \
			-geometry +2825+450 -composite \
		-auto-level \
		-level 50%,84%,0.618 \
		-quality 100 -alpha off \
		png:- | \
	convert png:- \
		-filter Gaussian -resize 3200x4800 \
		-quality 100 -alpha off +dither -colors 16 \
		$@

trim/b001.png trim/p180.png trim/y998.png: trim/%.png: jpeg/%.jpg
	convert $< \
		-crop 3200x4800-8-12! -background white -flatten \
		-fill white -draw 'rectangle 0,0 3200,4800' \
		-quality 100 -alpha off +dither -colors 16 \
		$@

# Retinex-based intensity correction and thresholding
# https://www.hpl.hp.com/techreports/2002/HPL-2002-82.html

# Margins will be filled with background color of the page.
# 3/4 inch width margin on top. With 600 dpi, it is 450 px.
# 5/8 inch width margin on left and right. With 600 dpi, it is 375 px.
# 1/4 inch width margin on bottom. With 600 dpi, it is 150 px.
trim/%.png: jpeg/%.jpg
	convert $< \
		-filter Gaussian -resize 318x477 \
		-define filter:sigma=8 -resize 3184x4776! \
		-quality 100 -alpha off \
		png:- | \
	composite $< -compose Divide_Dst png:- \
		-quality 100 -alpha off \
		png:- | \
	convert png:- \
		-crop 3200x4800-8-12! -background white -flatten \
		-quality 100 -alpha off \
		png:- | \
	convert png:- \
		\( +clone -crop 16x16+1280+256 +repage -scale 1x1! \
			-scale 3200x450! \) \
			-geometry +0+0      -composite \
		\( +clone -crop 1x1+0+0 +repage -scale 375x4200! \) \
			-geometry +0+450    -composite \
		\( +clone -crop 1x1+0+0 +repage -scale 3200x150! \) \
			-geometry +0+4650   -composite \
		\( +clone -crop 1x1+0+0 +repage -scale 375x4200! \) \
			-geometry +2825+450 -composite \
		-auto-level \
		-level 50%,84%,0.618 \
		-quality 100 -alpha off \
		png:- | \
	convert png:- \
		-filter Gaussian -resize 3200x4800 \
		-quality 100 -alpha off -grayscale Rec709Luma -depth 4 \
		$@

$(OUTPUT_BASENAME)-scan.pdf: FILELIST
	tesseract $< $(basename $@) -l chi_sim pdf

$(OUTPUT_BASENAME)-scan.txt: FILELIST
	tesseract $< $(basename $@) -l chi_sim txt

clean:
	$(RM) trim/*.png
	$(RM) *.pdf *.txt

latex:
	$(MAKE) -C latex all

.PHONY: build all scan proof clean latex
