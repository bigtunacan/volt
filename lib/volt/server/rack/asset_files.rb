class AssetFiles
  
  # Yield for every folder where we might find components
  def app_folders
    # Find all app folders
    @app_folders ||= begin
      app_folders = ['app', 'vendor/app']
      
      # Gem folders with volt in them
      # TODO: we should probably qualify this a bit more
      app_folders += Gem.loaded_specs.values.map { |g| g.full_gem_path }.reject {|g| g !~ /volt/ }
      
      app_folders
    end
    
    # Yield each app folder and return a flattened array with
    # the results
    
    files = []
    @app_folders.each do |app_folder|
      files += yield(app_folder)
    end
    
    return files
  end
  
  def asset_folders
    @asset_folders ||= begin
      app_folders do |app_folder|
        Dir["#{app_folder}/*/assets"]
      end
    end
  end
  
  def asset_javascript_files
    if SOURCE_MAPS
      javascript_files = environment['volt/templates/page'].to_a.map {|v| '/assets/' + v.logical_path + '?body=1' }
    else
      javascript_files = ['/assets/volt/templates/page.js']
    end
    
    javascript_files << '/components/home.js'
    
    javascript_files += app_folders do |app_folder|
      Dir["#{app_folder}/*/assets/**/*.js"].map {|path| '/' + path.split('/')[2..-1].join('/') }
    end
    
    return javascript_files
  end

  def asset_css_files
    app_folders do |app_folder|
      Dir["#{app_folder}/*/assets/**/*.{css,scss}"].map {|path| '/' + path.split('/')[2..-1].join('/').gsub(/[.]scss$/, '') }
    end
  end
end