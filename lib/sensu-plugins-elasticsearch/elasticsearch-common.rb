#
# DESCRIPTION:
#   Common helper methods
#
# DEPENDENCIES:
#   gem: elasticsearch
#   gem: sensu-plugin
#
# USAGE:
#
# NOTES:
#
# LICENSE:
#   Brendan Gibat <brendan.gibat@gmail.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require_relative 'elasticsearch-query.rb'

module ElasticsearchCommon
  include ElasticsearchQuery
  def initialize
    super()
  end

  def client
    transport_class = nil
    if config[:transport] == 'AWS'
      transport_class = Elasticsearch::Transport::Transport::HTTP::AWS
    end

    host = {
      host:               config[:host],
      port:               config[:port],
      request_timeout:    config[:timeout],
      scheme:             config[:scheme]
    }

    if !config[:user].nil? && !config[:password].nil?
      host[:user] = config[:user]
      host[:password] = config[:password]
      host[:scheme] = 'https' unless config[:scheme]
    end

    transport_options = {}

    if config[:headers]

      headers = {}

      config[:headers].split(',').each do |header|
        h, v = header.split(':', 2)
        headers[h.strip] = v.strip
      end

      transport_options[:headers] = headers

    end

    if config[:cert_file]
      transport_options[:ssl] = { ca_file: config[:cert_file] }
    end

    @client ||= Elasticsearch::Client.new(transport_class: transport_class, hosts: [host], region: config[:region], transport_options: transport_options)
  end
end
