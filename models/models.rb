models = Dir[Pathname.new(File.expand_path File.dirname(__FILE__)).join('*.rb').to_s]
            .map{|model| File.basename(model, File.extname(model))}
            .reject {|model| model.eql? 'models'}

models.each do |model|
    require_relative model
end