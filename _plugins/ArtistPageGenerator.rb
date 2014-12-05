module Jekyll

	class ArtistPage < Page

		def initialize(site, artist, reviews)
			@site = site
			@artist = artist
			self.ext = '.html'
			self.basename = 'index'
			self.content = <<-EOS
<ul class="post-list">
  {% for post in site.posts %}
    <li>
      <span class="post-meta">{{ post.date | date: "%b %-d, %Y" }}</span>

      <h2>
        <a class="post-link" href="{{ post.url | prepend: site.baseurl }}">{{ post.title }}</a>
      </h2>
      {{ post.excerpt }}
    </li>
  {% endfor %}
</ul>
EOS
			self.data = {
				'layout' => 'default',
				'title' => '#{artist} Reviews',
				'posts' => reviews
			}
		end

		def render(layouts, site_payload)
			payload = {
				'page' => self.to_liquid,
				'paginator' => pager.to_liquid
			}.deep_merge(site_payload)
			do_layout(payload, layouts)
		end

		def url
			File.join("/", "bands", @artist.downcase.gsub(" ","-"), "index.html")
			print url
		end

		def to_liquid
			self.data.deep_merge({
									"url" => self.url,
									"content" => self.content
									})
		end
	
		def write(dest_prefix, dest_suffix = nil)
			dest = dest_prefix
			dest = File.join(dest, dest_suffix) if dest_suffix
			FileUtils.mkdir_p(dest)
			path = File.join(dest, CGI.enescape(self.url))
			FileUtils.mkdir_p(File.dirname(path))
			File.open(path, 'w') do  |f|
				f.write(self.output)
			end
		end

		def html?
			true
		end

	end

	class ArtistPageGenerator < Generator

		def generate(site)
			artists = Hash.new()
			for post in site.posts
				artists[post.data['artist']] = [] unless artists.has_key? post.data['artist']
				artists[post.data['artist']].push post
			end
			
			artists.each { |artist, reviews|
				site.pages << ArtistPage.new(site, artist, reviews)
			}

		end
	
	end

end