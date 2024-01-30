# frozen_string_literal: true

module Versioning
  class Sorter
    def initialize(list)
      @list = list
    end

    def sort
      return @list if @list.empty?
      return sort_tag_names(@list) if @list.first.is_a?(String)

      sort_releases(@list) if @list.first.is_a?(Clients::Azure::Parsers::ReleaseParser)
    end

    private

    def sort_tag_names(tag_names)
      valid_tags = tag_names.grep(/(rc\.\d+\.)?v\d+\.\d+\.\d+$/)

      invalid_tags = tag_names.grep_v(/(rc\.\d+\.)?v\d+\.\d+\.\d+$/)

      sorted = valid_tags.sort do |a, b|
        is_a_pre_release = a.match?(/^rc/)
        is_b_pre_release = b.match?(/^rc/)

        is_a_major_release = a.match?(/^v/)
        is_b_major_release = b.match?(/^v/)

        a_stable_version = a.scan(/\d+.\d+.\d+$/).first.gsub(/\D/, '').to_f
        b_stable_version = b.scan(/\d+.\d+.\d+$/).first.gsub(/\D/, '').to_f

        a_pre_release_version = a.scan(/^rc.(\d+)/).flatten.first.to_f
        b_pre_release_version = b.scan(/^rc.(\d+)/).flatten.first.to_f

        result = nil
        if is_a_pre_release && is_b_pre_release
          result = if a_stable_version == b_stable_version
                     a_pre_release_version <=> b_pre_release_version
                   else
                     a_stable_version <=> b_stable_version
                   end
        elsif is_a_major_release && is_b_major_release
          result = a_stable_version <=> b_stable_version
        elsif (is_a_pre_release && is_b_major_release) || (is_a_major_release && is_b_pre_release)
          if a_stable_version == b_stable_version
            -1
          else
            result = a_stable_version <=> b_stable_version
          end
        end

        result || a <=> b
      end.reverse

      sorted + invalid_tags
    end

    def sort_releases(releases)
      tag_names = releases.map(&:tag_name)
      sorted_tags = sort_tag_names(tag_names)
      sorted_tags.map do |tag_name|
        releases.find { |release| release.tag_name == tag_name }
      end
    end
  end
end
