.PHONY: install test lint clean

install:
	@echo "Installing hooks..."
	lefthook install

test:
	bats tests/

lint:
	shellcheck bin/* lib/*
	shfmt -d bin/ lib/

clean:
	rm -rf .lefthook
	rm -f *.log