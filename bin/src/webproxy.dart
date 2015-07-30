part of dartup_agent;

abstract class VirtualProxy {

  /// Add a new virtual host.
  ///
  /// The [id] is just an identifier for future reference must be unique.
  /// You may request what host the proxy should listen to. But the
  /// implementation may ignore your request and just assign a domain name for
  /// you. Its a normal practice when running in more development modes.
  /// This method must be idempotent as in a second request will just work as a
  /// [getHost].
  ///
  /// Return VirtualHost with the assigned values. VirtualHost is immutable and
  /// only represents a point in time.
  VirtualHost addHost(String id, {String domainName});

  /// Gets information about a host.
  /// Returns an empty VirtualHost if no host found. VirtualHost is immutable
  /// and only represents a point in time.
  VirtualHost getHost(String id);

  /// Removes a virtual host if it exist.
  ///
  /// If the [id] did not exist it will return an empty VirtualHost;
  /// Else it will return the status of the host right before its removal for
  /// easier cleanup. The implementation may or may not let existing connections
  /// finnish.
  ///
  /// The service must release the port as soon as possible as it may be
  /// reused.
  VirtualHost removeHost(String id);
}

/// Data object with information a child server need from the proxy.
class VirtualHost{
  /// Gets an empty invalid null host.
  static const emptyHost = const VirtualHost._empty();

  /// return false if valid;
  final bool isEmpty;

  /// the id given when this host was created.
  final String id;
  /// The port the proxy sends traffic to.
  final int port;
  /// The hostname the proxy sends traffic to.
  final String hostname;
  /// The hostname the proxy listens on.
  final String domainName;

  /// Create a new valid host. Use [emptyHost] if you want an invalid one.
  const VirtualHost(this.id,this.port,this.hostname,this.domainName): isEmpty = false;

  const VirtualHost._empty(): isEmpty = true, id = '', port = 0, hostname = '', domainName = '';

  toString(){
    if(isEmpty){
      return 'VirtualHost(empty)';
    }
    return 'VirtualHost(name: $id, port: $port, hostname: $hostname, domainName: $domainName)';
  }
}