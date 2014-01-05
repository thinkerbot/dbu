require "bundler/gem_tasks"

desc "build all things"
task :all

desc "reset all things"
task :reset_all

directory "log"
Dir.glob("db/schemas/*").each do |schema_dir|
  schema_name  = File.basename(schema_dir)
  schema_files = Dir.glob("#{schema_dir}/**/*")

  file "log/#{schema_name}" => [schema_dir, "log"] + schema_files do |t|
    if sh(%{dbu setup -z '#{t.name}' '#{t.prerequisites[0]}' | dbu conn -ae '#{File.basename(t.name)}' > '#{t.name}.tmp' 2>&1})
      mv("#{t.name}.tmp", t.name)
    end
  end

  namespace :schema do
    desc "build #{schema_name}"
    task schema_name => "log/#{schema_name}"
  end
  task :all => "schema:#{schema_name}"

  namespace :reset do
    desc "reset #{schema_name}"
    task schema_name do |t|
      rm_f "log/#{t.name.split(':').last}"
    end
  end
  task :reset_all => "reset:#{schema_name}"
end
