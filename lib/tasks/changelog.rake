desc "Generate the CHANGELOG"
task :changelog do
  sh "git-changelog --from \`cat VERSION\` --to 0.0.1 > CHANGELOG"
end
