#!/usr/bin/env ruby
#
# Include assets hook


Jekyll::Hooks.register :site, :post_write do |site|

    site.posts.docs.each do |post|
        src_dir = File.join(File.dirname(post.path), 'assets')
        dest_dir = File.join(site.dest, post.id, 'assets')
        if Dir.exist?(src_dir)
            FileUtils.mkdir_p(dest_dir)
            Dir.glob(File.join(src_dir, '*')).each do |img|
                next unless File.file?(img)
                FileUtils.cp(img, dest_dir)
            end
        end
    end
end
