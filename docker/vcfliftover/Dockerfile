FROM ubuntu:24.04

COPY conda.yml ./

RUN apt-get update && apt-get -y install curl unzip vim

RUN curl -sSL https://repo.continuum.io/miniconda/Miniconda3-py310_23.10.0-1-Linux-x86_64.sh -o /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -bfp /usr/local/ \
    && rm -rf /tmp/miniconda.sh

RUN conda-env update -n root -f conda.yml && conda clean -a

RUN wget --no-check-certificate https://software.broadinstitute.org/software/score/score_1.20-20240505.zip && \
unzip score_1.20-20240505.zip -d /usr/local/libexec/bcftools && \
rm -rf *.zip