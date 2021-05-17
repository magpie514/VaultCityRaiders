ctags:
	ctags -R .

count:
	find . -name '*.gd' | xargs wc -l

test:
	echo test
