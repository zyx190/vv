#!/usr/bin/env ruby
#
# Relative path hook

Jekyll::Hooks.register :posts, :pre_render do |post|

    # only work for './xxx/' or 'xxx/' path
    def resolve_relative_path(doc_path, relative_path)
        if relative_path.start_with?('./')
            File.join(doc_path, relative_path[2..-1])
        else
            File.join(doc_path, relative_path)
        end
    end

    # adjust markdown relative paths
    post.content = post.content.gsub(/!\[([^\]]*)\]\(([^)]+)\)/) do |match|
        alt_text = $1
        path = $2

        # skip absolute path
        next match if path.start_with?('http', '/')

        doc_path = post.id
        new_path = resolve_relative_path(doc_path, path)
        "![#{alt_text}](#{new_path})"
    end

    # adjust HTML relative paths
    post.content = post.content.gsub(/<img\s+[^>]*src=["']([^"']+)["']/) do |match|
        src = $1

        # skip absolute path
        next match if src.start_with?('http', '/')

        doc_path = post.id
        new_src = resolve_relative_path(doc_path, src)
        match.gsub(src, new_src)
    end
end