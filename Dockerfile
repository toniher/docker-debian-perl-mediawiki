FROM debian:latest

# File Author / Maintainer
MAINTAINER Toni Hermoso Pulido <toni.hermoso@crg.eu>

ARG PERLBREW_ROOT=/usr/local/perl
ARG PERL_VERSION=5.26.1
# Enable perl build options. Example: --build-arg PERL_BUILD="--thread --debug"
ARG PERL_BUILD="-Dusethreads -Duselargefiles -Dcccdlflags=-fPIC -Doptimize=-O2 -Duseshrplib -Duse64bitall -Darchname=x86_64-linux-gnu -Dccflags=-DDEBIAN"
ARG PYENV_ROOT=/usr/local/python
ARG PYTHON_VERSION=3.6.3
ENV PYENV_ROOT $PYENV_ROOT

# Base Perl and builddep
RUN set -x; \
apt-get update && apt-get upgrade; \
apt-get install -y perl bzip2 zip curl \
	build-essential

RUN apt-get install -y git libreadline-dev sqlite3 libsqlite3-dev libssl-dev zlib1g-dev

RUN mkdir -p $PERLBREW_ROOT

RUN bash -c '\curl -L https://install.perlbrew.pl | bash'

ENV PATH $PERLBREW_ROOT/bin:$PATH
ENV PERLBREW_PATH $PERLBREW_ROOT/bin

RUN perlbrew install $PERL_BUILD perl-$PERL_VERSION
RUN perlbrew install-cpanm
RUN bash -c 'source $PERLBREW_ROOT/etc/bashrc'
		
ENV PERLBREW_ROOT $PERLBREW_ROOT
ENV PATH $PERLBREW_ROOT/perls/perl-$PERL_VERSION/bin:$PATH
ENV PERLBREW_PERL perl-$PERL_VERSION
ENV PERLBREW_MANPATH $PELRBREW_ROOT/perls/perl-$PERL_VERSION/man
ENV PERLBREW_SKIP_INIT 1

# Workdir place
RUN mkdir -p /project
WORKDIR /project

# Base Python
RUN apt-get install -y libbz2-dev

RUN bash -c 'curl -L https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer | bash'

ENV PATH $PYENV_ROOT/bin:$PATH
ENV PYTHON_VERSION $PYTHON_VERSION

RUN pyenv install $PYTHON_VERSION

ENV PATH="$PYENV_ROOT/shims:$PYENV_ROOT/versions/$PYTHON_VERSION/bin:$PATH"

VOLUME /scripts

# Adding Perl Modules
RUN cpanm MediaWiki::API
RUN cpanm App::wdq
RUN cpanm Catmandu::Wikidata

# Adding Jupyter
RUN pip install jupyter

RUN apt-get install -y libzmq3-dev --no-install-recommends

# Adding Perl kernel
RUN cpanm Devel::IPerl

# Support SSL
RUN cpanm IO::Socket::SSL

VOLUME /notebooks

# Clean cache
RUN apt-get clean
RUN set -x; rm -rf /var/lib/apt/lists/*

EXPOSE 8888


