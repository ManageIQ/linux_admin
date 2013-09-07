task :update_changelog do
  change = "CHANGELOG.md"
  `git diff --quiet #{change}`
  if $?.exitstatus == 1
    warn "There are already changes to #{change}."
    exit 1
  end
  existing = File.read(change)

  require 'linux_admin/version'
  version = LinuxAdmin::VERSION

  new_text = `git log --no-merges --format="  - %s" v#{version}...HEAD`
  File.write(change, new_text + "\n" + existing)

  msg = <<-MSG
Updated #{change} with commits since v#{version}.
Now:
1) Update LinuxAdmin::VERSION.
2) Verify the commits added to #{change} since the last tag.
3) Update #{change} with the version for these commits.
4) Commit these changes.
5) Hit enter to continue.
MSG
  puts msg

  STDIN.gets
end