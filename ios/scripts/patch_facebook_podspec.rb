#!/usr/bin/env ruby

# Script to patch the facebook_app_events podspec to use FBAudienceNetwork 6.17.0
# This is a workaround for the GitHub CI environment where we can't easily modify the podspec

require 'pathname'
require 'fileutils'

def find_podspec(dir, name_pattern)
  puts "Searching for #{name_pattern} in #{dir}"
  Dir.glob("#{dir}/**/#{name_pattern}")
end

def patch_podspec(podspec_path, old_version, new_version)
  puts "Patching #{podspec_path}"
  
  # Read the podspec file
  content = File.read(podspec_path)
  
  # Check if it already has the new version
  if content.include?(new_version)
    puts "✅ Podspec at #{podspec_path} already has the correct version: #{new_version}"
    return true
  end
  
  # Replace the version
  patched_content = content.gsub(old_version, new_version)
  
  # Check if the content was changed
  if content == patched_content
    puts "❌ Warning: No changes were made to #{podspec_path}"
    puts "Original content might not contain the expected version string:"
    puts "Expected: #{old_version}"
    
    # Print out a snippet of the file for debugging
    puts "File snippet:"
    content.lines.each_with_index do |line, idx|
      if line.include?('FBAudienceNetwork') || line.include?('facebook')
        puts "Line #{idx+1}: #{line.strip}"
      end
    end
    return false
  else
    # Write the patched content back to the file
    File.write(podspec_path, patched_content)
    puts "✅ Successfully patched #{podspec_path}"
    return true
  end
end

# Main execution
begin
  # Find the directory where plugins are located
  ios_dir = File.dirname(__FILE__) + "/.."
  plugins_dir = Pathname.new(File.expand_path(ios_dir + "/.symlinks/plugins")).to_s
  
  puts "Looking for facebook plugin podspecs in #{plugins_dir}"
  
  # Print environment information
  puts "Script execution environment:"
  puts "Current directory: #{Dir.pwd}"
  puts "Script directory: #{File.dirname(__FILE__)}"
  puts "iOS directory: #{ios_dir}"
  puts "Plugins directory: #{plugins_dir}"
  
  # Try multiple approaches to find the podspec files
  puts "Approach 1: Direct search for facebook-related podspecs"
  facebook_podspecs = find_podspec(plugins_dir, "*facebook*.podspec")
  
  if facebook_podspecs.empty?
    puts "Approach 2: Search in facebook plugin subdirectories"
    facebook_plugin_dirs = Dir.glob("#{plugins_dir}/*facebook*")
    facebook_plugin_dirs.each do |dir|
      puts "Checking #{dir}"
      ios_dir = "#{dir}/ios"
      if Dir.exist?(ios_dir)
        puts "Checking #{ios_dir}"
        podspecs = find_podspec(ios_dir, "*.podspec")
        facebook_podspecs.concat(podspecs)
      end
    end
  end
  
  if facebook_podspecs.empty?
    puts "Approach 3: Checking all podspecs for FBAudienceNetwork dependency"
    # Search in all the symlinks directory
    all_podspecs = find_podspec(plugins_dir, "*.podspec")
    puts "Found #{all_podspecs.length} total podspecs"
    
    # Read each podspec and check for FBAudienceNetwork dependency
    all_podspecs.each do |podspec_path|
      content = File.read(podspec_path)
      if content.include?('FBAudienceNetwork')
        puts "Found podspec with FBAudienceNetwork dependency: #{podspec_path}"
        facebook_podspecs << podspec_path
      end
    end
  end
  
  # If still no podspecs found, try to search in the Pods directory
  if facebook_podspecs.empty?
    puts "Approach 4: Checking in the Pods directory"
    pods_dir = "#{ios_dir}/Pods"
    if Dir.exist?(pods_dir)
      puts "Searching in #{pods_dir}"
      # Look for specs definition files
      spec_repos = "#{pods_dir}/Local Podspecs"
      if Dir.exist?(spec_repos)
        puts "Searching in Local Podspecs directory"
        local_specs = find_podspec(spec_repos, "*facebook*.podspec.json")
        facebook_podspecs.concat(local_specs)
      end
    end
  end
  
  if facebook_podspecs.empty?
    puts "❌ Error: No Facebook podspecs found"
    exit 1
  end
  
  puts "Found #{facebook_podspecs.length} Facebook podspecs"
  
  success = false
  # Patch each podspec
  facebook_podspecs.each do |podspec_path|
    # Try different version patterns
    success |= patch_podspec(podspec_path, "'FBAudienceNetwork', '6.16'", "'FBAudienceNetwork', '6.17.0'")
    success |= patch_podspec(podspec_path, '"FBAudienceNetwork", "6.16"', '"FBAudienceNetwork", "6.17.0"')
    success |= patch_podspec(podspec_path, "'FBAudienceNetwork', '= 6.16'", "'FBAudienceNetwork', '= 6.17.0'")
    success |= patch_podspec(podspec_path, '"FBAudienceNetwork", "= 6.16"', '"FBAudienceNetwork", "= 6.17.0"')
    success |= patch_podspec(podspec_path, "'FBAudienceNetwork', '~> 6.16'", "'FBAudienceNetwork', '= 6.17.0'")
    success |= patch_podspec(podspec_path, '"FBAudienceNetwork", "~> 6.16"', '"FBAudienceNetwork", "= 6.17.0"')
  end
  
  puts success ? "✅ Successfully patched at least one podspec" : "⚠️ Warning: No podspecs were patched"
  puts "✅ All Facebook podspecs have been processed"
  
rescue => e
  puts "❌ Error: #{e.message}"
  puts e.backtrace
  exit 1
end 