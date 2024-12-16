def parse_info_file(file_path)
  info = {}
  File.open(file_path, "r") do |file|
    file.each_line do |line|
      value, key = line.strip.split("\t")
      info[key] = value
    end
  end
  info
end

def parse_file(file_path, hits, sizes)
  rows = []

  File.open(file_path, "r") do |file|
    imagery_layer = ""
    site = ""
    source = ""

    file.each_line do |line|
      line.strip!
      if line.start_with?("imagery_layer")
        imagery_layer = line.split(" ")[1].tr('"', "")
      elsif line.include?("site")
        site = line.split(" ")[1].tr('"', "")
      elsif line.include?("source")
        source = line.split(" ")[1].tr('"', "")
      end

      next unless !imagery_layer.empty? && !site.empty? && !source.empty?
      hit_count = hits[imagery_layer].to_i || 0
      size = sizes[source] || "N/A"
      rows << {
        :file => file_path.delete_prefix("./"),
        :layer => imagery_layer,
        :site => site,
        :source => source.delete_prefix("/data/imagery/"),
        :hits => hit_count,
        :size => size
      }
      imagery_layer = ""
      site = ""
      source = "" # Reset for next group
    end
  end
  rows
end

def process_directory(dir_path, hits, sizes)
  rows = []
  Dir.glob("#{dir_path}/*.rb").each do |file_path|
    rows.concat(parse_file(file_path, hits, sizes))
  end
  rows.sort_by { |row| row[:hits] } # Sort rows by hits in ascending order
end

def generate_html_table(rows)
  headers = "<tr><th>Chef File</th><th>Imagery Layer</th><th>Site</th><th>Source</th><th>Hits</th><th>Size</th></tr>\n"
  table_rows = rows.map { |row| "<tr><td>#{row[:file]}</td><td>#{row[:layer]}</td><td>#{row[:site]}</td><td>#{row[:source]}</td><td>#{row[:hits]}</td><td>#{row[:size]}</td></tr>\n" }
  "<table>\n#{headers}#{table_rows.join}</table>\n"
end

# Command line arguments
dir_path = ARGV[0]
hits_file = ARGV[1]
sizes_file = ARGV[2]

if dir_path.nil? || hits_file.nil? || sizes_file.nil?
  puts "Please provide a directory path, a hits file, and a sizes file."
else
  hits = parse_info_file(hits_file)
  sizes = parse_info_file(sizes_file)
  rows = process_directory(dir_path, hits, sizes)
  puts generate_html_table(rows)
end
