module MyJekyllPlugins
    module Generators
        class MonthlyArchive < Jekyll::Generator
            def monthly_archive_list(site)
                site.posts.each.group_by{|post| Date.new(post.date.year, post.date.month)}
            end

            def generate(site)
                archive = monthly_archive_list(site)
                site.config['monthly_archive_list'] = archive.sort.reverse!

                archive.each do |date, posts|
                    site.pages << MonthlyArchivePage.new(site, nil, date, posts.sort.reverse!)
                end
            end
        end

        class TagsArchive < Jekyll::Generator
            def generate(site)
                site.config['tags_archive_list'] = site.tags.each_key.sort

                site.tags.each do |tag, posts|
                    site.pages << TagArchivePage.new(site, nil, tag, posts.sort.reverse!)
                end
            end
        end

        class SimplePage < Jekyll::Page
            def initialize(site, base, dir, name, data)
                #super(site, base, dir, name)
                @site = site
                @base = base
                @dir  = dir
                @name = name

                self.process(name)
                self.data = data
            end
        end

        class MonthlyArchivePage < SimplePage
            def initialize(site, dir, date, posts)
                layout = 'monthly_archive'
                super(site, dir, '%04d/%02d' % [date.year, date.month], 'index.html',
                      {
                          'layout' => layout,
                          'title' => '%04d-%02d' % [date.year, date.month],
                          'posts' => posts,
                          'content' => '{% for post in page.posts %}<li><a href="{{ site.url }}{{ post.url }}"><span>{{ post.title }}<span></a></li>
{% endfor %}',
                          'date' => date,
                      })
            end
        end

        class TagArchivePage < SimplePage
            def initialize(site, dir, tag, posts)
                layout = 'tag_archive'
                super(site, dir, "tags/#{tag}", 'index.html',
                      {
                          'layout' => layout,
                          'title' => "#{tag}",
                          'posts' => posts,
                          'content' => '{% for post in page.posts %}<li><a href="{{ site.url }}{{ post.url }}"><span>{{ post.title }}<span></a></li>
{% endfor %}',
                          'tag' => tag
                      })
            end
        end

        class FilesGenerator < Jekyll::Generator
            def generate(site)
                site.posts.each do |post|
                    if post.data['files']
                        files = []
                        post.data['files'].each do |pattern|
                            Dir.glob(File.join('files', pattern)).sort{|a, b| File.mtime(b) <=> File.mtime(a)}.each do |file|
                                files << [ file, File.mtime(file), File.size(file) ]
                            end
                        end

                        post.data['file_list'] = files
                    end
                end
            end
        end

    end
end
