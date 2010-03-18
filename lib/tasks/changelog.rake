desc "Generate the CHANGELOG"
task :changelog do
  sh "git-changelog --from \`semver tag\` > CHANGELOG"
end
