
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
		-v "$$PWD:/srv/jekyll" \
		-w "/srv/jekyll" \
		-e BUNDLE_PATH="/srv/jekyll/.bundles_cache" \
		-p 4000:4000 \
		ruby:3-alpine \
		sh -c "gem install bundler && bundle install && bundle exec jekyll serve --host 0.0.0.0 --verbose --config _config.yml,_config_dev.yml"
