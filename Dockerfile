FROM continuumio/miniconda3

# Preprocessing Junk
RUN apt update -y
RUN apt-get update -y
RUN apt install -y curl wget bzip2 git gnupg2
RUN apt install -y poppler-utils ghostscript 
RUN apt install -y imagemagick

# see https://stackoverflow.com/questions/42928765/convertnot-authorized-aaaa-error-constitute-c-readimage-453
ADD policy.xml /etc/ImageMagick-6/policy.xml 

# Mask-RCNN fork -- stick to the CPU version for CHTC
RUN git clone https://github.com/iross/Mask-RCNN-exp

WORKDIR /Mask-RCNN-exp/exp/
RUN git fetch origin && git checkout prep_for_chtc
RUN sed -i "s|tensorflow-gpu|tensorflow|g" /Mask-RCNN-exp/exp/c_requirements.txt
RUN conda install --file c_requirements.txt && \
    pip install -r requirements.txt && \
    ./install.sh

# Add weights file
RUN mkdir -p weights/pages_uncollapsed20190114T1121/
ADD mask_rcnn_pages_uncollapsed_0022.h5 /Mask-RCNN-exp/exp/weights/pages_uncollapsed20190114T1121/
RUN mkdir -p pdf/

# Tesseract
RUN echo "deb http://ftp.debian.org/debian stretch-backports main" >> /etc/apt/sources.list
RUN apt update -y
RUN apt install -y tesseract-ocr-osd/stretch-backports tesseract-ocr-eng/stretch-backports
#RUN apt install -y tesseract-ocr/stretch-backports

RUN mkdir /input && chmod 777 /input
RUN mkdir /output && chmod 777 /output

WORKDIR /output/
RUN ln -s /Mask-RCNN/exp/weights
    
