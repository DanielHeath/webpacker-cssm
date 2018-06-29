module CssmodulesHelper

  mattr_accessor :cache
  self.cache ||= {}

  def cssmodule(path)
    cache = {}
    if Rails.application.config.action_controller.perform_caching
      # Avoid reloading CSS paths
      cache = CssmodulesHelper.cache
    end

    return cache[path] if cache.include?(path)

    mod = JSON.parse(File.read Rails.root.join('app', 'javascript', 'src', path + '.json').to_s)

    os = OpenStruct.new(mod)

    def os.call(*args)
      args.map do |arg|
        case arg
        when Hash
          arg.keys.select {|k| arg[k]}.map {|k| public_send(k) }
        else
          public_send arg
        end
      end.compact.flatten.join(" ")
    end

    cache[path] = os

    yield os
  end

end
