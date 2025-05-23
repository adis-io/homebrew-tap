class ElasticsearchAT7102 < Formula
  desc "Distributed search & analytics engine"
  homepage "https://www.elastic.co/products/elasticsearch"
  version "7.10.2"
  license "Apache-2.0"

  # Elasticsearch 7.10.2 doesn't have native ARM64 macOS builds
  # Use the x86_64 version on all architectures (will run via Rosetta 2 on ARM64)
  url "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-7.10.2-darwin-x86_64.tar.gz"
  sha256 "3a131539d5de8bd0fd707f8ee6d06174abd9d394ec2268cca9452cb9c47258ca"

  keg_only :versioned_formula

  depends_on "openjdk@11"

  def install
    # Remove Windows files
    rm_f Dir["bin/*.bat"]
    rm_f Dir["bin/*.exe"]

    # Install everything into libexec
    libexec.install Dir["*"]

    # Set up directories
    (etc/"elasticsearch").mkpath
    (var/"lib/elasticsearch").mkpath
    (var/"log/elasticsearch").mkpath
    (var/"elasticsearch/plugins").mkpath

    # Move config files to etc
    (etc/"elasticsearch").install Dir[libexec/"config/*"]
    
    # Remove the config directory from libexec and symlink to etc
    rm_rf libexec/"config"
    libexec.install_symlink etc/"elasticsearch" => "config"

    # Update paths in config files - make the regex more flexible
    inreplace etc/"elasticsearch/elasticsearch.yml" do |s|
      # Look for commented path.data and path.logs with various spacing
      s.gsub!(/^#\s*path\.data:\s*.*/, "path.data: #{var}/lib/elasticsearch")
      s.gsub!(/^#\s*path\.logs:\s*.*/, "path.logs: #{var}/log/elasticsearch")
    end

    # Create wrapper scripts with proper JAVA_HOME
    env = {
      JAVA_HOME: Formula["openjdk@11"].opt_prefix.to_s,
    }
    
    # Create wrapper for elasticsearch
    (bin/"elasticsearch").write_env_script libexec/"bin/elasticsearch", env
    
    # Create wrappers for other binaries
    Dir[libexec/"bin/*"].each do |f|
      next if f.end_with?(".bat", ".exe")
      bn = File.basename(f)
      next if bn == "elasticsearch"  # already handled
      (bin/bn).write_env_script f, env
    end
  end

  def post_install
    # Make sure runtime directories exist with correct permissions
    (var/"lib/elasticsearch").mkpath
    (var/"log/elasticsearch").mkpath
    (var/"elasticsearch/plugins").mkpath
  end

  service do
    run [opt_bin/"elasticsearch"]
    keep_alive true
    working_dir var
    log_path var/"log/elasticsearch/elasticsearch.log"
    error_log_path var/"log/elasticsearch/elasticsearch.log"
    environment_variables JAVA_HOME: Formula["openjdk@11"].opt_prefix
  end

  def caveats
    s = <<~EOS
      Data:    #{var}/lib/elasticsearch/
      Logs:    #{var}/log/elasticsearch/
      Plugins: #{var}/elasticsearch/plugins/
      Config:  #{etc}/elasticsearch/

      Elasticsearch 7.10.2 requires Java 11. This formula uses the bundled openjdk@11.
    EOS

    if Hardware::CPU.arm?
      s += <<~EOS

        Note: This formula installs the x86_64 version of Elasticsearch 7.10.2
        which will run under Rosetta 2 on Apple Silicon Macs, as there is no
        native ARM64 build available for this version.
      EOS
    end

    s += <<~EOS

      To start elasticsearch:
        brew services start #{name}

      Or run manually:
        #{opt_bin}/elasticsearch
    EOS

    s
  end

  test do
    port = free_port
    system "#{bin}/elasticsearch", "-E", "http.port=#{port}", "-E", "transport.port=#{free_port}",
           "-E", "node.name=test", "-E", "cluster.initial_master_nodes=test",
           "-E", "discovery.type=single-node", "-E", "path.data=#{testpath}/data",
           "-E", "path.logs=#{testpath}/logs", "-d", "-p", "#{testpath}/pid"

    sleep 20

    begin
      output = shell_output("curl -s http://localhost:#{port}")
      assert_match '"cluster_name" : "elasticsearch"', output
    ensure
      Process.kill(9, File.read("#{testpath}/pid").to_i)
    end
  end
end
