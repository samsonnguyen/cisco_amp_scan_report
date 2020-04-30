require 'fileutils'

module SimpleFileCache
  def cache_dir
    "cache"
  end

  def with_cache(key = cache_key)
    ensure_cachedir
    if cached?(key)
      Marshal.load(File.binread(cache_path(key)))
    else
      contents = yield
      File.open(cache_path(key), 'wb') {|f| f.write(Marshal.dump(contents))}
      contents
    end
  end

  def invalidate_cache(key = cache_key)
    FileUtils.rm(cache_path(key)) if cached?(key)
  end

  def cached?(key = cache_key)
    File.exist? cache_path(key)
  end

  def ensure_cachedir
    FileUtils.mkdir_p(cache_dir) unless File.exist? cache_dir
  end

  def cache_path(key = cache_key)
    File.join(cache_dir, key)
  end

  def cache_key
    self.class.to_s.downcase
  end

end
