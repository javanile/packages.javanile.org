
.PHONY: Gemfile
Gemfile:
	@echo 'source "https://rubygems.org"' > Gemfile
	@echo 'gem "github-pages", "~> 219", group: :jekyll_plugins' >> Gemfile
	@echo 'gem "kramdown-parser-gfm"' >> Gemfile
	@echo 'gem "jekyll-include-cache"' >> Gemfile

.PHONY: _config_dev.yml
_config.dev.yml:
	@echo 'baseurl: ""' > _config_dev.yml
	@echo 'repository: "javanile/packages.javanile.org"' >> _config_dev.yml

serve: Gemfile _config_dev.yml
	@mkdir -p ".bundles_cache"
	@docker run --rm -it \
		-v $$PWD:/srv/jekyll \
		-v $$PWD/.bundles_cache:/tmp/.bundles_cache \
		-e BUNDLE_PATH=/tmp/.bundles_cache \
		-p 4000:4000 \
		jekyll/builder:3.8 bash -c "\
			chmod 777 \$$BUNDLE_PATH && \
			gem install bundler -v 2.4.22 && bundle install && \
			bundle exec jekyll serve --host 0.0.0.0 --verbose --config _config.yml,_config_dev.yml"

dev-push:
	@git config credential.helper 'cache --timeout=3600'
	@git add .
	@git commit -am "Dev release"
	@git push