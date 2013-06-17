#!/usr/bin/ruby

IMAGE2MPEG = "image2mpeg"
FFMPEG = "ffmpeg"
IMAGICK_CONVERT = "convert"

CONFIG = "config.txt"
OUTPUT = "output.mpg"

def die(err)
  $stderr.puts err
  exit 1
end


unless ARGV[0] && File.exists?(ARGV[0]) # TODO: Dir.exist?
  die "Error: no directory provided"
end

dir = ARGV[0]
outputf = ARGV[1] ? ARGV[1] : dir + "/" + OUTPUT
configf = ARGV[2] ? ARGV[2] : dir + "/" + CONFIG

class SlideShow
  def initialize(dir, outputf, configf)
    @output = outputf
    @dir = dir
    @configopts = {}
    if File.exists?(configf)
      @config = configf
      process_config(@config)
    end
    @workdir = dir + "/.work/"
  end

  def generate
    puts "Finding files in input directory: #{@dir}"
    # @inputfiles = Dir.scan
    # After finding all files:
    # + pairs up text with matching images &c through a hash.
    # + keys then are sorted.
    # + iterates each key:
    # ++ building 'nextvidimages' as kenburns / scroll images are hit (keep mode), and running do_text_job as needed to create them
    # ++ running do_effect_job to create a video for each image set as needed, building 'nextvidinputs'
    # ++ running do_video_job in the end below to create @output:
    # ...
  end

  def do_effect_job(effect, *files)
    puts "Creating effect movie of type #{effect}"
    # do_system
    # output to: mktemp @workdir
    # return filename
  end

  def do_text_job(textfile, imagefile = nil)
    puts "Adding text from: #{textfile}#{imagefile ? " to #{imagefile}" : ""}"
    # http://www.imagemagick.org/Usage/annotating/
    # http://www.imagemagick.org/Usage/text/
    # do_system
    # output to: mktemp @workdir
    # return filename
  end

  def do_video_job
    puts "Creating output movie: #{@dir}"
    # TODO: http://ffmpeg.org/trac/ffmpeg/wiki/How%20to%20concatenate%20%28join,%20merge%29%20media%20files
    # do_system
    # dir & .work -> output to: @output
  end

  def process_config
    puts "Processing config file: #{@config}"
    # File.read
    # ...
    # TODO: @configopts, such as the time per image in slideshow, effect, font, &c
    ### (NOTE: also allow setting by file name in here? what about filename LIMITS themselves (day of week...etc))
  end

  def do_system(*args)
    cmd = args.join(" ")
    if $VERBOSE
      echo "-> #{cmd}"
    end
    system(*args) or die "Command failed: #{cmd}" # with err code..
  end
end

SlideShow.new(dir, outputf, configf).generate
