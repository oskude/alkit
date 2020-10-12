PREFIX ?= /usr/local

default:
	# variables:
	#    DESTDIR   temporary packaging path (default: $(DESTDIR))
	#    PREFIX    system path prefix (default: $(PREFIX))
	# targets:
	#    install   install to $$DESTDIR$$PREFIX
	#    package   create system package (for archlinux)
	#    clean     remove any temporary files

install:
	install -d $(DESTDIR)$(PREFIX)/lib/alkit/cmd
	install -Dm755 src/cmd/.lib.sh $(DESTDIR)$(PREFIX)/lib/alkit/cmd/.lib.sh
	install -Dm755 src/cmd/* $(DESTDIR)$(PREFIX)/lib/alkit/cmd
	install -Dm755 src/alkit $(DESTDIR)$(PREFIX)/bin/alkit
	sed -ri 's|(^.+alkit_cmddir=).*|\1"$(PREFIX)/lib/alkit/cmd"|' $(DESTDIR)$(PREFIX)/bin/alkit
	sed -ri 's|(^.+alkit_version=).*|\1"$(shell git describe --tags)"|' $(DESTDIR)$(PREFIX)/bin/alkit

package:
	# TODO: how to tell makepkg not to update pkgver?!
	makepkg --noextract -p pkgbuild

clean:
	rm *.pkg.tar.* || true
	rm -rf pkg || true
