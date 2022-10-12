build:
	mkdir -p build
test: build
	mkdir -p build/test
test/Config: test Config/test/*.pony
	ponyc Config/test -o build/test --debug
test/execute: test/Config
	./build/test/test
clean:
	rm -rf build

.PHONY: clean test
