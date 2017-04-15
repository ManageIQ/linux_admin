Rake::Task[:release].enhance [:prepare_for_release]

require 'active_support/core_ext'

CHANGELOG_FILE    = "CHANGELOG.md".freeze
GEM_DIRECTORY     = File.dirname(__FILE__).split("/")[-2].freeze
GEM_CONSTANT      = GEM_DIRECTORY.classify.constantize
GEM_VERSION_FILE  = "./lib/#{GEM_DIRECTORY}/version.rb"

task :prepare_for_release do
  puts "Preparing for release of #{GEM_CONSTANT}"

  puts "Old Version: #{old_release_tag}"
  puts "New Version: #{new_release_tag}"
  update_version_file

  prepend_to_changelog
  puts "\nChangelog updated, please review and save changes.  Press enter to continue..."
  STDIN.gets

  confirm_all_changes

  commit_changes
end


def file_modified_since_release?(file)
  # Check for committed changes
  `git diff --quiet #{old_release_tag}...HEAD #{file}`
  return true if $?.exitstatus == 1

  # Check for uncommitted changes
  `git diff --quiet #{file}`
  return true if $?.exitstatus == 1

  false
end

def commits_since_last_release
  `git log --no-merges --format="  - %s" #{old_release_tag}...HEAD`
end

def update_version_file
  return if file_modified_since_release?(GEM_VERSION_FILE)
  updated_contents = read_version_file.collect {|line| line.include?("VERSION") ? line.split("=").first.rstrip + " = \"#{new_gem_version}\"" : line}
  File.write(GEM_VERSION_FILE, updated_contents.join("\n"))
  puts "\nVersion File Updated"
end

def new_release_tag
  "v#{new_gem_version}"
end

def new_gem_version
  @new_gem_version ||= begin
    return version_from_version_file if file_modified_since_release?(GEM_VERSION_FILE)

    old_version = Hash[[:major, :minor, :build].zip(version_from_version_file.split("."))]
    old_version.each_with_object({}) do |(k, v), h|
      h[k] =  if    h[release_type]; 0
              elsif k == release_type; (old_version[release_type].to_i + 1).to_s
              else  old_version[k]
              end
    end.values.join(".")
  end
end

def release_type
  @release_type ||= begin
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
    else exit 1
    end
  end
end

def version_from_version_file
  read_version_file.select { |l| l.include?("VERSION")}.first.split("=").last.tr("\"", "").strip
end

def read_version_file
  @read_version_file ||= File.read(GEM_VERSION_FILE).split("\n")
end

def old_release_tag
  @old_release_tag ||= begin
    `git tag -l v*`.split("\n").last
  end
end

def prepend_to_changelog
  #TODO: prepend missing releases also?
  changes = ["## #{new_release_tag}", commits_since_last_release, File.read(CHANGELOG_FILE)].join("\n")
  File.write(CHANGELOG_FILE, changes)
end

def confirm_all_changes
  puts `git diff`
  puts <<-EOQ

Please confirm the changes above...
  1) Accept all changes
  2) Reload changes
  3) Exit - aborting commit
EOQ

  case STDIN.gets.chomp.to_i
  when 1; return
  when 2; confirm_all_changes
  else exit 1
  end
end

def commit_changes
  `git add -u`
  `git commit -m "Bumping version to #{new_release_tag}"`
  puts "\nChanges committed. Press enter to release #{GEM_CONSTANT} #{new_release_tag}"
  STDIN.gets
end