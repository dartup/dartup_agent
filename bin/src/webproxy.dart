part of dartup_agent;

abstract class VirtualProxy {

  /// Adds information on virtual host
  ///
  VirtualHost addHost(String name, {String hostname, int port});

  /// Gets information about a host.
  ///
  /// Returns the same data as [addHost] except that it returns an empty Map on no data found.
  ///
  /// Do not throw an invalid name results in a host not fond and an empty Map back.
  VirtualHost getHost(String name);

  /// Removes a virtual host if it exist.
  ///
  /// If it returns false there is no record of that name.
  /// If it returns true means that the virtual host being removed and no new connections will be maid.
  /// The implementation may or may not let existing connections finnish.
  ///
  /// The underlying
  bool removeHost(String name);
}

/// Data object with information a child server need from the proxy.
class VirtualHost{
  /// Gets an empty invalid null host.
  static const emptyHost = const VirtualHost._empty();

  /// return false if valid;
  final bool isEmpty;

  /// the name uses when this host was created.
  final String name;
  /// The port the proxy sends traffic to.
  final int port;
  /// The hostname the proxy sends traffic to.
  final String hostname;
  /// The hostname the proxy listens on.
  final String domainName;

  /// Create a new valid host. Use [emptyHost] if you want an invalid one.
  const VirtualHost(this.name,this.port,this.hostname,this.domainName): isEmpty = false;

  const VirtualHost._empty(): isEmpty = true, name = '', port = 0, hostname = '', domainName = '';

  toString(){
    if(isEmpty){
      return 'VirtualHost(empty)';
    }
    return 'VirtualHost(name: $name, port: $port, hostname: $hostname, domainName: $domainName)';
  }
}