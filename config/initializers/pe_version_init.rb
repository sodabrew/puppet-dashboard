# Retrieves the Puppet Enterprise version, and provides simple methods to present
# the versioning information however it may be needed. Any repo should be able to
# access these facts by passing a require File.join(File.dirname(_FILE_),
# '../relative-path-to-src/puppet-dashboard/config/initializers/pe_version_init')

def retrieve_pe_version
  pe_version_fact     = File.read('/opt/puppet/pe_version').chomp
  @pe_version_array   = pe_version_fact.split( '.' )
  @pe_major_version   = @pe_version_array[0]
  @pe_minor_version   = @pe_version_array[1]
  pe_version_fact
end

def pe_major_version
  retrieve_pe_version if @pe_major_version == nil
  @pe_major_version
end

def pe_minor_version
  retrieve_pe_version if @pe_mionor_version == nil
  @pe_minor_version
end

def pe_version_major_minor
  retrieve_pe_version if (@pe_major_version||@pe_mionor_version)== nil
  "#{@pe_major_version}.#{@pe_minor_version}"
end