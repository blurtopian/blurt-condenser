FROM faddat/archlinux

MAINTAINER jacob@blurt.foundation

COPY . /condenser

WORKDIR /condenser

RUN sed -i -e "s/^CheckSpace/#!!!CheckSpace/g" /etc/pacman.conf && \
	pacman -Syyu --noconfirm yarn base-devel gnupg python git libtool autoconf automake libsodium && \
	sed -i -e "s/^#!!!CheckSpace/CheckSpace/g" /etc/pacman.conf


RUN mkdir tmp && \
    yarn install && \
    yarn run build

ENV PORT 8080
ENV NODE_ENV production

CMD yarn run production
