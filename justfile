
root-dir := justfile_directory()

name := "python_module_04"


src-dir := root-dir / "src"
data-dir := root-dir / "data"

test_file_name := "ancient_fragment.txt"
test-file := data-dir / test_file_name
new_file_name := "new_fragment.txt"
new-file := data-dir / new_file_name

dist-dir := root-dir / "dist"
stage-dir := dist-dir / name + "_turnin"


_default:
    @just -l


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# run
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# run the entry script for the given exercise number
[group('run')]
run ex *args:
    python3 {{src-dir}}/ex{{ex}}/*.py {{args}}

[group('run')]
run-all:
  for f in ex*/*.py; do python3 "$f"; done

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# testruns
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
[group('run')]
[group('test')]
testrun0:
    cat {{test-file}}
    just run 0
    @echo ""

    -just run 0 foo
    @echo ""

    -just run 0 /etc/shadow
    @echo ""

    just run 0 {{test-file}}

[group('run')]
[group('test')]
testrun1:
    printf "\n" | just run 1 {{test-file}}
    @echo ""

    just run 1 {{test-file}} <<< {{new-file}}
    cat {{new-file}}
    @echo ""

    echo "hello world!" > {{new-file}}
    cat {{new-file}}
    just run 1 {{test-file}} <<< {{new-file}}
    cat {{new-file}}
    rm {{new-file}}

[group('run')]
[group('test')]
testrun2:
    -just run 2 foo
    @echo ""

    just run 2 {{test-file}} <<< /etc/passwd

[group('run')]
[group('test')]
testrun3:
    -rm -f {{new-file}}
    cd {{data-dir}} && python3 {{src-dir}}/ex3/*.py
    @echo ""
    @echo "--- contents of {{new-file}} ---"
    cat {{new-file}}
    @echo "--- end ---"
    rm {{new-file}}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# dist
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# package a release tarball tagged with the given version
[group('dist')]
publish tag msg:
    just dist {{tag}}
    just tag {{tag}} "{{msg}}"
    git push origin HEAD:refs/heads/main --tags
    gh release create {{tag}} {{dist-dir}}/{{name}}_turnin_{{tag}}.tar.gz


# checks then stage + tarball
[group('dist')]
dist tag="":
    just checks-dist
    just stage
    tar -czf {{dist-dir}}/{{name}}_turnin_{{tag}}.tar.gz -C {{stage-dir}} .

# rsync turnin files
[group('dist')]
stage:
    rm -rf {{stage-dir}}
    mkdir -p {{stage-dir}}
    rsync -vhacP --filter=':- .gitignore' --exclude='*.txt' src/ {{stage-dir}}/


# create tag for latest commit
[group('dist')]
tag name msg:
    #!/usr/bin/env nu
    if (git tag -l {{name}}| is-empty) {git tag {{name}} -m "{{msg}}"}

# type-check + style
[group('dist')]
checks-dist:
    just test-mypy
    just test-lint
    @printf '\033[1;32m✓ all checks passed! Ready for submission\n\033[0m\n'


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# test
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# run mypy across src/
[group('test')]
test-mypy:
    uv run mypy --check-untyped-defs {{src-dir}}

# run ruff across src/
[group('test')]
test-ruff *args:
    uv run ruff check {{src-dir}} {{args}}

# run flake8 across src/
[group('test')]
test-flake8 *args:
    uv run flake8 {{src-dir}} {{args}}

[group('test')]
test-lint:
    just test-ruff
    just test-flake8

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# clean
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# remove python caches
[group('clean')]
clean:
    find {{src-dir}} -type d -name '__pycache__' -exec rm -rf {} +
    find {{src-dir}} -type f -name '*.pyc' -delete
    rm -rf {{root-dir}}/.mypy_cache {{root-dir}}/.ruff_cache 

# clean + remove dist tree
[group('clean')]
fclean: clean
    rm -rf {{dist-dir}}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# tools
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

