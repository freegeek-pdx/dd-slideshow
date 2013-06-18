#!/usr/bin/ruby

require 'yaml'

$VERBOSE=true
SIMULATE = false # true

ENV_VARS=["PATH=/home/guest/image2mpeg-1.02/src/image2ppm/:/home/guest/image2mpeg-1.02/scripts/:#{ENV["PATH"]}"]
FFMPEG = "ffmpeg"
IMAGICK_CONVERT = "convert"
IMAGE2MPEG = "image2mpeg"

IMGTYPES = "png|jpg"

# TODO: implement config & such
CONFIG = "config.txt"
OUTPUT = "output.mpg"

def die(err)
  $stderr.puts err
  exit 1
end


unless ARGV[0] && File.exists?(ARGV[0]) # TODO: Dir.exist?
  if File.exists?("ex")
    ARGV[0] = "ex"
  else
    die "Error: no directory provided"
  end
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
      process_config
    end
    @workdir = dir + "/.work/"
  end

  def generate
    puts "Finding files in input directory: #{@dir}"
    Dir.mkdir(@workdir) unless File.exists?(@workdir)
    nextvidimages = []
    nextvidinputs = []
    @inputfiles = Dir.foreach(@dir) do |file| # match?
      unless file.match(/^[.]/)
        nextvidimages << File.join(@dir, file) if file.match(/[.](#{IMGTYPES})$/)
      end
    end
    nextvidimages.map!{|img|
      if File.exists?(img + ".txt")
        img = do_text_job(img + ".txt", img)
      end
      img
    }
    video = do_effect_job('kenburns', *nextvidimages)
    nextvidinputs << video
    return do_video_job(*nextvidinputs)
    # After finding all files:
    # + pairs up text with matching images &c through a hash.
    # + keys then are sorted.
    # + iterates each key:
    # ++ building 'nextvidimages' as kenburns / scroll images are hit (keep mode), and running do_text_job as needed to create them
    # ++ running do_effect_job to create a video for each image set as needed, building 'nextvidinputs'
    # ++ running do_video_job in the end below to create @output:
    # ...
  end

  # TODO: support scroll?
  def do_effect_job(effect, *files)
    puts "Creating effect movie of type #{effect}"
    f = @workdir + "/tmp.mpeg"
    do_system(IMAGE2MPEG, "-e", "MPEG2ENC", "-n", "NTSC", "-m", "DVD", "--" + effect, "-o", f, '--transition', @configopts["TRANSITION"].to_s, "--time-per-image", @configopts["TIME_PER_IMAGE"].to_s, "--time-per-transition", @configopts["TIME_PER_TRANSITION"].to_s, *files)
    # output to: mktemp @workdir # TODO: cleanup?
    return f
  end

  def do_text_job(textfile, imagefile) # TODO: imagefile = nil, straight text?
    puts "Adding text from: #{textfile}#{imagefile ? " to #{imagefile}" : ""}"
    newfile = @workdir + File.basename(imagefile)
    width=`identify -format %w #{imagefile}`.strip
    do_system(*(%w{convert -background '#0008' -fill white -gravity center -size} + ["#{width}x90", "caption:\"#{File.read(textfile).strip}\"", imagefile] + %w{+swap -gravity south -composite} + [newfile]))
    return newfile
    # http://www.imagemagick.org/Usage/annotating/
    # http://www.imagemagick.org/Usage/text/
    # do_system
    # output to: mktemp @workdir
    # return filename
  end

  # TODO: support raw video?
  def do_video_job(*inputs)
    puts "Creating output movie: #{@output}"
    do_system("cp", inputs.first, @output) # FIXME
    # TODO: http://ffmpeg.org/trac/ffmpeg/wiki/How%20to%20concatenate%20%28join,%20merge%29%20media%20files
    # do_system
    # dir & .work -> output to: @output
  end

  def process_config
    puts "Processing config file: #{@config}"
    @configopts = YAML.load_file(@config)
    # TODO: font, &c
    ### (NOTE: also allow setting by file name in here? what about filename LIMITS themselves (day of week...etc))
  end

  def do_system(*args)
    cmd = args.join(" ")
    if $VERBOSE or SIMULATE
      puts "-> #{cmd}"
    end
    return if SIMULATE
    system("env", *(ENV_VARS + args))
    if $?.exitstatus != 0
      die "Command failed (#{$?.exitstatus}): #{(ENV_VARS + [cmd]).join(" ")}" # with err code..
    end
  end
end

SlideShow.new(dir, outputf, configf).generate
