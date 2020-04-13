##############################################################################
# Copyright 2019 IBM Corp. All Rights Reserved.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
##############################################################################
FROM centos:7

ENV GMP_VERSION=6.0.0
ENV GNU_COBOL=1.1

RUN yum install -y libtool ncurses ncurses-devel ncurses-libs make && \
    yum install -y libdb-devel libdbi libdbi-devel libtool-ltdl libtool-ltdl-devel db4 db4-devel wget

RUN mkdir /src

RUN cd /src && wget https://ftp.gnu.org/gnu/gmp/gmp-${GMP_VERSION}a.tar.xz && \
    tar xf gmp-${GMP_VERSION}a.tar.xz && \
    cd gmp-${GMP_VERSION} && ./configure ; make ; make check ; make install

RUN cd /src && wget http://sourceforge.net/projects/open-cobol/files/gnu-cobol/${GNU_COBOL}/gnu-cobol-${GNU_COBOL}.tar.gz && \
    tar xvzf gnu-cobol-${GNU_COBOL}.tar.gz && \
    cd gnu-cobol-${GNU_COBOL} && ./configure ; make ; make check ; make install

COPY ./helloworld.cobol /src

RUN cd /src && cobc -free -x -o helloworld-exe helloworld.cobol

ENV LD_LIBRARY_PATH /usr/local/lib:$LD_LIBRARY_PATH

CMD "./src/helloworld-exe"
