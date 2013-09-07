require 'active_support/core_ext'

CHANGELOG_FILE    = "CHANGELOG.md".freeze
GEM_DIRECTORY     = File.dirname(__FILE__).split("/")[-2].freeze
GEM_CONSTANT      = GEM_DIRECTORY.classify.constantize
GEM_VERSION_FILE  = "./lib/#{GEM_DIRECTORY}/version.rb"

task :prepare_for_release do
  puts "Preparing for release of #{GEM_CONSTANT}"
  new_gem_version
  update_version_file

  if changelog_modified?
    warn "There are already changes to #{CHANGELOG_FILE}."
    exit 1
  end

  prepend_to_changelog

  puts <<-MSG
Updated #{CHANGELOG_FILE} with commits since v#{latest_gem_version}.
Now:
1) Verify the commits added to #{CHANGELOG_FILE} since the last tag.
2) Update #{CHANGELOG_FILE} with the version for these commits.
3) Commit these CHANGELOG_FILEs.
4) Hit enter to continue.
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

def update_version_file
  old_contents      = File.read(GEM_VERSION_FILE).split("\n")
  updated_contents  = old_contents.collect {|line| line.include?("VERSION") ? line.split("=").first<<"= #{new_gem_version.inspect}" : line}
  File.write(GEM_VERSION_FILE, updated_contents.join("\n"))
end

def new_gem_version
  @new_gem_version ||= begin
    version = Hash[[:major, :minor, :build].zip(latest_gem_version.split(".", 3))]
    version[ask_release_type_question] = (version[ask_release_type_question].to_i + 1).to_s
    version.values.join(".")
  end
end

def ask_release_type_question
  @ask_release_type_question ||= begin
    puts <<-EOQ
Please select release type:
  1) Build (0.0.x)
  2) Minor (0.x.0)
  3) Major (x.0.0)
EOQ

    case STDIN.gets.chomp.to_i
    when 1; :build
    when 2; :minor
    when 3; :major
    end
  end
end

def latest_gem_version
  @latest_gem_version ||= begin
    require "#{GEM_VERSION_FILE}"
    GEM_CONSTANT::VERSION
  end
end

def prepend_to_changelog
  File.write(CHANGELOG_FILE, commits_since_last_release + "\n" + File.read(CHANGELOG_FILE))
end