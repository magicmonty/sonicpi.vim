# We should probably find the SynthInfo class relatively
#  Presently assumes we're in <sonic-pi-path>/app/server/ruby/lib/sonicpi
require './synths/synthinfo'

fp = File.open("/tmp/sonic-pi-synths-for-vim.rb", "w")

synths = []
context = {}

# Collect all synth info
SonicPi::Synths::SynthInfo.all_synths.each do |synth|
  synths += [ synth.to_s ]
  args = SonicPi::Synths::SynthInfo.get_info(synth).arg_defaults
  args.select {|k,v| v.is_a? Symbol}
  .each do |k,v|
    # e.g., {decay_level: :sustain_level} -> {decay_level: args[:sustain_level]}
    args[k] = args[v]
  end
  context[synth.to_s] = args.map{ |k,v| k.to_s }
end

# factor out commonalites for better readability
commonContexts = {}

contexts = context.map { |k,v| v }
elements = contexts.flatten

common = contexts.reduce (:&)
elements = elements - common
contexts = contexts.map { |v| v - common }
commonContexts["common"] = common

begin
  name = elements[0]
  nameElements = elements.select { |e| e.start_with? name }.uniq
  g1 = contexts.map { |v| v & nameElements }.uniq.select { |v| !v.empty? }
  smallest = g1.min
  g1 = g1.map { |v| (v - smallest).empty? ? smallest : v-smallest }.uniq.select { |v| !v.empty? }
  g1.select { |v| v.length > 1 }.each { |v| commonContexts[v[0]] = v }
  elements = elements - g1.flatten
end while !elements.empty?

newContexts = {}
context.each do |ck, cv|
  newValue = []
  oldValue = cv
  commonContexts.each do |k,v|
    common = oldValue & v
    if !common.empty? then
      newValue.push k
      oldValue -= common
    end
  end
  newValue.push oldValue unless oldValue.empty?
  newContexts[ck] = newValue.map { |v| v.kind_of?(Array) ? "[ #{ v.map { |i| "'#{i}'" }.join(", ") } ]" : "context_" + v }.join (" + ")
end

# output the synth data
fp.puts "# The synths"
fp.puts "@synths = []"
fp.puts "@context = {}"
commonContexts.each do |key, cont|
  fp.puts "context_#{key} = [ #{cont.map{ |c| "'#{c}'" }.join(", ")} ]"
end
synths.sort.each do |synth|
  fp.puts "@synths += [':#{synth}']"
  fp.puts "@context['#{synth}'] = #{ newContexts[synth].to_s }"
end

fp.puts
fp.puts "# The samples"
fp.puts "@samples = [ #{SonicPi::Synths::SynthInfo.all_samples.map {|s| "':#{s.to_s}'"}.join (", ")} ]"


fp.puts
fp.puts "# The FX"
fp.puts "@fx = [ #{ SonicPi::Synths::SynthInfo.all_fx.map {|f| "':#{f.to_s}'"}.join(", ") } ]"

fp.close
