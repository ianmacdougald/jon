chmod: 
	sudo chmod a+rx *.sh

install: 
	cp jon.sh /usr/local/bin/jon
	cp jof.sh /usr/local/bin/jof
uninstall: 
	rm /usr/local/bin/jon
	rm /usr/local/bin/jof
