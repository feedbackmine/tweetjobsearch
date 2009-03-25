#!/usr/bin/env ./script/runner

require 'rubygems'
require 'tokenizer'
require 'svm'
require 'yaml'

#replace the one in svm.rb
def _convert_to_svm_node_array(a)  
  data = svm_node_array(a.size + 1)
  svm_node_array_set(data,a.size,-1,0)
  i = 0
  a.each {|x|
    svm_node_array_set(data, i, x, 1)
    i += 1
  }
  return data
end

def tokenize(text)
  result = []
  tokenizer = Tokenizer.new(text)
  while token = tokenizer.next
    result << token.downcase
  end
  return result
end

class FeatureDictionary
  def initialize
    @map = {}
    @i = 1
  end
  
  def [] word
    v = @map[word]
    v ? v : 0
  end
  
  def add word
    unless @map.has_key? word
      @map[word] = @i
      @i += 1
    end
  end
  
  def save filename
    File.open(filename, 'w') {|f| f.puts to_yaml}
  end
  
  def self.load filename
    YAML::load(File.open(filename))
  end
end

class TrainingData
  def self.convert(text, feature_dictionary)
    words = tokenize(text)
    words.uniq!
    words.each {|word| feature_dictionary.add(word)}
    features = words.map {|word| feature_dictionary[word]}
    features.sort!
    features.reject! {|x| x == 0}
    return features
  end
end


class Classifier
  MODEL_FILENAME = 'job.model'
  FEATURE_FILENAME = 'job.dict'
  
  def initialize(model = nil, feature_dictionary = FeatureDictionary.new)
    @model = model
    @feature_dictionary = feature_dictionary
    @logger = Logger.new('log/classifer.log')
  end
  
  def train tweets
    @logger.info "#{tweets.length} training data"
    if tweets.length <= 0
      return
    end

    labels = []
    training_data = []
    tweets.each {|tweet| 
      labels << tweet.label   
      training_data << TrainingData.convert(tweet.text, @feature_dictionary)
    }

    problem = Problem.new(labels, training_data)
    
    @model = Model.new(problem, find_best_parameter(problem, labels))
    @model.save(MODEL_FILENAME)
    @feature_dictionary.save(FEATURE_FILENAME)
  end
  
  def predict text
    @model.predict(TrainingData.convert(text, @feature_dictionary)).to_i
  end
  
  def self.load
    return nil unless File.exist?(MODEL_FILENAME) && File.exist?(FEATURE_FILENAME)
    model = Model.new MODEL_FILENAME
    feature_dictionary = FeatureDictionary.load FEATURE_FILENAME
    Classifier.new model, feature_dictionary
  end
  
private

  def default_parameter(c = 1, g = 0)
    Parameter.new(
      :svm_type => C_SVC,
      :kernel_type => RBF,
      :degree => 3,
      :gamma => g,
      :coef0 => 0,
      :nu => 0.5,
      :cache_size => 100,
      :C => c,
      :eps => 1e-3,
      :p => 0.1,
      #:shrinking => 1,
      :probability => 1
      #:nr_weight => 0,
      #:weight_label =? [0],
      #:weight = [0]
    )
  end
  
  def find_best_parameter(problem, labels)
    nr_fold = 5
    c_begin = -5
    c_end = 15
    c_step = 2
    g_begin = 3
    g_end = -15
    g_step = -2
    best_parameter = default_parameter
    best_total_correct = 0
    
    c = c_begin
    while c <= c_end do
      g = g_begin
      while g >= g_end do
        parameter = default_parameter(2**c.to_f, 2**g.to_f)
        target = cross_validation(problem, parameter, nr_fold)
        
        total_correct = 0
        for i in (0..problem.prob.l - 1) 
          if target[i] == labels[i]
            total_correct += 1 
          end
        end
        
        p "C=2**#{c} g=2**#{g} rate=#{total_correct}/#{problem.prob.l}"
        if total_correct > best_total_correct
          best_parameter = parameter
          best_total_correct = total_correct         
        end
        
        g += g_step
      end
      c += c_step
    end
    
    p "best rate=#{best_total_correct}/#{problem.prob.l}"
    return best_parameter
  end
end

def test
  p tokenize('@hello #job We are looking for ruby developers: http://abc.com ')
  Classifier.new.train([TrainingTweet.new(:text => '@hello #job We are looking for ruby developers: http://abc.com ', :label => 1),
                        TrainingTweet.new(:text => 'we have position open for a good developer ', :label => 1),
                        TrainingTweet.new(:text => 'dm me if you know good developer ', :label => 1),
                        TrainingTweet.new(:text => 'music is too load', :label => 0),
                        TrainingTweet.new(:text => 'dinner is ready', :label => 0),
                        TrainingTweet.new(:text => 'trying to get something done', :label => 0)
                       ])
  classifier = Classifier.load
  p classifier.predict('we are looking for ruby developers')
  p classifier.predict('music is too load')
end


def sanity_check tweets
  classifier = Classifier.load
  num = 0
  tweets.each {|tweet|
    num += 1 if classifier.predict(tweet.text) == tweet.label    
  }
  puts "#{num} out of #{tweets.size} is classified correctly"
end

#Usage: jobs/classifer train OR jobs/classifier test
if ARGV.length == 1 && ARGV[0] == 'train'
  Classifier.new.train(TrainingTweet.find(:all))
elsif ARGV.length == 1 && ARGV[0] == 'test'
  test
elsif ARGV.length == 1 && ARGV[0] == 'check'
  sanity_check(TrainingTweet.find(:all))
end

