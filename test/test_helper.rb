File.expand_path('../../lib', __FILE__).tap do |path|
  $LOAD_PATH.unshift path unless $LOAD_PATH.include? path
end

require 'misc'

require 'test/unit'
