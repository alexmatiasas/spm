.PHONY: install test lint clean

install:
	@echo "Installing hooks..."
	lefthook install

test:
	bats tests/

lint:
	shellcheck -e SC2034 -e SC2086 -e SC2094 bin/* lib/*
	shfmt -d bin/ lib/

clean:
	rm -rf .lefthook
	rm -f *.log