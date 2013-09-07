require 'active_support/core_ext'

CHANGELOG_FILE  = "CHANGELOG.md".freeze
GEM_DIRECTORY   = File.dirname(__FILE__).split("/")[-2].freeze
GEM_CONSTANT    = GEM_DIRECTORY.classify.constantize

task :update_changelog do
  if changelog_modified?
    warn "There are already changes to #{CHANGELOG_FILE}."
    exit 1
  end

  prepend_to_changelog

  puts <<-MSG
Updated #{CHANGELOG_FILE} with commits since v#{latest_gem_version}.
Now:
1) Update VERSION file.
2) Verify the commits added to #{CHANGELOG_FILE} since the last tag.
3) Update #{CHANGELOG_FILE} with the version for these commits.
4) Commit these CHANGELOG_FILEs.
5) Hit enter to continue.
MSG

  STDIN.gets
end


def changelog_modified?
  `git diff --quiet #{CHANGELOG_FILE}`
  $?.exitstatus == 1 ? true : false
end

def commits_since_last_release
  `git log --no-merges --format="  - %s" v#{latest_gem_version}...HEAD`
end

def latest_gem_version
  @latest_gem_version ||= begin
    require "#{GEM_DIRECTORY}/version"
    GEM_CONSTANT::VERSION
  end
end

def prepend_to_changelog
  File.write(CHANGELOG_FILE, commits_since_last_release + "\n" + File.read(CHANGELOG_FILE))
end