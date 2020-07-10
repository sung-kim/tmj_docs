# Minimal makefile for Sphinx documentation
# vim: noexpandtab tabstop=3 softtabstop=3 shiftwidth=3

.PHONY: help publish clean html

# You can set these variables from the command line.
SPHINXOPTS    =
SPHINXBUILD   = sphinx-build
SPHINXPROJ    = tmj
SOURCEDIR     = .
BUILDDIR      = _build

PUBLISHDIR    = docs

help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

html: Makefile
	doxygen
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

publish: clean html
	@mkdir -p $(PUBLISHDIR)
	make -C ./ html
	@# cleanup unneeded build outputs and organize for github pages
	@rm -rf $(PUBLISHDIR)/*
	@cp -rf $(BUILDDIR)/html/* $(PUBLISHDIR)
	@touch $(PUBLISHDIR)/.nojekyll

clean:
	@rm -rf $(BUILDDIR) _build_doxy

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
